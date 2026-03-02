# ClaudeUsageBar

macOS 메뉴바에서 Claude API 사용량을 실시간으로 모니터링하는 앱입니다.

---

## 스크린샷

```
C:42%  W:15%    ← 메뉴바 표시
```

---

## 기능

### 사용량 모니터링
- 현재 세션 사용률
- 주간(7일) 사용률
- Opus / Sonnet 모델별 사용률
- 색상 표시: 초록(~79%) → 주황(80~94%) → 빨강(95%~)
- 리셋 시간 표시

### 계정 정보 (설정 > 정보 탭)
- 이름, 이메일, 조직
- 플랜 (Pro / Max), 기본 모델
- 로그인 방식, Claude Code 버전
- 타임존, 지역 정보

### 설정 (탭 UI)
- **정보**: 계정/플랜/모델/버전 정보 + 업데이트 확인
- **표시**: 표시 항목 선택, 상태바 포맷 (C:%, W:%, 둘 다, 숫자만)
- **일반**: 새로고침 주기 (1/3/5/10분), 언어 (한국어/English), 부팅 시 실행

---

## 요구사항

- macOS 13+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 로그인 필요 (OAuth 토큰을 Keychain에서 읽음)

---

## 설치

### DMG 다운로드

[Releases](https://github.com/duaghwns/ClaudeUsageBar/releases) 페이지에서 최신 `ClaudeUsageBar-x.x.x.dmg`를 다운받아 Applications 폴더에 드래그하세요.

### Homebrew

```bash
brew tap duaghwns/tap
brew install claude-usage-bar
```

### 직접 빌드

```bash
git clone https://github.com/duaghwns/ClaudeUsageBar.git
cd ClaudeUsageBar
swift build -c release
.build/release/ClaudeUsageBar
```

---

## 사전 준비

1. [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 설치
2. `claude` 명령어로 로그인
3. ClaudeUsageBar 실행

앱은 Keychain에 저장된 Claude Code OAuth 토큰을 사용합니다.

---

## 라이선스

MIT

---

# ClaudeUsageBar (English)

A macOS menu bar app for real-time Claude API usage monitoring.

---

## Screenshots

```
C:42%  W:15%    ← Menu bar display
```

---

## Features

### Usage Monitoring
- Current session utilization
- 7-day weekly utilization
- Per-model usage (Opus, Sonnet)
- Color-coded progress bars: green (~79%) → orange (80~94%) → red (95%~)
- Reset time display

### Account Info (Settings > Info tab)
- Name, email, organization
- Plan (Pro / Max), default model
- Login method, Claude Code version
- Timezone, region

### Settings (Tabbed UI)
- **Info**: Account/plan/model/version info + check for updates
- **Display**: Toggle display items, status bar format (C:%, W:%, both, number only)
- **General**: Refresh interval (1/3/5/10 min), language (Korean/English), launch at login

---

## Requirements

- macOS 13+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) login required (reads OAuth token from Keychain)

---

## Installation

### DMG Download

Download the latest `ClaudeUsageBar-x.x.x.dmg` from the [Releases](https://github.com/duaghwns/ClaudeUsageBar/releases) page and drag it to your Applications folder.

### Homebrew

```bash
brew tap duaghwns/tap
brew install claude-usage-bar
```

### Build from Source

```bash
git clone https://github.com/duaghwns/ClaudeUsageBar.git
cd ClaudeUsageBar
swift build -c release
.build/release/ClaudeUsageBar
```

---

## Prerequisites

1. Install [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
2. Log in with the `claude` command
3. Run ClaudeUsageBar

The app reads the Claude Code OAuth token stored in the macOS Keychain.

---

## License

MIT
