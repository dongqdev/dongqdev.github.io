---
title: "METHOD IN ABAP CLASS(RAP)"
date: 2026-08-08 05:17:02 +0900
categories: ["DEV", "SAP-WIKI"]
tags: ["SAP", "개발WIKI"]
---

## 1. DETERMINATION (값 자동 채우기 및 계산)
> **Java Spring 매칭:** JPA의 `@PrePersist`, `@PreUpdate` 또는 프런트엔드의 `onChange` 이벤트 리스너

> ### FOR DETERMINE ON MODIFY

- **발동 시점:** 사용자가 화면에서 특정 필드 값을 변경하고 엔터를 치거나 포커스를 이동하는 즉시 (실시간)
- **주요 용도:** 사용자의 입력에 반응하여 다른 필드의 값을 실시간으로 계산하고 화면에 즉시 동기화할 때 사용합니다.
- **비즈니스 예시:** 품목 수량(`Quantity`)이나 단가(`UnitPrice`)가 변경되었을 때, 총금액(`TotalPrice = 수량 * 단가`)을 즉시 계산하여 화면에 보여줌.

```ABAP
METHOD calculateTotalPrice FOR DETERMINE ON MODIFY
    IMPORTING keys FOR WbsTask~Quantity. " 수량 필드가 변경될 때 트리거

  " 1. 변경된 행의 데이터 읽기
  READ ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      FIELDS ( Quantity UnitPrice ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

  " 2. 루프를 돌며 총금액 계산 후 백엔드 컨텍스트에 반영
  MODIFY ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      UPDATE FIELDS ( TotalPrice )
      WITH VALUE #( FOR ls_task IN lt_tasks (
        %tky       = ls_task-%tky
        TotalPrice = ls_task-Quantity * ls_task-UnitPrice
      ) )
    REPORTED DATA(lt_reported).
ENDMETHOD.
```

> ### FOR DETERMINE ON SAVE

- **발동 시점:** 사용자가 최종 [저장(Save)] 버튼을 누른 직후, 데이터가 데이터베이스에 최종 영속화(Commit)되기 직전
- **주요 용도:** 사용자가 직접 입력하지 않는 시스템 필드, 생성 로그, 또는 최종 마스터 일련번호를 백엔드에서 묵묵히 채워줄 때 사용합니다.
- **비즈니스 예시:** 데이터가 생성되는 순간, 현재 시스템 시간과 로그인한 유저 ID를 생성자/생성일시 필드에 자동으로 주입함.

```ABAP
METHOD setCreationLog FOR DETERMINE ON SAVE
    IMPORTING keys FOR WbsTask~setCreationLog. " 저장 시점에 트리거

  " 최종 저장 직전, 시스템 필드를 일괄적으로 채워넣음
  MODIFY ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      UPDATE FIELDS ( CreatedBy CreatedAt )
      WITH VALUE #( FOR key IN keys (
        %tky      = key-%tky
        CreatedBy = sy-uname
        CreatedAt = sy-timlo
      ) )
    REPORTED DATA(lt_reported).
ENDMETHOD.
```

## 2. VALIDATION (데이터 무결성 검증)
> **Java Spring 매칭:** Spring Boot Validation (`@Valid`, `@NotNull`) 및 Custom Validator

> ### FOR VALIDATE ON SAVE

- **발동 시점:** 사용자가 [저장(Save)] 버튼을 누른 직후 (Determination 완료 후 DB 커밋 직전)
- **주요 용도: ** 비즈니스 규칙에 어긋나는 데이터가 DB에 들어가지 못하도록 철저하게 검증합니다. 실패 시 **트랜잭션을 롤백하고 저장을 원천 차단** 합니다.
- **비즈니스 예시:** 프로젝트 '종료 날짜'가 '시작 날짜'보다 과거일 경우 저장 에러를 뿜으며 화면에 빨간색 경고창을 띄움.

```ABAP
METHOD validateDates FOR VALIDATE ON SAVE
    IMPORTING keys FOR WbsTask~validateDates.

  " 1. 검증할 날짜 데이터 읽기
  READ ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

  " 2. 비즈니스 유효성 체크
  LOOP AT lt_tasks INTO DATA(ls_task).
    IF ls_task-EndDate < ls_task-StartDate.

      " ❌ 저장을 막기 위해 failed 구조체에 마킹
      APPEND VALUE #( %tky = ls_task-%tky ) TO failed-wbstask.

      " ❌ 화면에 띄울 에러 메시지를 reported 구조체에 주입
      APPEND VALUE #(
        %tky = ls_task-%tky
        %element-EndDate = if_abap_behv=>mk-on " 에러가 발생한 필드 하이라이트
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = '종료 날짜는 시작 날짜보다 빠를 수 없습니다.'
               )
      ) TO reported-wbstask.

    ENDIF.
  ENDLOOP.
ENDMETHOD.
```

## 3. FEATURE CONTROL (화면 동적 제어)
**Java Spring 매칭:** UI Dynamic Attribute/State Control (프런트엔드 권한/상태별 Button Disabled 처리)

> ### FOR INSTANCE FEATURES

- **발동 시점:** 화면이 로딩되거나, 테이블의 데이터 행(Instance)을 사용자가 클릭하여 선택할 때마다 실시간 발동
- **주요 용도:** 데이터의 현재 '상태(Status)'에 따라 화면의 버튼을 동적으로 활성화/비활성화하거나, 특정 필드를 읽기 전용(`Read-Only`)으로 잠급니다.
- **비즈니스 예시:** 해당 작업의 상태가 이미 '완료(Completed)'인 행을 선택하면, 상단의 [작업 완료 처리] 버튼을 비활성화(`Disabled`) 시킴.

```ABAP
METHOD get_instance_features.
  " 1. 해당 행의 현재 상태값 읽기
  READ ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

  " 2. 상태에 따라 버튼(Action) 활성화 여부를 동적으로 결정
  result = VALUE #( FOR ls_task IN lt_tasks
             ( %tky = ls_task-%tky
               " 상태가 'C'(Complete)라면 버튼을 불가능(disabled)하게 만들고, 아니면 가능(enabled)하게 오픈
               %action-completeTask = COND #( WHEN ls_task-Status = 'C'
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled )
             ) ).
ENDMETHOD.
```

## 4. ACTION (커스텀 비즈니스 메서드)
> **Java Spring 매칭:** Spring REST Controller의 커스텀 `@PostMapping("/tasks/{id}/complete")` API 엔드포인트

> ### FOR ACTION (일반 또는 Static)

- **발동 시점:** 사용자가 UI 화면 툴바에 배치된 커스텀 버튼을 클릭했을 때 트리거
- **주요 용도:** 단순 CRUD(등록/수정/삭제) 외에 비즈니스적으로 무언가 프로세스를 처리하고 상태를 변경하는 핵심 비즈니스 함수를 구동합니다.
- **비즈니스 예시:**[작업 완료 처리] 버튼을 누르면 내부적으로 상태 필드를 'C'로 바꾸고 결재 프로세스를 태움. 혹은 [카테고리 추가] 팝업창을 열어 마스터 테이블에 독립 인서트를 수행함.

```ABAP
METHOD completeTask FOR ACTION
    IMPORTING keys FOR ACTION WbsTask~completeTask RESULT result.

  " [Action 핵심] 비즈니스 명령을 받아 내부 필드 상태를 완전히 업데이트함
  MODIFY ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys (
        %tky   = key-%tky
        Status = 'C' " 상태를 완료로 강제 업데이트
      ) )
    FAILED   DATA(lt_failed)
    REPORTED DATA(lt_reported).

  " 성공 시 초록색 토스트 메시지를 프런트엔드로 리턴
  APPEND VALUE #(
    %cid = keys[ 1 ]-%cid
    %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-success
             text     = '선택한 작업이 성공적으로 완료 처리되었습니다.'
           )
  ) TO reported-wbstask.
ENDMETHOD.
```

## 5. AUTHORIZATION (보안 권한 체크)
> **Java Spring 매칭:** Spring Security의 `@PreAuthorize("hasRole('ROLE_ADMIN')")` 또는 접근 제어 인터셉터

> ### FOR INSTANCE AUTHORIZATION

- **발동 시점:** 사용자가 데이터를 조회, 수정, 삭제하거나 액션 버튼을 누르기 직전 백엔드 게이트웨이에서 가동
- **주요 용도:** 현재 로그인한 유저의 권한 오브젝트(`AUTHORITY-CHECK`)를 검사하여 행 단위로 데이터 접근 권한을 완벽하게 통제합니다.
- **비즈니스 예시:** 영업 부서 사원은 타 부서(인사, 재무)의 프로젝트 데이터를 수정하거나 삭제할 수 없도록 차단함.

```ABAP
METHOD check Authorization FOR INSTANCE AUTHORIZATION
    IMPORTING
      keys       FOR WbsTask~AUTHORIZATION
      result     FOR WbsTask~AUTHORIZATION.

  READ ENTITIES OF zr_twbs_task2 IN LOCAL MODE
    ENTITY WbsTask
      FIELDS ( Department ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

  LOOP AT lt_tasks INTO DATA(ls_task).
    " 권한 없는 부서(인사/재무) 데이터라면 수정/삭제 권한을 막음
    IF ls_task-Department IN ( 'HR', 'FIN' ) AND sy-uname <> 'ADMIN'.
      APPEND VALUE #( %tky = ls_task-%tky ) TO result-wbstask.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```
