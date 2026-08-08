---
title: "QM(Quality Management-품질)"
date: 2026-08-08 05:22:42 +0900
categories: ["SAP-모듈"]
tags: ["SAP", "QM"]
---

## 개요
QM(Quality Management, 품질)은 원자재 입고부터 완제품 출하까지 품질을 검사하고 문제를 관리하는 모듈입니다. MM(입고 검사)·PP(생산 중 검사)와 밀접하게 연동됩니다.

## 주요 업무
- 검사로트(Inspection Lot) 생성 및 처리
- 품질통지(Quality Notification) — 불량/문제 접수
- 검사계획(Inspection Plan) 관리
- 사용결정(Usage Decision) — 합격/불합격 최종 판정

## 핵심 용어
-**Inspection Lot(검사로트)**: 검사 대상이 되는 수량 단위 (예: 이번에 입고된 자재 100개)
-**Usage Decision(사용결정)**: 검사로트를 합격/불합격 처리하는 최종 판정 액션
-**Quality Notification(품질통지)**: 불량이나 클레임이 발생했을 때 등록하는 문서
-**Inspection Plan(검사계획)**: 무엇을, 어떻게 검사할지 정의한 기준

## 개발자 참고
- 주요 테이블: `QALS`(검사로트), `QMEL`(품질통지)
- 관련 트랜잭션: `QA01`(검사로트 생성), `QA11`(사용결정 입력), `QM01`(품질통지 생성)
- MM에서 자재 입고(Goods Receipt) 시 자재마스터에 검사유형이 설정돼 있으면 QM 검사로트가 자동 생성되는 구조입니다 — MM↔QM 연동 로직을 개발할 때 꼭 알아둘 포인트입니다.
