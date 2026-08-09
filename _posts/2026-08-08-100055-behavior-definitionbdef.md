---
title: "Behavior Definition(BDEF)"
date: 2026-08-08 05:14:12 +0900
categories: ["SAP-RAP"]
tags: ["SAP", "RAP"]
image:
  path: /_images/20260808/2026-08-08-100055-behavior-definitionbdef_image1.png
---



RAP 아키텍처에서 데이터 조회(Read)는 CDS 뷰가 담당하지만, **데이터의 생성(Create), 수정(Update), 삭제(Delete) 및 비즈니스 로직 제어** 는 모두 이 BDEF 파일에서 정의
- Select(조회)만 하는 경우에는 불필요
- **CDS View:** 데이터베이스 테이블을 기반으로 화면에 보여줄 필드를 선언 (정적 레이어)
- **Behavior Definition:** 데이터를 수정,저장할 때 어떤 로직을 태울지 선언 (동적 레이어)
- CDS View당 1개만 생성이 가능하다
## 1. 생성방법


- Data Definition 마우스 우클릭 후, New > Behabior Definition
- Root View, Projection View에 따라 Implementation Type 자동으로 결정 됨.
- Implementation Type : Managed(자동으로 CUD 생성)



![관련 이미지](/_images/20260808/2026-08-08-100055-behavior-definitionbdef_image1.png)




![관련 이미지](/_images/20260808/2026-08-08-100055-behavior-definitionbdef_image2.png)



## 2. 실행 모드 및 규칙 선언


- **managed:** 개발자가 실제 복잡한 INSERT/UPDATE SQL 문을 직접 쓰지 않고, SAP 표준 RAP 엔진이 persistent table(`ZTWBS_TASK2`)에 데이터를 자동으로 저장하고 관리하도록 위임하는 방식입니다.
- **strict ( 2 ):** RAP 프레임워크의 최신 구문 규칙과 보안 표준을 엄격하게 검사하겠다는 선언입니다. 최신 버전 개발 시 필수 표준입니다.
- **with draft:** Fiori 화면에서 사용자가 데이터를 입력하다가 중간에 팅기거나 임시 저장을 누를 수 있도록 '드래프트(Draft)' 기능을 활성화합니다.
```javascript
managed implementation in class ZBP_R_TWBS_TASK2 unique;
// ZBP_R_TWBS_TASK2 에 마우스오버, Ctrl + 1 입력 > Create behavior implementation class..
strict ( 2 );
// strict,strict(2)가 있고, strict(2)의 경우, BO가 추가적인 구문검사를 해서
// 엄격한 룰에 의해 작성. 시스템 안정성 확보.
with draft;
```
## 3. 오브젝트 제어 및 동시성 관리


- **persistent table:** 최종 승인된 데이터가 실제로 저장될 물리 데이터베이스 테이블입니다.
- **draft table:** 사용자가 입력 중인 임시 데이터가 보관될 '섀도우 테이블', 물리 테이블과 똑같은 구조로 생성되어 있습니다.
- **lock master / etag master:** 여러 사용자가 동시에 동일한 데이터를 수정할 때 데이터가 꼬이는 것을 막아주는 동시성 제어(Concurrency Control) 메커니즘입니다. 최종 변경 시간(`LastChangedAt`)을 기준으로 락을 관리합니다.
```javascript
persistent table ZTWBS_TASK2

// 확장 가능 여부
extensible

// 2. 표준 규격에 맞게 자동 생성된 드래프트 테이블
// 따로 생성하지 않아도, 오류 소스에서 Ctrl + 1 누르면 자동 생성됨.
draft table ZTWBS_TASK2_D

// 3. 인스턴스 레벨의 동시성 체크(ETag) 필드 지정
// Optimistic Lock(낙관적 동시성 지정) : 수정화면 진입은 가능 Edit 후, Save 불가
etag master LastChangedAt

// 4. 서버 레벨의 동시성 체크
// Exclusive Lock(베타적 동시성 지정) : A가 수정버튼을 누른 순간 B는 진입조차 불가.
lock master

// Draft 테이블에 존재하는 필드를 이용해서, 데이터 전환시 동시성 검사 기능 활성화.
total etag LastChangedAt

//권한처리를 위한 기능을 활성화합니다.
//instance는 데이터별 권한을 점검 기능, global은 사용자별 권한을 점검 기능
authorization master( global )
```

#### LOCK 상세 내용

## 1. ETag Master vs Lock Master 개념 비교
두 기능의 핵심적인 차이점을 한눈에 파악할 수 있도록 노션(Notion)에 붙여넣기 좋은 표 형식으로 정리해 드립니다.
| **비교 항목** | **ETag Master (낙관적 동시제어)** | **Lock Master (비관적/배타적 동시제어)** |
| --- | --- | --- |
| **제어 철학** | "데이터가 동시에 수정되는 일은 **흔치 않을 것** 이다." | "데이터가 동시에 수정되어 충돌이 **무조건 날 것** 이다." |
| **잠금(Lock) 시점** | 데이터가 실제로 **저장(Save/Commit)되는 순간** | 사용자가 수정 버튼을 눌러 **화면에 진입하는 순간** |
| **구현 방식** | 데이터의 버전 관리 (Timestamp, Hash, 시스템 일시) | SAP Enqueue 서버 기반의 물리적인 리소스 잠금 장치 |
| **충돌 발생 시** | 나중에 저장을 누른 사용자에게 에러 팝업을 띄움 | 먼저 진입한 사용자가 나갈 때까지 다른 사용자는 수정 불가 |
| **시스템 부하** | DB 조회가 일어날 뿐이므로 **부하가 매우 적음** | 서버 메모리에 잠금 세션을 유지하므로 **부하가 상대적으로 큼** |
| **추천 사용 처** | 마스터 테이블, 트래픽이 낮거나 충돌 빈도가 적은 데이터 | 재고 수량 관리, 주문 처리, 동시 수정이 치명적인 핵심 트랜잭션 |
## 2. 작동 프로세스로 보는 차이점 (시나리오)
A와 B라는 두 명의 사용자가 동시에 1번 데이터(WBS 태스크)를 수정하려고 화면에 접근한 상황을 가정해 보겠습니다.
### A. ETag Master가 적용된 경우 (낙관적 제어)
1. **오후 1:00**- A와 B가 동시에 1번 데이터 상세 화면에 진입합니다. (이때 두 사람 모두 화면에서 `LastChangedAt` 타임스탬프 값이 `오후 12:00`인 것을 확인합니다.)
2. **오후 1:05**- A가 먼저 수정을 완료하고 [저장]을 누릅니다. 시스템은 DB의 타임스탬프(`12:00`)와 A가 가진 타임스탬프(`12:00`)가 일치하므로 저장을 승인하고, DB의 타임스탬프를 `1:05`로 업데이트합니다.
3. **오후 1:06**- B가 수정을 마치고 [저장]을 누릅니다. 시스템이 검사해 보니 DB의 타임스탬프는 이미 `1:05`로 바뀌었는데 B가 가져온 구 버전 타임스탬프는 `12:00`입니다.
4. **결과:** B의 저장은 거부되며 "다른 사용자에 의해 데이터가 변경되었습니다. 화면을 새로고침하십시오."라는 에러 팝업이 뜹니다.
### B. Lock Master가 적용된 경우 (비관적/배타적 제어)
1. **오후 1:00**- A가 1번 데이터의 **[수정(Edit)]** 버튼을 누릅니다. 이 순간 SAP Enqueue 서버가 1번 리소스에 대해 자물쇠를 채워버립니다 (`Lock`).
2. **오후 1:01**- B가 1번 데이터의 **[수정(Edit)]** 버튼을 누르려고 시도합니다.
3. **결과:** B는 수정 화면에 진입조차 하지 못하고 "해당 데이터는 현재 사용자 A에 의해 잠겨 있습니다."라는 경고 메시지를 보며 조회 모드로만 대기해야 합니다. A가 저장을 하거나 화면을 이탈하여 잠금이 해제되어야만 B가 수정 권한을 얻을 수 있습니다.
## 3. 요약 및 실무 적용 팁
- **RAP 프레임워크 환경에서는 보통 두 가지를 조합하여 세팅합니다.***기본적으로 사용자가 초안을 작성하고 편집하는 드래프트(Draft) 상태에서는 ** Lock Master** 가 동작하여 다른 사용자가 동일한 초안을 건드리지 못하게 처리합니다.
- 동시에 최종 액티브 테이블에 반영되거나 장기적인 동시성 충돌을 유연하게 방지하기 위해 타임스탬프 필드를 기반으로 한 **ETag Master** 설정을 상호 보완적으로 배치하는 것이 SAP RAP 아키텍처의 표준 설계 원칙입니다.



#### authorization 상세 내용

| **분류** | **global (사용자별 권한 점검)** | **instance (데이터별 권한 점검)** |
| --- | --- | --- |
| **체크 기준** | 사용자의 **ID 및 권한 세팅(Role)** 자체 | 테이블에 적힌 **실제 데이터의 값**(예: 회사 코드 `1000`) |
| **수행 시점** | 수정/생성/삭제 **화면이나 버튼이 뜰 때** | 사용자가 데이터를 선택하고 **[저장]을 누를 때** |
| **주요 대상** | `Create` (데이터를 처음 만들 권한이 있는가?) | `Update`, `Delete` (이 데이터를 수정/삭제할 권한이 있는가?) |
| **로직 <br>매개변수** | 인스턴스 데이터가 없으므로 데이터 구조를 받지 않음 | 체크 대상이 되는 레코드들의 Key와 데이터 값을 넘겨받음 |



![관련 이미지](/_images/20260808/2026-08-08-100055-behavior-definitionbdef_image3.png)


![관련 이미지](/_images/20260808/2026-08-08-100055-behavior-definitionbdef_image4.png)

## 4. 필드 속성 정리(Field Properties)


- **numbering : managed:** 개발자가 Key 값을 수동으로 따주는 로직을 짜지 않아도, 시스템이 데이터를 저장할 때 32자리 UUID(Universally Unique Identifier) 유일키를 자동으로 채번하여 입력해 줍니다.
- **readonly:** 시스템 관리 필드(생성자, 생성일시 등)는 사용자가 화면에서 직접 수정할 수 없도록 '읽기 전용'으로 잠급니다. `strict ( 2 )` 환경에서는 RAP 엔진이 이 필드들에 자동으로 세션 정보를 매핑합니다.
- **readonly : update:** 이미 만들어진 데이터를 수정(Update)하는 시점에는 변경되어서는 안 되는 기본 키(`ProgKey`)를 수정 불가능하게 막아줍니다.
```javascript
field ( numbering : managed ) ProgKey;
field ( readonly ) CreatedBy, CreatedAt, LastChangedBy, LastChangedAt;
field ( readonly : update ) ProgKey;
```
## 5. Standard Action 및 Draft Life cycle


- **create; update; delete; :** 선언하는 것만으로 Fiori Elements 화면에 <br> 신규 생성, 수정, 삭제 버튼이 표준 기능으로 즉시 활성화
- **draft action ...:** 드래프트 기능을 켰을 때 필수적으로 요구되는 프레임워크 표준 동작들입니다.
- **Activate(저장):** 임시 저장 테이블(`ZTWBS_TASK2_D`)에 있던 데이터를 검증한 뒤 실제 운영 테이블(`ZTWBS_TASK2`)로 이관(확정 저장)합니다.
- **Discard(취소/드래프트 무시):** 입력하던 임시 데이터를 다 날리고 취소합니다.
- **Edit(수정):** 기존 데이터를 고치기 위해 임시 저장 세션을 엽니다.
- **Resume(세션재개/이어쓰기):** 기존 데이터를 고치기 위해 임시 저장 세션을 엽니다.
- **Prepare(중간검증):** 저장(`Activate`) 직전에 데이터에 오류가 없는지 백엔드의 모든 Determination(자동 계산) 및 Validation(값 검증) 로직을 일괄 트리거하여 준비하는 전처리 단계<br>
```abap
create; update; delete;

//optimized가 없어도,
draft action Activate optimized;
draft action Discard;
draft action Edit;
draft action Resume;
draft determine action Prepare;
```

#### optimized를 사용하는 이유(Fiori UI 저장 클릭 시나리오)

Optimized 미사용
1단계: Prepare (값 계산 및 유효성 검사 수행 ── > 통과!)
- 2단계: Activate (저장 시작)
- 🔄 [재검증 루프] ABAP 서버가 데이터를 한 건씩 다시 꺼냄
- 1번 ~ N번 레코드: 진짜 오류 없는지 또 검사...(시간 소요)
- 3단계: 건별 이관 (ABAP 서버가 DB에 한 줄씩 INSERT 명령)
- [완료] 마스터 테이블 반영 및 드래프트 삭제
Optimized 사용
1단계: Prepare (값 계산 및 유효성 검사 수행 ── > 통과! 데이터 무결함 확정)
- 2단계: Activate optimized (최적화 저장 시작) : 이미 검증됐으므로 다시 검사하지 않음.
- 3단계: 고속 집합 이관 (HANA DB 레벨 복사)
- [드래프트 테이블] ════════════════════> [마스터 테이블]
- [완료] 마스터 테이블 반영 및 드래프트 삭제 (완료)


## 6. Non-Standard Action


- Create/Read/Update/Delete 이외에, Action을 의미하며, 대표적으로 "상태 변경"이 있음.
- Update로도 가능하지만,Validation Check등 추가 로직수행으로 리소스 낭비가 발생.
**(instance) action (가장 많이 씀): ** 스마트 테이블에서 **체크박스로 특정 행(Record)을 하나 이상 선택해야만** 상단 툴바의 버튼이 활성화되는 구조입니다. <br>(예: 3번 작업 선택 -> [승인] 클릭 -> 3번 데이터 상태 변경)
- **static action: ** 테이블에서 아무것도 선택하지 않아도 **언제나 활성화되어 있는 버튼** 입니다. (예: [전체 마감], [연도별 마이그레이션 실행] 등 시스템 전역 배치성 작업)
- **factory action: ** 기존 복잡한 데이터를 템플릿 삼아 복사 생성할 때 사용. 테이블에서 특정 행을 잡고 버튼을 누르면, 백엔드가 그 데이터를 기반으로 **새로운 Create 신규 Draft 창** 생성<br>(예: [전월 전표 복사 생성])
- **internal action: ** Fiori UI 화면에 버튼으로 절대 노출하지 않음. 백엔드 내부의 다른 Validation이나 Determination 로직 안에서 **프로그램 코드로만 호출하여 내부 모듈화용** 으로 사용

#### 6-1. 액션 생성
```abap
determination setDefaultValues on modify{ create; }
// 데이터가 저장/수정될 때(on modify) 두 필드의 값을 결정하겠다는 determination 구문을 선언
// 선언 후, ctrl + 1 입력하여 class 생성
```

![관련 이미지](/_images/20260808/2026-08-08-100055-behavior-definitionbdef_image5.png)

## 7. 데이터 매핑 (Mapping For)


- **mapping for:** ABAP 데이터베이스 테이블의 컬럼명은 전통적으로 소문자/스네이크 표기법(`PROG_KEY`)을 사용합니다. 반면, 최신 CDS 뷰나 프론트엔드 환경에서는 CamelCase(`ProgKey`)를 선언하여 사용합니다.
- 이 구문은 **백엔드 물리 테이블 컬럼명과 CDS 뷰 필드명을 1:1로 매핑** 하여 데이터가 엇갈리지 않고 정상적으로 입출력되도록 중재하는 허브 역할을 합니다.
-
```javascript
mapping for ZTWBS_TASK2 corresponding extensible
{
  -- 왼쪽(CDS 뷰 필드명) = 오른쪽(물리 DB 테이블 컬럼명)
  ProgKey = PROG_KEY;
  ProgNo = PROG_NO;
  ...
}
```
## 8. Projection View Behavior Definition
전체소스

```abap
projection implementation in class ZBP_C_TWBS_TASK2 unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZC_TWBS_TASK2 alias ZcTwbsTask2
extensible
use etag
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

}
```

#### 상세설명(기본 생성된 소스로 충분함 : Root 뷰 설정 상속)

### 1. `projection implementation in class ZBP_C_TWBS_TASK2 unique;`
- **역할:** 프로젝션 레이어 전용 행위 구현 클래스(Behavior Implementation Class)를 지정합니다.
- **상세 설명:** 본질적으로 프로젝션 뷰는 기저 레이어(`ZR_`)의 로직을 그대로 재사용(`use`)하지만, UI 소비 레이어 단계에서만 필요한 추가적인 커스텀 액션이나 기능 제어가 있을 수 있습니다. 그때 사용할 비즈니스 로직 클래스를 `ZBP_C_TWBS_TASK2`로 정의하는 것입니다. `unique` 키워드는 이 행위 정의를 구현할 클래스가 시스템 내에서 오직 이 클래스 하나뿐임을 보장합니다.
### 2. `strict ( 2 );`
- **역할:** RAP 프레임워크의 최신 문법 및 아키텍처 규칙(Strict Mode)을 강제로 적용합니다.
- **상세 설명:** 자바스크립트의 `'use strict';`나 최신 프레임워크의 버전 규격 가드레일과 유사합니다. `( 2 )`라는 숫자는 RAP Release 버전 기준 2단계의 규칙을 따르겠다는 의미입니다. 이 구문이 선언되면 컴파일러가 아주 엄격하게 구문을 검사하므로, 문법 오류나 RAP 표준 디자인 가이드에 맞지 않는 잘못된 코드가 런타임(앱 실행 시점)으로 넘어가 덤프를 내는 것을 컴파일 타임에 완벽하게 선언적으로 차단해 줍니다.
### 3. `extensible;`
- **역할:** 향후 이 프로젝션 행위 정의를 확장할 수 있도록 코드를 열어두는 선언입니다.
- **상세 설명:** SAP 표준 개발이나 규모가 큰 프로젝트에서 매우 중요한 개념입니다. 이 키워드가 붙어 있으면, 개발자가 본래의 소스 코드를 단 한 줄도 수정하지 않고도 별도의 'Extension 파일(행위 정의 확장)'을 추가로 생성하여 새로운 필드 제어나 액션을 이 위에 얹어 붙일 수(Plug-in) 있게 됩니다.
### 4. `use draft;`
- **역할: ** Fiori Elements UI의 임시 저장 기능인 **드래프트(Draft) 라이프사이클을 이 레이어에 활성화** 합니다.
- **상세 설명:** 기저 레이어(`ZR_`)에서 설계해 둔 임시 세션 버퍼 기능(`with draft`)을 최종 소비 레이어(Projection)에서도 사용하겠다고 완전히 선언하는 것입니다. 이 구문 덕분에 Fiori 화면에서 사용자가 값을 입력할 때마다 백엔드 드래프트 테이블에 데이터가 실시간으로 자동 임시 저장되며, 네트워크가 끊기거나 창을 닫아도 임시 저장된 초안 데이터가 유실되지 않고 유지됩니다.
### 5. `use side effects;`
- **역할: ** 웹 화면의 **실시간 UI 데이터 동기화 기능(Side Effects)을 활성화** 합니다.
- **상세 설명:** 웹 개발 시 특정 입력란의 값이 바뀔 때 다른 필드의 값을 서버에서 다시 계산해 와서 화면을 부분 갱신(Partial Refresh)해야 하는 경우가 있습니다. (예: '수량'을 바꾸면 화면의 '총 금액'이 실시간으로 변하는 기능) 이 구문을 선언하면 백엔드에서 특정 데이터가 변경되었을 때, Fiori UI 레이어에게 "관련된 이 필드들의 값도 바뀌었으니 화면을 다시 랜더링하라"고 브라우저에 비동기 웹 통신 신호를 알아서 보내주게 됩니다.
