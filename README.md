# ssafy-2nd-semester-2nd-project-skill

팀 Jira 컨벤션에 묶인 Claude Code 스킬 모음. 스킬 하나당 디렉토리 하나, 그 안에 `SKILL.md`.

개인 스킬 저장소(`claude-skills`)와 따로 둔 이유는 여기 스킬들이 **팀 Jira 컨벤션에 묶여 있어 팀과 공유할 수 있기 때문**입니다. 대가는 `install.sh` 한 벌이 복제되는 것인데, 그 파일은 저장소 이름에 의존하지 않아 관리 부담이 거의 없습니다.

## 설치

```bash
git clone https://github.com/uwonu606/ssafy-2nd-semester-2nd-project-skill.git
cd ssafy-2nd-semester-2nd-project-skill
bash install.sh                # skills/ 전부 전역 설치 (~/.claude/skills) — symlink
bash install.sh to-jira        # 일부만 설치
bash install.sh --project      # 현재 프로젝트의 .claude/skills 에만 설치
bash install.sh --copy         # symlink 대신 복사본
bash install.sh --list         # 저장소에 있는 스킬 목록
bash install.sh --uninstall    # 제거 (이름 주면 그것만)
```

기본이 symlink라 저장소에서 `SKILL.md`를 고치면 다음 세션부터 바로 반영됩니다. `--copy`로 깔았다면 수정 후 `install.sh --copy --force`를 다시 실행해야 합니다 — 왜 `--force` 인지는 `bash install.sh -h` 가 말합니다.

## 새 스킬 만들기

```bash
mkdir -p skills/<이름>
$EDITOR skills/<이름>/SKILL.md      # 기존 스킬의 짜임을 본떠 쓴다
bash install.sh <이름>
```

- frontmatter 의 `name` 은 디렉토리 이름과 같게 둡니다 — 커맨드 이름이 여기서 옵니다.
- `description`은 Claude가 "이 스킬을 띄울지" 판단하는 유일한 근거입니다. 무엇을 하는지 + 어떤 상황/표현에서 트리거되는지를 같이 적으세요.
- 본문은 Claude가 읽는 절차서입니다. 설명문보다 실행 가능한 단계로 씁니다.
- 보조 파일은 스킬 디렉토리 아래 `references/`(필요할 때 읽는 문서)·`scripts/`(실행 코드)·`assets/`(산출물에 쓰는 파일)에 두고 `SKILL.md`에서 상대경로로 가리킵니다. symlink 설치라 경로가 그대로 유지됩니다.

## 저장소 구성

```
ssafy-2nd-semester-2nd-project-skill/
├── README.md
├── install.sh              # 설치/제거 스크립트
└── skills/to-jira/
    ├── SKILL.md            # 스킬 하나당 디렉토리 하나
    └── references/         # 필요할 때 읽는 보조 문서
```
