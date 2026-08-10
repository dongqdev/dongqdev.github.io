---
title: "SD(Sales & Distribution-영업/수송)"
date: 2026-08-08 05:22:12 +0900
categories: ["DEV", "SAP-모듈"]
tags: ["SAP", "SD"]
---

## 개요
SD(Sales & Distribution, 영업/수송)는 견적부터 수주, 출하, 청구(인보이스)까지 판매 프로세스 전체를 관리하는 모듈입니다. 흔히 말하는 **"Order to Cash"**(수주부터 대금회수까지) 프로세스의 핵심입니다.

## 주요 업무
- 견적(Quotation)/수주(Sales Order) 입력
- 출하(Delivery) 처리 — 창고에서 물건을 내보내는 단계
- 청구서(Billing Document) 발행
- 가격결정(Pricing) — 할인, 세금 등 반영
- 신용관리(Credit Management) — 고객 신용한도 체크

## 핵심 용어
- **Sales Order(수주)**: 고객의 주문을 등록한 문서 (헤더 VBAK / 항목 VBAP)
- **Delivery(출하)**: 실제 물류 처리 문서 (헤더 LIKP / 항목 LIPS)
- **Billing Document(청구서)**: 고객에게 발행하는 인보이스 (헤더 VBRK / 항목 VBRP)
- **Condition Type(가격조건유형)**: 가격/할인/세금이 어떻게 계산되는지 정의하는 규칙

## 개발자 참고
- 주요 테이블: `VBAK`/`VBAP`(수주), `LIKP`/`LIPS`(출하), `VBRK`/`VBRP`(청구)
- 표준 CDS 뷰: `I_SalesOrder`, `I_SalesOrderItem`
- 관련 트랜잭션: `VA01`(수주 생성), `VL01N`(출하 생성), `VF01`(청구서 생성)
- RAP 커스텀 앱(예: 주문 현황 대시보드)에서 표준 SD CDS 뷰를 Association으로 참조하는 경우가 아주 많아서, 위 4개 테이블 관계는 꼭 알아두면 좋습니다.
