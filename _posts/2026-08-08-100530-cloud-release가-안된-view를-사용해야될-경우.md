---
title: "Cloud Release가 안된 View를 사용해야될 경우"
date: 2026-08-08 05:18:22 +0900
categories: ["SAP-WIKI"]
tags: ["SAP", "개발WIKI"]
image:
  path: /_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image1.png
---

(주)**> Z** HFB0011 참고

## 1. 사용자 정의 CDS 뷰 생성


- 레이블을 입력하면 이름이 자동으로 입력 됨.
- 외부 API로 생성

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image1.png)



경고창이 뜨는 경우, 무시하고 진행해도 됨.

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image2.png)

### 2. 요소 추가
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image3.png)

### 3. 사용자 정의 통신 시나리오 생성


-**네이밍 패턴:**`YY1_[비즈니스영역]_[목적]`
-**시나리오 ID**: PRODN_ROUTING_API (Communication Scenario)
-**내역**: 제품 라우팅 API 시나리오

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image4.png)



1. 인바운드 서비스 등록 
2. 검색 > 사용자 정의 CDS뷰 이름(**ZI_ProdnRoutingOpSubor)** 입력
3. 저장 > 게시
※ 게 후, [규약생성] 가능

### 사용자 정의 CDS뷰 검색하면, 앞서 정한 레이블에 접두가 YY1이 붙은 형태로 나옴
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image5.png)

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image6.png)
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image7.png)

### 4. 규약생성
규약생성을 누르면 자동으로 입력 됨.

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image8.png)



1. 통신 시스템 > [신규]
2. 정보입력
	1. **시스템 ID:**`YY1_[상대시스템명]_[비즈니스영역]` 또는 `Z_[상대시스템명]_[목적]`
	2. **시스템 이름:**(시스템 ID와 동일하게 입력하여 식별성 유지)
	3. Z_CLD_EXT_BYPASS_API : 클라우드 외부 API 라는 의미로 생성

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image9.png)



1. 일반 > 호스트 이름 : 현재 URL(myXXXXXX.s4hana.cloud.sap)

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image10.png)



1. 인바운드 통신 사용자 등록
2. [신규 사용자] 등록

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image11.png)



1. 정보입력 후, 생성 (비밀번호 최소 길이: 20자) - ZEXT_BYPASS_USERitm0526!@

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image12.png)



1. 확인

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image13.png)



1. 신규 아웃바운드 사용자 등록 (인바운드 사용자와 동일하게) 후, 저

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image14.png)

### 5. 통신규약 복귀 후, 앞서 등록한 통신시스템 및 사용자 등록


1. 등록 후, 서비스 URL/서비스 인터페이스 [복사]
2. WSDL/서비스 메타데이터 ]다운로드[

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image15.png)

### 6. 사용자 정의 통신 시나리오 > 아웃바운드 서비스 등록


1. 편집 > 추가
2. 통신규약 인바운드 서비스와 동일한 이름/URL 로 지정
3. 저장 후, 게시

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image16.png)
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image17.png)

### 7. 통신규약 설정


1. 아웃바운드 통신 사용자 선택
2. 아웃바운드 서비스 활성화

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image18.png)

### 7. Service Consumption Model (SRVC) 생성


1. **New > Business Services > Service Consumption Model** 을 생성합니다.
2. **Remote Consumption Mode**: OData

![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image19.png)

### 8. 다운로드 받은 xml 임포트 후 [Next]
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image20.png)

### 9. 확인 
![관련 이미지](/_images/20260808/2026-08-08-100530-cloud-release가-안된-view를-사용해야될-경우_image21.png)

### 10. Custom Entity 생성
```javascript
@EndUserText.label: '공정 하위 작업 외부 API 매핑 엔티티'
@ObjectModel.query.implementedBy: 'ZCL_PRODN_ROUTING_PROVIDER'
define custom entity ZI_PRODNROUTINGOPSUBORD
{
  key BillOfOperationsType : abap.char(1);
  key ProductionRoutingGroup : abap.char(8);
  key ProductionRoutingOpIntID : abap.char(8);
  key ProductionRoutingOpIntVersion : abap.char(8);
  Operation : abap.char(4);
  Plant : abap.char(4);
}
```
### 11. Class 생성 
ZCL_PRODN_ROUTING_PROVIDER 이름으로 CLASS 생성

```javascript
CLASS zcl_prodn_routing_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES tt_result TYPE STANDARD TABLE OF zi_prodnroutingopsubord WITH EMPTY KEY.

    CLASS-METHODS get_data
      IMPORTING
        io_filter      TYPE REF TO if_rap_query_filter OPTIONAL
        iv_top         TYPE int8 OPTIONAL
        iv_skip        TYPE int8 OPTIONAL
      RETURNING
        VALUE(rt_data) TYPE tt_result.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_prodn_routing_provider IMPLEMENTATION.

  METHOD get_data.
    DATA: lo_http_client  TYPE REF TO if_web_http_client,
          lo_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request      TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response     TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA lt_business_data TYPE TABLE OF zsc_prodn_routing_subor=>tys_yy_1_zi_prodn_routing_op_2.

    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
          comm_scenario = 'YY1_ZCS_PRODN_ROUTING'
        ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
            is_proxy_model_key       = VALUE #(
              repository_id       = 'DEFAULT'
              proxy_model_id      = 'ZSC_PRODN_ROUTING_SUBOR'
              proxy_model_version = '0001' )
            io_http_client         = lo_http_client
            iv_relative_service_root = '' ).

        lo_request = lo_client_proxy->create_resource_for_entity_set( 'YY_1_ZI_PRODN_ROUTING_OP_S' )->create_request_for_read( ).

        IF io_filter IS BOUND.
          DATA(lt_all_filters) = io_filter->get_as_ranges( ).
          DATA(lo_filter_factory) = lo_request->create_filter_factory( ).
          DATA lo_root_node TYPE REF TO /iwbep/if_cp_filter_node.

          LOOP AT lt_all_filters INTO DATA(ls_filter).
            DATA lv_property_path TYPE string.
            CLEAR lv_property_path.

            CASE to_upper( ls_filter-name ).
              WHEN 'BILLOFOPERATIONSTYPE'.
                lv_property_path = 'BILL_OF_OPERATIONS_TYPE'.
              WHEN 'PRODUCTIONROUTINGGROUP'.
                lv_property_path = 'PRODUCTION_ROUTING_GROUP'.
              WHEN 'PRODUCTIONROUTINGOPINTID'.
                lv_property_path = 'PRODUCTION_ROUTING_OP_INT_ID'.
              WHEN 'PRODUCTIONROUTINGOPINTVERSION'.
                lv_property_path = 'PRODUCTION_ROUTING_OP_INT_VERSION'.
              WHEN 'OPERATION'.
                lv_property_path = 'OPERATION'.
              WHEN 'PLANT'.
                lv_property_path = 'PLANT'.
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.

            DATA(lo_node) = lo_filter_factory->create_by_range(
              iv_property_path = lv_property_path
              it_range         = ls_filter-range ).

            IF lo_root_node IS NOT BOUND.
              lo_root_node = lo_node.
            ELSE.
              lo_root_node = lo_root_node->and( lo_node ).
            ENDIF.
          ENDLOOP.

          IF lo_root_node IS BOUND.
            lo_request->set_filter( lo_root_node ).
          ENDIF.
        ENDIF.

        IF iv_top > 0.
          lo_request->set_top( CONV i( iv_top ) ).
        ENDIF.

        IF iv_skip > 0.
          lo_request->set_skip( CONV i( iv_skip ) ).
        ENDIF.

        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).

        LOOP AT lt_business_data INTO DATA(ls_business).
          DATA lv_op_int_id TYPE string.
          DATA lv_op_int_ver TYPE string.
          FIELD-SYMBOLS <lv_any> TYPE any.

          ASSIGN COMPONENT 'PRODUCTION_ROUTING_OP_INT_ID' OF STRUCTURE ls_business TO <lv_any>.
          IF sy-subrc = 0.
            lv_op_int_id = <lv_any>.
          ELSE.
            ASSIGN COMPONENT 'PRODUCTION_ROUTING_OP_INT' OF STRUCTURE ls_business TO <lv_any>.
            IF sy-subrc = 0.
              lv_op_int_id = <lv_any>.
            ENDIF.
          ENDIF.

          ASSIGN COMPONENT 'PRODUCTION_ROUTING_OP_INT_VERSION' OF STRUCTURE ls_business TO <lv_any>.
          IF sy-subrc = 0.
            lv_op_int_ver = <lv_any>.
          ELSE.
            ASSIGN COMPONENT 'PRODUCTION_ROUTING_OP_IN_2' OF STRUCTURE ls_business TO <lv_any>.
            IF sy-subrc = 0.
              lv_op_int_ver = <lv_any>.
            ENDIF.
          ENDIF.

          APPEND VALUE #(
            billofoperationstype          = ls_business-bill_of_operations_type
            productionroutinggroup        = ls_business-production_routing_group
            productionroutingopintid      = lv_op_int_id
            productionroutingopintversion = lv_op_int_ver
            operation                     = ls_business-operation
            plant                         = ls_business-plant ) TO rt_data.
        ENDLOOP.

      CATCH /iwbep/cx_cp_remote.
        CLEAR rt_data.
      CATCH /iwbep/cx_gateway.
        CLEAR rt_data.
      CATCH cx_web_http_client_error.
        CLEAR rt_data.
      CATCH cx_root.
        CLEAR rt_data.
    ENDTRY.
  ENDMETHOD.

  METHOD if_rap_query_provider~select.
    DATA lv_top  TYPE int8.
    DATA lv_skip TYPE int8.

    DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      IF lo_paging->get_page_size( ) <> if_rap_query_paging=>page_size_unlimited.
        lv_top = lo_paging->get_page_size( ).
      ENDIF.
      IF lo_paging->get_offset( ) > 0.
        lv_skip = lo_paging->get_offset( ).
      ENDIF.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter( ).
    DATA(lt_result) = get_data(
      io_filter = lo_filter
      iv_top    = lv_top
      iv_skip   = lv_skip ).

    IF io_request->is_total_numb_of_rec_requested( ).
      DATA(lt_count_result) = get_data( io_filter = lo_filter ).
      io_response->set_total_number_of_records( lines( lt_count_result ) ).
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
```
