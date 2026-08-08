---
title: "SAP UI5 Controller Lifecycle"
date: 2026-08-08 05:15:22 +0900
categories: ["SAP-FIORI"]
tags: ["SAP", "Fiori"]
---

대부분의 SPA(Single Page Application) Framework는 각 컴포넌트의 생성부터 소멸까지를 관리하는 생명주기(Lifecycle)를 가지고 있습니다.
SAP UI5 역시 SPA Framework에 해당하며, 코어 아키텍처에 따라 아래와 같은 **Controller 메서드 생명주기**를 따릅니다. 상황과 목적에 맞게 적절한 훅(Hook) 메서드를 활용해야 합니다.
## 0. 생명주기 흐름 한눈에 보기
> 1. **`onInit()`** (뷰 생성 및 초기화)
> 2. **`onBeforeRendering()`** (렌더링 직전 인터셉트)
> 3. **`onAfterRendering()`** (화면 그리기 완료 후 DOM 접근 가능)
> 4. **`onExit()`** (뷰 파괴 및 자원 해제)
### 1. onInit
- **설명:** View가 로딩될 때 **무조건 딱 1번만 실행**되는 초기화 함수입니다.
- **용도:** 화면이 처음 켜질 때 초기 데이터를 세팅하거나, 시작 시점에 동작해야 하는 함수들을 주로 등록합니다.
```plain text
onInit: function(){
    // 뷰 초기화 및 모델 바인딩 로직 구현
}
```
### 2. onBeforeRendering
- **설명:** XML View가 브라우저에 **렌더링(화면 생성)되기 직전**에 매번 실행되는 함수입니다.
- **용도:** 데이터 변경 등으로 인해 화면이 다시 그려지기 전, UI 구조를 변경하거나 사전에 처리해야 할 로직이 있을 때 사용합니다.
```plain text
onBeforeRendering: function(){
    // 렌더링 전 실행할 로직 구현
}
```
### 3. onAfterRendering
- **설명:** XML View가 브라우저에 **렌더링(화면 생성)된 직후**에 매번 실행되는 함수입니다.
- **용도:** HTML DOM 요소가 실제로 생성된 시점이기 때문에, JavaScript로 HTML 태그(DOM)를 직접 제어하거나 제이쿼리(jQuery) 플러그인 등을 연동할 때 필수적으로 사용됩니다.
```plain text
onAfterRendering: function(){
    // DOM 접근 및 렌더링 후속 처리
}
```
### 4. onExit
- **설명:** XML View가 파괴되거나 **화면을 완전히 떠날 때(Destroy) 실행**되는 소멸자 함수입니다.
- **용도:** 라우팅(Routing)을 통해 다른 뷰로 이동하면서 현재 뷰가 메모리에서 해제될 때, 메모리 누수(Leak)를 방지하기 위해 생성했던 이벤트를 제거하거나 자원을 초기화(Clean-up)합니다.
```plain text
onExit: function(){
    // 자원 해제 및 인스턴스 초기화
}
```
