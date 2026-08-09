---
title: "Metadata Extention(MDE)"
date: 2026-08-08 05:14:02 +0900
categories: ["SAP-RAP"]
tags: ["SAP", "RAP"]
image:
  path: /_images/20260808/2026-08-08-100044-metadata-extentionmde_image1.png
---



- **활성화 조건: ** MDE를 적용할 대상 프로젝션 뷰(`ZP_...` 또는 `ZC_...`) 상단에**`@Metadata.allowExtensions: true`** 어노테이션이 선언 필수
- **소스코드 분리 (Clean Code):** CDS 뷰 안에 `@UI.lineItem`, `@UI.facet` 같은 화면 제어 코드가 수백 줄씩 섞이면 백엔드 쿼리를 알아보기 힘들어집니다. 이를 UI 전용 파일로 격리시켜 CDS 뷰를 깔끔하게 유지
- **영역별 협업 최적화:** 백엔드 개발자가 CDS 뷰 데이터 구조를 바꾸지 않아도, UI 담당자나 프론트엔드 개발자가 MDE 파일만 수정하여 화면 레이아웃(필터바 순서, 테이블 컬럼명 등)을 자유롭게 변경할 수 있습니다.
## 1. 상단 Annotation
### @Metadata.layer
```javascript
@Metadata.layer: #CUSTOMER
-- [필수 어노테이션] 이 UI 설정이 적용되는 개발 레이어(계층)를 정의합니
```
| **옵션값** | **의미 및 설명 (우선순위 순서)** |
| --- | --- |
| **`#CORE`** | **최하위 레이어.** SAP가 표준 스탠다드 뷰를 만들 때 내장하는 기본 UI 설정 계층입니다. |
| **`#LOCALIZATION`** | **국가별 로컬라이제이션 계층.** 국가별 법적 규제나 언어적 특성에 맞춘 UI 설정을 입힐 때 사용합니다. |
| **`#INDUSTRY`** | **산업군별 계층.** 리테일, 제조, 화학 등 특정 산업군 전용 솔루션 UI를 구성할 때 사용합니다. |
| **`#PARTNER`** | **파트너사 개발 계층.** SAP 툴을 커스텀하여 납품하는 협력사/파트너사 아키텍처용 레이어입니다. |
| **`#CUSTOMER`** | **최상위 레이어 (실무 표준). ** 실제 프로젝트를 진행하는 **고객사 개발자(나)가 커스텀할 때 사용하는 계층** 입니다. 표준이나 파트너사 설정을 무시하고 내가 셋팅한 UI가 화면에 1순위로 최종 반영됩니다. |
### @UI.headerInfo.\[속성\]
```javascript
@UI.headerInfo: {

  -- 이미지는 여기에 URL 필드명을 바인딩합니다.
  typeImageUrl: 'FixedImageUrl',

  -- 메인 타이틀 (텍스트 대제목)
  title: { type: #STANDARD, value: 'ProgName' },

  -- 서브 타이틀 (부제목 설명)
  description: { type: #STANDARD, value: 'ProgKey' }
}
```
## 2. Projection View 메타데이터 설정
```javascript
annotate view ZP_LDG_FLIGHT with {
-- [대상 지정] ZP_LDG_FLIGHT 라는 프로젝션 뷰의 필드들을 꾸미겠다고 시스템에 선언합니다.

  -------------------------------------------------------------------------------------
  -- 본문 안에는 CDS 문법(key, as 등) 없이 오직 필드명과 UI 어노테이션만 작성합니다.
  -------------------------------------------------------------------------------------

@UI.facet: [
-------------------------------------------------------------------------------------
  -- [Step 0] 최상위 메인 탭(Section) 정의
-------------------------------------------------------------------------------------
{
    id: 'Main',
    type: #IDENTIFICATION_REFERENCE,
    // 컬럼에 아래와 같이 명시만 해도 상세 페이지 생성 됨.
    //@UI.identification: [ { position: 10, label: '프로젝트 키' } ]
    label: 'Main',
    position: 10
},
  -------------------------------------------------------------------------------------
  -- [Step 1] 최상위 메인 탭(Section) 정의
  -------------------------------------------------------------------------------------
  {
    id:              'ProgramSection',       -- 이 섹션의 고유 식별 ID (내부 매핑용)
    type:            #COLLECTION,            -- 레이아웃 양식: 여러 그룹을 담는 큰 방으로 설정
    label:           '프로그램 정보',             -- 최종 사용자의 화면 탭에 나타날 한글/영문 타이틀
    position:        10                      -- 탭이 배치될 순서 (10번이므로 맨 첫 번째 탭)
  },

  -------------------------------------------------------------------------------------
  -- [Step 2] 위에서 만든 메인 탭 내부의 세부 필드 그룹 구역(Group) 정의
  -------------------------------------------------------------------------------------
  {
    id:              'ProgramInfo',     -- 이 세부 구역의 고유 식별 ID
    type:            #FIELDGROUP_REFERENCE,  -- 레이아웃 양식: 필드 그룹을 참조하여 그리겠다고 선언
    label:           '프로그램 상세',         -- 세부 구역 박스 상단에 들어갈 소제목
    parentId:        'ProgramSection',       -- [중요] Step 1에서 만든 큰 방의 'id'를 적어 상속시킴
    targetQualifier: 'ProgramlInfoFields',    -- [중요] 실제 필드들에 적어줄 fieldGroup의 qualifier 이름과 일치시킴
    //@UI.fieldGroup: [{ qualifier: 'ProjectDates', position: 10, label: '시작일자' }]
    position:        10                      -- 섹션 내부에서 배치될 순서
  }
]
  -- 상세 페이지(Object Page)의 전체적인 방 구조(Section, Field Group)를 설계합니다.

  @UI.selectionField: [{ position: 10 }]
  -- 해당 필드를 Fiori 화면 상단 검색 필터바에 배치합니다.

  @UI.lineItem: [{ position: 10, label: '항공사 ID' }]
  -- 해당 필드를 Fiori 화면 중앙 그리드 테이블의 컬럼으로 배치합니다.

  @UI.identification: [{ position: 10 }]
  -- 상세 페이지 내부의 기본 정보 탭 안에 값을 바인딩합니다.
  -- type: #IDENTIFICATION_REFERENCE 인 그룹으로 자동으로 매칭

  @UI.fieldGroup: [
  { qualifier: 'BasicInfoFields', position: 10, label: '프로그램 번호' },
  { qualifier: 'ProgramlInfoFields', position: 10, label: '프로그램 번호',hidden:true }
  ]
  -- BasicInfoFields 그룹에는 표출되고, ProgramlInfoFields에서는 숨기기
}
```
![관련 이미지](/_images/20260808/2026-08-08-100044-metadata-extentionmde_image1.png)
<empty-block/>
## ※ 기타
### 프로그래스바
```javascript
  -------------------------------------------------------------------------------------
  -- 1. 수치형 Progress 필드: DataPoint(막대바) 설정 주입
  -------------------------------------------------------------------------------------
  @UI.dataPoint: {
      title: '진행률',
      targetValue: 100,                  -- 최댓값 마커(HTML max="100") 역할
      visualization: #PROGRESS           -- 막대 차트 컴포넌트로 렌더링 지시
  }
  @EndUserText.label: '진행률(Bar)'
  @UI.lineItem: [ { position: 190, type: #AS_DATAPOINT } ] -- 스마트 테이블에 막대형으로 출력
  @UI.fieldGroup: [{ qualifier: 'BasicInfoFields', position: 40, type: #AS_DATAPOINT }] -- '상세 내역 명세'에 배치
  Progress;

  -------------------------------------------------------------------------------------
  -- 2. 문자열 ProgressString 필드: 텍스트 보조용으로 유지 (선택 사항)
  -------------------------------------------------------------------------------------
  @EndUserText.label: '진행률(텍스트)'
  @UI.fieldGroup: [{ qualifier: 'TechInfoFields', position: 90 }] -- 기술 정보 탭 백업용 [cite: 24]
  ProgressString;
```
