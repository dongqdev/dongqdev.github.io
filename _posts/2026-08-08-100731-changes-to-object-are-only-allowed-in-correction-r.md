---
title: "Changes to object are only allowed in correction/repair"
date: 2026-08-08 05:20:12 +0900
categories: ["SAP-오류조치"]
tags: ["SAP", "VII 오류조치"]
image:
  path: /_images/20260808/2026-08-08-100731-changes-to-object-are-only-allowed-in-correction-r_image1.png
---

![관련 이미지](/_images/20260808/2026-08-08-100731-changes-to-object-are-only-allowed-in-correction-r_image1.png)

> 💡 **원인**: 단순히 TR(헤더)만 먼저 생성하고, 시스템이 해당 TR을 '오브젝트를 수정할 수 있는 상태(Correction/Repair)'로 인식하지 못한 경우
### 조치방법
>
- Object를 생성하고, 생성된 Transport Request를 선택
- 이후는 Obejct 추가가 가능해짐.
