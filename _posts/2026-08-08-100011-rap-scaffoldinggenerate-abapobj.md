---
title: "RAP Scaffolding(Generate AbapObj)"
date: 2026-08-08 05:13:32 +0900
categories: ["DEV", "SAP-RAP"]
tags: ["SAP", "RAP"]
---

# RAP Scaffolding(Generate AbapObj)
- 새로운 서비스를 만들 때 **물리 테이블을 먼저 생성한 뒤, **`OData UI 서비스`** 마법사로 껍데기들을 자동 생성하는 것** 이 실무에서 가장 빠르고 휴먼 에러가 없는 정석 루트입니다.

## 📅 STEP 1. 물리 데이터베이스 테이블 직접 생성 (`TABL`)

1. 최상위 패키지(`ZDEV_LDG`) 우클릭 ➡️ `New` ➡️ `ABAP Package`로 **도메인 서브 패키지(예:**`ZLUNCH_MANAGEMENT`**)를 먼저 생성** 합니다.
2. 생성한 서브 패키지 우클릭 ➡️ `New` ➡️ `Database Table` 클릭
3. 테이블 이름(예: `ZTLUNCH_STATS`)을 입력하고 아래 표준 스펙 코드를 복사·붙여넣기 한 후 **`Ctrl + F3`**(Activate)** 합니다.

```javascript
@EndUserText.label : '점심 메뉴 통계 테이블'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztlunch_stats {

  key client      : abap.clnt not null;
  key stats_uuid  : sysuuid_x16 not null; // 🌟 단일 자동생성 마스터 ID (OData V4 필수 사양)
  eat_month       : abap.char(6) not null; // 일반 데이터 필드들...
  restaurant_name : abap.char(100);
  menu_name       : abap.char(50);
  order_count     : abap.int4;
  @Semantics.amount.currencyCode : 'ztlunch_stats.currency'
  total_spent     : abap.curr(13,2);
  currency        : abap.cuky;

  // 🏢 엔터프라이즈 표준 공통 스탬프 (제너레이터가 자동으로 매핑해 줌)
  created_by      : abp_creation_user;
  created_at      : abp_creation_tstmpl;
  last_changed_by : abp_lastchange_user;
  last_changed_at : abp_lastchange_tstmpl;

}
```

## ⚡ STEP 2. RAP Generator (`OData UI 서비스`)

### 1. Run Generator
- 방금 만든 서브 패키지 폴더 우클릭 ➡️ `New` ➡️ `Other...` 클릭
- **`Generate ABAP Repository Objects`** 검색 후 더블클릭
- ⚠️[중요] 반드시 **`OData UI 서비스`**(밑에서 2번째)를 선택하고 `Next`

### 2. 1단계: General (기본 정보 설정)
- **`Referenced Object`**: ** STEP 1에서 만든 물리 테이블명 입력 (예: `ZTLUNCH_STATS`)
- **`Project Name`**: ** 외부 노출용 API 명칭 입력 (뒤에 화면용임을 뜻하는 `_UI` 명시) ➡️ 예: `ZRE_LUNCH_STATS_UI`
- **`Artifacts Prefix`**: ** 뒤에서 네이밍이 꼬이는 것을 방지하기 위해**`비워둠(Blank)`** 또는 **`Z`** 를 제외한 특정 접두사** 입력 권장.

### 3. 2단계: Data Model & Behavior (Core 레이어 네이밍 교정)
- 메뉴 트리에서 `Data Model`, `Behavior`를 순서대로 클릭하며 우측 입력창의 **`ZZ_`** 나 **`ZZP_`** 로 중복 꼬인 접두사들을 싹 지우고 **표준 이름으로 교정**.
- **`CDS Entity Name`**: `ZR_LUNCH_STATS` (5단계 원장 뷰)
- **`Implementation Class`**: `ZBP_R_LUNCH_STATS` (원장 서비스 로직 클래스)

### 4. 3단계: Service Projection (화면 DTO 레이어 네이밍 교정)
- 메뉴 트리에서 `Service Projection`을 클릭
- **`Projection Entity Name`**: `ZP_LUNCH_STATS` (6단계 화면용 뷰) 또는 표준 규칙에 따라 `ZC_LUNCH_STATS`로 명명 조치

### 5. 4단계: 마무리 및 발행
- 모든 세팅이 끝나면 `Next`를 눌러 에러가 없는지 확인하고 `Finish`를 클릭

## 🔥 STEP 3. 전체 컴파일 및 Fiori Preview 확인
1. 마법사가 종료되면 패키지 폴더에 파일 12개가 들어와 있습니다.
2. 서브 패키지 폴더 자체를 마우스 우클릭 ➡️**`Change Activation (Ctrl + Shift + F3)`** 클릭
3. 생성된 12개 파일의 체크박스를 전부 켜고 **한 방에 전체 Activate** 를 진행
4. 최상단 비즈니스 서비스 계층에 있는 **`Service Binding`** 파일 **을 `open`
5. 엔티티 명을 우클릭하고 **`Preview`** 버튼을 누르면, **OData V4 Draft 임시저장 기능이 확인**되고 **`[생성(Create)]`** 과 **`[삭제(Delete)]`** 확인 가능