---
title: "MM(Material Management-구매/자재관리)"
date: 2026-08-08 05:22:22 +0900
categories: ["SAP-모듈"]
tags: ["SAP", "MM"]
---

## 개요
MM(Material Management, 구매/자재관리)은 자재를 사고, 받고, 재고로 관리하는 모듈입니다. **"Procure to Pay"**(구매부터 대금지급까지) 프로세스의 핵심입니다.

## 주요 업무
- 구매요청(Purchase Requisition)/발주(Purchase Order) 처리
- 입고(Goods Receipt) 처리
- 재고관리(Inventory Management) — 재고 이동, 실사
- 송장검증(Invoice Verification) — 받은 물건과 청구서가 맞는지 확인

## 핵심 용어
- **Material Master(자재마스터)**: 자재의 모든 속성(단위, 가격, 플랜트별 정보 등)을 담은 기준정보
- **Purchase Order(발주)**: 공급업체에 보내는 정식 주문 문서 (헤더 EKKO / 항목 EKPO)
- **Plant(플랜트)**: 생산·재고를 관리하는 물리적/조직적 단위 (공장, 물류센터 등)
- **Storage Location(저장위치)**: 플랜트 안에서 재고를 더 세분화한 위치

## 개발자 참고
- 주요 테이블: `MARA`(자재마스터 일반), `EKKO`/`EKPO`(발주), `MSEG`(자재이동내역)
- 표준 CDS 뷰: `I_PurchaseOrder`, `I_Product`
- 관련 트랜잭션: `ME21N`(발주 생성), `MIGO`(입고 처리), `MB52`(재고현황 조회)
- RAP 개발에서 재고/자재 조회 기능을 만들 때 가장 자주 참조하게 되는 영역입니다 — `MARA` 계열 테이블이 워낙 넓게 퍼져있어서(MARC, MBEW 등) 필요한 필드가 어느 서브 테이블에 있는지 파악하는 게 관건입니다.
