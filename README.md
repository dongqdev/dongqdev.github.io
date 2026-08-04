# Chirpy Starter (처피 스타터)

[![Gem Version](https://img.shields.io/gem/v/jekyll-theme-chirpy)][gem]&nbsp;
[![GitHub license](https://img.shields.io/github/license/cotes2020/chirpy-starter.svg?color=blue)][mit]

[**Chirpy**][chirpy] Jekyll 테마를 사용하여 블로그를 신속하게 만들 수 있도록 제공되는 최소한의 즉시 사용 가능한 템플릿입니다. 모든 필수 파일이 미리 구성되어 있어 몇 분 안에 블로그를 시작할 수 있습니다.

## 이 스타터 템플릿이 필요한 이유

[RubyGems.org][gem]을 통해 Chirpy 테마를 설치하는 경우, Jekyll은 젬(gem)에서 테마 파일의 일부(`_data`, `_layouts`, `_includes`, `_sass`, `assets`)와 제한적인 `_config.yml` 옵션만 읽을 수 있습니다. 결과적으로 사용자는 Chirpy가 제공하는 모든 기능을 온전히 누리기 어렵습니다.

모든 기능을 제한 없이 사용하려면 Jekyll 사이트에 다음 파일들이 반드시 존재해야 합니다:

```shell
.
├── _config.yml
├── _plugins
├── _tabs
└── index.html
```

이 스타터 템플릿은 최신 **Chirpy** 릴리스에서 제공하는 파일들과 자동 배포를 위한 [CD][CD] 워크플로우를 함께 묶어 제공하므로, 즉시 글 작성을 시작할 수 있습니다.

## 사용 방법

테마의 상세한 가이드는 [테마 공식 위키](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)를 참조하세요.

## 기여 및 문제 보고

이 저장소는 테마 저장소의 새로운 릴리스가 나올 때마다 자동으로 업데이트됩니다. 문제가 발생하거나 개선에 기여하고 싶으시다면 [테마 저장소][chirpy]를 방문하여 의견을 남겨주세요.

## 라이선스

본 템플릿은 [MIT][mit] 라이선스에 따라 배포됩니다.

[gem]: https://rubygems.org/gems/jekyll-theme-chirpy
[chirpy]: https://github.com/cotes2020/jekyll-theme-chirpy/
[CD]: https://en.wikipedia.org/wiki/Continuous_deployment
[mit]: https://github.com/cotes2020/chirpy-starter/blob/master/LICENSE

