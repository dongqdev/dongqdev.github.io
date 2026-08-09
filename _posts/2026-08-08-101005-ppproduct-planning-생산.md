---
title: "PP(Product Planning-생산)"
date: 2026-08-08 05:22:32 +0900
categories: ["SAP-모듈"]
tags: ["SAP", "PP"]
---

## 개요
PP(Product Planning, 생산)는 제품을 언제, 얼마나, 어떻게 만들지 계획하고 실행을 추적하는 생산관리 모듈입니다.

## 주요 업무
- 자재소요계획(MRP) — 필요한 자재를 언제 얼마나 확보해야 하는지 계산
- BOM(자재명세서)/라우팅(작업순서) 관리
- 생산오더(Production Order) 생성 및 실행
- 재공품/완제품 확인(Confirmation)

## 핵심 용어
- **BOM(Bill of Material, 자재명세서)**: 제품 하나를 만들기 위해 필요한 구성품 목록
- **Routing(라우팅)**: 제품을 만드는 작업 순서와 각 공정에서 쓰는 작업장(Work Center)
- **Production Order(생산오더)**: "이 제품을 이만큼 만들어라"라는 실행 지시 문서
- **MRP(자재소요계획)**: 수요 대비 재고/발주를 자동으로 맞춰주는 계획 로직

## 개발자 참고
- 주요 테이블: `MAST`(자재-BOM 연결), `AFKO`/`AFPO`(생산오더 헤더/항목)
- 관련 트랜잭션: `CS01`(BOM 생성), `CO01`(생산오더 생성), `MD04`(재고/소요 현황 조회)
- 앞서 정리한 SAP 표준 CDS 뷰 접미사(`I_PRODNROUTINGOPSUBORDOPDEX` 등)가 다루는 대부분의 영역이 바로 이 PP입니다 — 라우팅/공정(Operation) 관련 표준 뷰가 특히 많습니다.
