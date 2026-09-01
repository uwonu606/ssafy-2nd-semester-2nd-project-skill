#!/usr/bin/env bash
# claude-skills 설치 스크립트
#
# 사용법:
#   bash install.sh                        # skills/ 아래 전부 전역 설치 (~/.claude/skills)
#   bash install.sh foo bar                # foo, bar 스킬만 설치
#   bash install.sh --project              # 현재 디렉토리의 .claude/skills 에 설치
#   bash install.sh --copy                 # symlink 대신 복사본으로 설치
#   bash install.sh --list                 # 저장소에 있는 스킬 목록만 출력
#   bash install.sh --uninstall [이름...]  # 설치 제거 (이름 없으면 전부)
#   bash install.sh --force                # 이 저장소 것이 아닌 항목도 대체/제거
#
# 기본은 symlink 설치라 저장소에서 SKILL.md를 고치면 즉시 반영됩니다.
# --copy 로 설치한 경우에는 수정 후 install.sh --copy --force 를 다시 실행해야
# 합니다 — 복사본은 이 저장소가 걸어 둔 symlink 가 아니어서 --force 없이는
# 덮어쓰지 않습니다.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"

TARGET_ROOT="$HOME/.claude"
UNINSTALL=false
MODE=symlink
LIST_ONLY=false
FORCE=false
NAMES=()

for arg in "$@"; do
  case "$arg" in
    --project)   TARGET_ROOT="$(pwd)/.claude" ;;
    --copy)      MODE=copy ;;
    --uninstall) UNINSTALL=true ;;
    --list)      LIST_ONLY=true ;;
    --force)     FORCE=true ;;
    -h|--help)
      awk 'NR==1 {next} /^#/ {sub(/^# ?/, ""); print; next} {exit}' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    -*)
      echo "알 수 없는 옵션: $arg" >&2
      echo "사용법: bash install.sh [--project] [--copy] [--list] [--uninstall] [--force] [스킬이름...]" >&2
      exit 1
      ;;
    *) NAMES+=("$arg") ;;
  esac
done

# dest 가 이 저장소가 걸어 둔 symlink 인가
owned() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in
    "$SRC_DIR"/*) return 0 ;;
    *)            return 1 ;;
  esac
}

# dest 가 없거나, 우리 것이거나, --force 면 비우고 0. 남의 것이면 그대로 두고 1.
claim() {
  { [ -e "$1" ] || [ -L "$1" ]; } || return 0
  if owned "$1" || $FORCE; then
    rm -rf "$1"
    return 0
  fi
  return 1
}

# 저장소에 있는 스킬 목록 (SKILL.md 를 가진 디렉토리만)
all_skills() {
  local d
  for d in "$SRC_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    basename "$d"
  done
}

if $LIST_ONLY; then
  found=false
  while read -r name; do
    [ -n "$name" ] || continue
    found=true
    desc=$(sed -n 's/^description: *//p' "$SRC_DIR/$name/SKILL.md" | head -1)
    printf '  %-28s %s\n' "$name" "$desc"
  done < <(all_skills)
  $found || echo "  (아직 스킬 없음 — skills/<이름>/SKILL.md 를 추가하세요)"
  exit 0
fi

# 대상 스킬 결정: 인자로 받은 이름들, 없으면 전부
if [ ${#NAMES[@]} -eq 0 ]; then
  mapfile -t NAMES < <(all_skills)
fi

if [ ${#NAMES[@]} -eq 0 ]; then
  echo "설치할 스킬이 없습니다. skills/<이름>/SKILL.md 를 먼저 추가하세요." >&2
  exit 1
fi

SKILLS_ROOT="$TARGET_ROOT/skills"

if $UNINSTALL; then
  echo "제거 완료:"
  for name in "${NAMES[@]}"; do
    dest="$SKILLS_ROOT/$name"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if claim "$dest"; then
        echo "  - $dest"
      else
        echo "  ! $name — $dest 는 이 저장소가 건 symlink 가 아님, 건너뜀 (--force 로 제거)" >&2
      fi
    fi
  done
  exit 0
fi

mkdir -p "$SKILLS_ROOT"
installed=0
for name in "${NAMES[@]}"; do
  src="$SRC_DIR/$name"
  if [ ! -f "$src/SKILL.md" ]; then
    echo "  ! $name — skills/$name/SKILL.md 없음, 건너뜀" >&2
    continue
  fi
  dest="$SKILLS_ROOT/$name"
  if ! claim "$dest"; then
    echo "  ! $name — $dest 에 이 저장소 것이 아닌 항목이 있음, 건너뜀 (--force 로 대체)" >&2
    continue
  fi
  if [ "$MODE" = symlink ]; then
    ln -s "$src" "$dest"
  else
    cp -r "$src" "$dest"
  fi
  [ "$installed" -eq 0 ] && echo "설치 완료 ($MODE):"
  installed=$((installed + 1))
  echo "  - $dest"
done

if [ "$installed" -eq 0 ]; then
  echo "설치된 스킬 없음." >&2
  exit 1
fi

echo ""
echo "새 Claude Code 세션에서 /<스킬이름> 으로 사용하세요."
