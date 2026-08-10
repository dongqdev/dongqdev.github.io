---
title: "Join vs Association 정리"
date: 2026-08-08 05:16:22 +0900
categories: ["DEV", "SAP-WIKI"]
tags: ["SAP", "개발WIKI"]
---

## 1. RAP의 데이터 결합 방식 개요
SAP RAP(RESTful ABAP Programming Model)에서 CDS View를 구축할 때 데이터를 결합하는 방식은 크게 전통적인 **SQL Join** 과 CDS Core 기능인 **Association** 두 가지로 나뉩니다.
**핵심 요약**

- **Join:** 정적(Static) 결합 — 쿼리가 실행되는 시점에 무조건 데이터를 합칩니다.
- **Association: ** 동적(Dynamic) 결합 — 기본 데이터만 먼저 읽고, 하위 데이터는 **실제 요청(On-demand)이 있을 때만** 조인합니다. (성능 최적화에 유리)

## 2. SQL Join 종류 및 특징
RAP의 CDS View 내에서도 표준 SQL Join을 그대로 사용할 수 있습니다.
### 📊 Join 종류별 비교 테이블

| **Join 종류** | **노션 아이콘** | **설명** | **매칭 실패 시 결과** |
| --- | --- | --- | --- |
| **Inner Join** | 🤝 | 양쪽 테이블에 모두 조건이 일치하는 데이터만 반환 | 결과에서 제외됨 |
| **Left Outer Join** | 👈 | 왼쪽(가져올 주체) 테이블의 모든 데이터 + 오른쪽의 일치하는 데이터 | 오른쪽 테이블 내용은 `NULL`로 채워짐 |
| **Right Outer Join** | 👉 | 오른쪽 테이블의 모든 데이터 + 왼쪽의 일치하는 데이터 | 왼쪽 테이블 내용은 `NULL`로 채워짐 |

### 📌 Join 사용 시 주의사항 (토글)
### 클릭하여 내용 펼치기
- **성능 부담:** Join된 테이블이 많고 데이터가 방대할 경우, 사용하지 않는 필드까지 모두 조인하므로 DB와 네트워크에 부하가 걸립니다.
- **1:N 관계의 주의점:** 1:N 관계의 테이블을 Join하면 중심 테이블의 Row가 중복되어 늘어나는 현상이 발생합니다.

## 3. Association (RAP의 핵심 기능)
Association은 데이터 모델 간의 **관계(Relationship) 정의** 에 집중하는 CDS View의 강력한 기능입니다.
### 🔄 Association의 핵심 메커니즘: Lazy Loading (간접 조인)
- 엔티티를 정의할 때는 조인을 맺지 않고, 데이터 관계성(Cardinality)만 정의해 둡니다.
- OData 서비스나 UI에서 해당 하위 엔티티로 네비게이션(Navigation)을 가거나 필드를 명시적으로 호출할 때, 그 순간 내부적으로 `Left Outer Join`이 실행됩니다.

```ABAP
// CDS View에서의 Association 선언 예시
define view entity ZI_OrderHeader
  as select from zorder_h
  association [0..*] to ZI_OrderItem as _Item on $projection.OrderUUID = _Item.OrderUUID
{
  key order_uuid as OrderUUID,
      order_id   as OrderID,

      /* Expose association */
      _Item // 노출만 시켜두고, 호출 전까지는 조인되지 않음
}
```

## 4. [핵심 비교] Join vs Association
노션에서 한눈에 비교할 수 있는 종합 대조표입니다.

| **비교 항목** | **SQL Join (Inner / Left Outer)** | **Association** |
| --- | --- | --- |
| **결합 시점** | **정적 (Static)**<br>쿼리 실행 시 항상 즉시 결합 | **동적 (Dynamic)**<br>데이터가 필요한 시점에 결합 (Lazy Loading) |
| **성능 (Performance)** | 불필요한 필드까지 항상 읽어오므로 상대적으로 무거움 | 최초 조회 시 메인 테이블만 읽으므로 가볍고 빠름 |
| **OData / UI 활용** | 단순 플랫(Flat)한 구조 출력에 적합 | Fiori Elements의 **Navigation Path** 및 대량 데이터 처리에 필수적 |
| **카디널리티 (관계성)** | 명시하지 않음 (조인 조건만 기술) | `[1..1]`, `[0..*]` 등 데이터 관계를 명확히 선언 |
| **재사용성** | 해당 쿼리 내부에서만 일회성으로 결합됨 | 한 번 정의해 두면 다른 CDS나 비즈니스 로직에서 자유롭게 타고 들어감 (Reuse 가능) |

## 5. RAP 개발 시 어떤 것을 선택해야 할까? (Best Practice)


1. **기본 규칙은 Association을 우선 고려합니다.**
- RAP 기반 비즈니스 객체(BO)를 설계할 때는 Header와 Item 간의 관계를 무조건 `Association` (혹은 `Composition`)으로 엮는 것이 정석입니다.
2. **이럴 때는 Join을 사용하세요.**
- 메인 데이터를 조회할 때 **우측 테이블의 특정 필드가 무조건 필수로 화면에 같이 나와야 하거나**, 해당 필 조건으로 ** 필터링(Where절)** 을 쳐서 가져와야 할 때는 `Inner Join` 또는 `Left Outer Join`을 사용하는 것이 직관적이고 효율적입니다.
3. **경로 표현식(Path Expression) 활용**
- Association을 맺어둔 상태에서 특정 필드가 즉시 필요하다면, Select List 내에서 `_Item.MaterialName` 처럼 경로 표현식을 써서 Join처럼 바로 꺼내 쓸 수도 있습니다.
