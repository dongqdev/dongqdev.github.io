#!/usr/bin/env bash
# _images/ 안에서 어떤 _posts/*.md 에도 더 이상 참조되지 않는 "고아 이미지"를 찾아 삭제합니다.
# 게시물을 지운 뒤 이 스크립트를 실행하면, 그 게시물이 쓰던 이미지들이 자동으로 함께 정리됩니다.
#
# 사용법:
#   ./scripts/cleanup_orphan_images.sh          # dry-run: 지울 목록만 보여줌
#   ./scripts/cleanup_orphan_images.sh --force  # 실제로 삭제
#
# 삭제 여부 판단 기준: 이미지 경로(예: /_images/20260808/foo_image1.png)가
# 어떤 _posts/*.md 파일에도 문자열로 등장하지 않으면 고아로 간주합니다.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

if [[ ! -d _images || ! -d _posts ]]; then
  echo "이 스크립트는 저장소 루트(_images, _posts가 있는 위치)에서 실행해야 합니다." >&2
  exit 1
fi

orphans=()

while IFS= read -r -d '' img; do
  # _images/20260808/foo.png -> /_images/20260808/foo.png (마크다운/프론트매터에서 쓰는 형태)
  ref_path="/${img#./}"
  filename="$(basename "$img")"

  # 경로 전체 또는 파일명만으로도 참조를 찾는다 (프론트매터 image.path, 본문 ![]() 둘 다 커버)
  if grep -rqF -- "$ref_path" _posts/ 2>/dev/null || grep -rqF -- "$filename" _posts/ 2>/dev/null; then
    continue
  fi

  orphans+=("$img")
done < <(find _images -type f -print0)

if [[ ${#orphans[@]} -eq 0 ]]; then
  echo "고아 이미지가 없습니다. 정리할 게 없습니다."
  exit 0
fi

echo "고아 이미지 ${#orphans[@]}개 발견:"
printf '  %s\n' "${orphans[@]}"

if [[ "$FORCE" -eq 1 ]]; then
  for f in "${orphans[@]}"; do
    rm -f -- "$f"
  done
  echo "삭제 완료 (${#orphans[@]}개)."
else
  echo
  echo "실제로 삭제하려면 --force 옵션을 붙여서 다시 실행하세요:"
  echo "  ./scripts/cleanup_orphan_images.sh --force"
fi
