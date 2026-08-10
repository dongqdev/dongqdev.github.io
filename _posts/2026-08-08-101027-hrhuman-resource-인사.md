---
title: "HR(Human Resource-인사)"
date: 2026-08-08 05:22:52 +0900
categories: ["DEV", "SAP-모듈"]
tags: ["SAP", "HR"]
---

## 개요
HR(Human Resource, 인사, SAP 내부에서는 HCM이라고도 부릅니다)은 인사정보, 조직관리, 급여, 근태 등 "사람"과 관련된 업무 전체를 다루는 모듈입니다.

## 주요 업무
- 인사정보관리(Personnel Administration) — 입사/퇴사, 개인정보 관리
- 조직관리(Organizational Management) — 조직도, 직위, 보고체계
- 급여계산(Payroll)
- 근태관리(Time Management)
- 채용(Recruiting)

## 핵심 용어
- **Personnel Number(사번, PERNR)**: 직원 한 명을 식별하는 고유 번호
- **Infotype(인포타입)**: 인사정보를 담는 데이터 구조 단위 (예: 개인정보는 0002번 Infotype)
- **Organizational Unit(조직단위)**: 부서/팀 같은 조직 구조의 노드
- **Position(직위)**: 조직 안에서 사람이 채워지는 자리(포지션) 단위

## 개발자 참고
- 주요 테이블: `PA0001`(조직배치 Infotype), `PA0002`(개인정보 Infotype)
- 관련 트랜잭션: `PA20`(인사정보 조회), `PA30`(인사정보 유지보수), `PPOME`(조직관리)
- HR 데이터는 개인정보 보호 이슈가 커서, CDS/RAP 개발 시 **권한(Authorization) 설계**를 특히 꼼꼼히 해야 합니다 — 다른 모듈보다 접근 통제 요구사항이 까다로운 편입니다.
