---
title: "ComboBox/Abstract View"
date: 2026-08-08 05:16:52 +0900
categories: ["SAP-WIKI"]
tags: ["SAP", "개발WIKI"]
---

## 1. 공통 더미 테이블 생성 (`ZWBS_DUMMY`)
>
- Dual 같은 가상테이블이 없어서, 더비테이블 생성 후, SELECT
- New > DataBase Table (Z???_DUMMY)
```abap
@EndUserText.label : '공통 Dual 더미 테이블'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zwbs_dummy {

  key client : abap.clnt not null;
  key dummy  : abap.char(1) not null;

}
```
## 2. **새로 만든 더미 테이블로 Y/N 가상 뷰 완성하기**
>
- New > Data Definition(ZC_TWBS_YN_VIRTUAL)
```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '운영배포 여부 가상 마스터'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS 

/* 💡 [글로벌 표준 안착] 직접 만든 zwbs_dummy를 소스로 지정합니다.
     where 조건절 없이도 'Y' 1줄, 'N' 1줄이 중복 없이 완벽하게 생성됩니다.
*/
define view entity ZC_TWBS_YN_VIRTUAL
  as select from zwbs_dummy
{
  @EndUserText.label: '코드'
  @ObjectModel.text.element: ['YnName']
  key 'Y' as YnCode,
  
  @EndUserText.label: '코드명'
  cast( '예' as abap.char(3) ) as YnName
}

union all

select from zwbs_dummy
{
  key 'N' as YnCode,
  cast( '아니오' as abap.char(3) ) as YnName
}
```
## 3. 동작 방식 및 데이터 Insert
>
- **동작 방식:** 데이터베이스 엔진은 상수를 화면에 그리기 전에, 먼저 `FROM ZWBS_DUMMY` 구절을 보고 해당 테이블의 레코드 저장소로 찾아갑니다.
- **테이블이 비어있다면 (0건):** `ZWBS_DUMMY`에 행이 하나도 없으면, 엔진은 "조회 결과가 0건이네"라고 판단하고 그 시점에서 쿼리 실행을 종료합니다. 셀렉트된 행 자체가 없으니 앞에 적어둔 `'Y'`나 `'예'`라는 가상 값을 얹어줄 대상(레코드 공간)이 아예 존재하지 않게 되는 것입니다.
- **테이블에 1줄이 있다면 (1건):** 데이터가 단 1줄이라도 들어있으면, 엔진은 "행을 1개 찾았다"라고 인지하고 그 찾아낸 행의 원래 알맹이(예: 'X')를 우리가 하드코딩한 `'Y'`와 `'예'`로 완전히 덮어씌워서 1줄의 결과물을 생산해 냅니다.
```abap
CLASS zcl_wbs_dummy_initializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " ADT 콘솔에서 F9로 즉시 단독 실행이 가능하도록 표준 인터페이스를 구현합니다.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_wbs_dummy_initializer IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: ls_dummy TYPE zwbs_dummy.

    " 1. 이물질 방지를 위해 기존 더미 테이블을 깔끔하게 한 번 밀어줍니다.
    DELETE FROM zwbs_dummy.

    " 2. 행 1건을 세팅합니다.
    ls_dummy-client = sy-mandt. " 현재 로그인한 SAP 시스템 클라이언트 번호 자동 매핑
    ls_dummy-dummy  = 'X'.      " 오라클 DUAL 테이블의 표준 값 'X' 주입

    " 3. 데이터베이스에 최종 인서트
    INSERT zwbs_dummy FROM @ls_dummy.

    IF sy-subrc = 0.
      out->write( '==================================================' ).
      out->write( '글로벌 공통 DUAL 테이블(ZWBS_DUMMY) 초기화 완료!' ).
      out->write( '==================================================' ).
    ELSE.
      out->write( '더미 데이터 인서트 중 에러가 발생했습니다.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
```
## 4. 테이블 내 데이터를 이용해서, 콤보박스 적용
```abap
...
@Consumption.valueHelpDefinition: [{
  entity: { name: 'ZC_TWBS_YN_VIRTUAL', element: 'YnCode' },
  label: '완료여부'
}]
// 기본값 지정
@UI.defaultValue: '"N"'
CompleteYn;
```
