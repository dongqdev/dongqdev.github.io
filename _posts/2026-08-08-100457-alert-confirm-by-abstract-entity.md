---
title: "Alert/Confirm by Abstract Entity"
date: 2026-08-08 05:17:52 +0900
categories: ["DEV", "SAP-WIKI"]
tags: ["SAP", "개발WIKI"]
image:
  path: /_images/20260808/2026-08-08-100457-alert-confirm-by-abstract-entity_image1.png
---

## 1. 확인 창을 위한 Data definition 정의
>

- **New > Data Definition**
- **Name : ZC_TWBS_RESET_CONFIRM**

### 소스코드
```abap
@EndUserText.label: '초기화 작업 확인 팝업'
define abstract entity ZC_TWBS_RESET_CONFIRM
{
  @EndUserText.label: '선택하신 TASK의 배포 및 완료 상태를 정말 초기화하시겠습니까?'
  // 단순 안내 멘트만 보여주기 위해 입력 필드는 화면에서 숨깁니다.
  @UI.hidden: true 
  DummyField : abap.char(1); 
}
```

## 2. Behavior Definition 정의
```abap
// 기존: action resetStatus result [1] $self;
// 변경: 뒤에 parameter 키워드와 함께 1단계에서 만든 팝업 엔티티명을 엮어줍니다.
action resetStatus parameter ZC_TWBS_RESET_CONFIRM result [1] $self; 
```
## 2.  Behavior Definition(Root) 정의
```abap
// 기존: action resetStatus result [1] $self;
// 변경: 뒤에 parameter 키워드와 함께 1단계에서 만든 팝업 엔티티명을 엮어줍니다.
action resetStatus result [1] $self; 
```
## 3. Behavior Definition(Projection) 정의
```abap
use action resetStatus; 
```
## 4. Abap Class 작성
>

- severity = if_abap_behv_message=>severity-success 에 따라 메시지 창이 다름

### severity-succes
![관련 이미지](/_images/20260808/2026-08-08-100457-alert-confirm-by-abstract-entity_image1.png)

### severity-information
![관련 이미지](/_images/20260808/2026-08-08-100457-alert-confirm-by-abstract-entity_image2.png)

### severity-error
![관련 이미지](/_images/20260808/2026-08-08-100457-alert-confirm-by-abstract-entity_image3.png)

```abap
METHOD resetStatus.
    IF keys IS INITIAL. RETURN. ENDIF.

    " 1. 들어온 keys 내용을 기반으로 초고속 일괄 업데이트 처리
    MODIFY ENTITIES OF zr_twbs_task2 IN LOCAL MODE
      ENTITY ZrTwbsTask2
        UPDATE FROM VALUE #( FOR key IN keys (
                               %tky              = key-%tky
                               DeployYn          = 'N'
                               CompleteYn        = 'N'
                               Progress          = 0 " 숫자 필드일 경우 정수 형식 주입
                               %control-DeployYn   = if_abap_behv=>mk-on
                               %control-CompleteYn = if_abap_behv=>mk-on
                               %control-Progress   = if_abap_behv=>mk-on
                            ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    failed   = CORRESPONDING #( DEEP ls_failed ).
    reported = CORRESPONDING #( DEEP ls_reported ).

    " 2. 완수 후 재조회 및 화면 리턴
    IF ls_failed IS INITIAL.
      READ ENTITIES OF zr_twbs_task2 IN LOCAL MODE
        ENTITY ZrTwbsTask2 ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result_tasks).

      result = VALUE #( FOR ls_res IN lt_result_tasks ( %tky = ls_res-%tky %param = ls_res ) ).

      " [최종 마감 알림창]
      reported-zrtwbstask2 = VALUE #( FOR key IN keys (
        %tky = key-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text     = '배포 및 완료 상태가 정상적으로 초기화 되었습니다.'
               )
      ) ).
    ENDIF.
  ENDMETHOD.
```
## 5. Metadata Extention 작성
```abap
@EndUserText.label: '프로그램 UUID' // 한글 컬럼명 적용
@UI.selectionField: [ { position: 10 } ]
@UI.lineItem: [ { position: 10 }
// 액션버튼
...
,{ type: #FOR_ACTION, dataAction: 'resetStatus', label: '상태 초기화', poition: 50}
...
]
ProgUuid;
```
