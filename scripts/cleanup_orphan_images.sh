#!/usr/bin/env bash
# _images/ 안에서 어떤 _posts/*.md 에도 더 이상 참조되지 않는 "고아 이미지"를 찾아 삭제합니다.
# 게시물을 지운 뒤 이 스크립트를 실행하면, 그 게시물이 쓰던 이미지들이 자동으로 함께 정리됩니다.
#
# 사용법:
#   ./scripts/cleanup_orphan_images.sh          # dry-run: 지울 목록만 보여줌
#   ./scripts/cleanup_orphan_images.sh --force  # 실제로 삭제
#
# 삭제 여부 판단 기준: 이미지 경로(예: /_images/20260808/foo_image1.png)가
# 어떤 _posts/*.md 파일에도 문자열로 등장하지 않으면 1차로 "고아 후보"로 봅니다.
#
# 주의: blog-bot은 PUBLISH_TARGET=naver(네이버 전용 발행)일 때 _images만 커밋하고
# _posts 글은 아예 만들지 않습니다(push_images_only, 커밋 메시지"chore: 발행용
# 이미지 추가" 고정). 이런 이미지는 _posts에서 영원히 참조되지 않는 게 "정상"이며,
# 네이버 쪽에서 지금도 쓰고 있을 수 있어 자동 삭제하면 안 됩니다. 그래서 고아 후보
# 중에서도 "그 이미지를 처음 추가한 커밋 메시지가 저 문구인 경우"는 보호 대상으로
# 제외합니다. (반대로 "docs: auto post ...", "docs: sync ..." 등 _posts와 함께
# 커밋됐던 이미지가 지금 고아라면, 그건 나중에 게시물 자체가 지워진 경우이므로
# 안전하게 삭제 대상입니다.)
NAVER_ONLY_COMMIT_MSG="chore: 발행용 이미지 추가"

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
protected=()

while IFS= read -r -d '' img; do
  # _images/20260808/foo.png -> /_images/20260808/foo.png (마크다운/프론트매터에서 쓰는 형태)
  ref_path="/${img#./}"
  filename="$(basename "$img")"

  # 경로 전체 또는 파일명만으로도 참조를 찾는다 (프론트매터 image.path, 본문 ![]() 둘 다 커버)
  if grep -rqF -- "$ref_path" _posts/ 2>/dev/null || grep -rqF -- "$filename" _posts/ 2>/dev/null; then
    continue
  fi

  # 이 파일을 최초로 추가한 커밋의 메시지를 확인 (네이버 전용 발행 여부 판별)
  add_commit_msg="$(git log --diff-filter=A --format='%s' --follow -- "$img" 2>/dev/null | tail -n 1)"
  if [[ "$add_commit_msg" == "$NAVER_ONLY_COMMIT_MSG" ]]; then
    protected+=("$img")
    continue
  fi

  orphans+=("$img")
done < <(find _images -type f -print0)

if [[ ${#protected[@]} -gt 0 ]]; then
  echo "네이버 전용 발행으로 보이는 이미지 ${#protected[@]}개는 보호 대상이라 건너뜁니다:"
  printf '  %s\n' "${protected[@]}"
  echo
fi

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
