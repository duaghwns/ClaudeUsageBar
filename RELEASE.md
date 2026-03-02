# Release Process

이 문서는 ClaudeUsageBar의 새 버전을 릴리스하는 절차를 정의한다.
사용자가 "v{X.Y.Z}로 릴리스해줘" 또는 "새 버전 올려줘"라고 요청하면 아래 절차를 순서대로 수행한다.

## 1. 버전 번호 업데이트

`Sources/ClaudeUsageBar/SettingsWindowController.swift` 파일의 `kAppVersion` 값을 새 버전으로 변경한다.

```swift
let kAppVersion = "X.Y.Z"
```

## 2. 변경사항 커밋

- 변경된 파일만 선택적으로 `git add` (git add -A 사용 금지)
- 커밋 메시지 형식:

```
vX.Y.Z: 한 줄 요약

- 변경사항 1
- 변경사항 2

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## 3. 리모트 동기화 및 푸시

```bash
git pull --rebase origin master
git push origin master
```

## 4. GitHub Release 생성

```bash
gh release create vX.Y.Z --title "vX.Y.Z" --notes "릴리스 노트"
```

- 릴리스 노트는 `## Changes` 헤더 아래에 변경사항을 한/영 혼용으로 작성
- GitHub Actions (`release.yml`)가 자동으로 DMG를 빌드하여 릴리스에 첨부함

## 5. 로컬 앱 재설치 (선택)

사용자가 요청하면 로컬에도 최신 버전을 설치한다.

```bash
bash scripts/install.sh
```

## 참고

- 메인 브랜치: `master`
- 번들 ID: `com.duaghwns.ClaudeUsageBar`
- GitHub 저장소: `duaghwns/ClaudeUsageBar`
- DMG 빌드: `.github/workflows/release.yml` (release 이벤트 시 자동 실행)
