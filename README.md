# ClaudeUsageBar

macOS 메뉴바에서 Claude API 사용량을 실시간으로 모니터링하는 앱입니다.

A macOS menu bar app for real-time Claude API usage monitoring.

---

## 스크린샷 / Screenshots

```
C:42%  W:15%    ← 메뉴바 표시 / Menu bar display
```

---

## 기능 / Features

### 사용량 모니터링 / Usage Monitoring
- 5시간 세션 사용률 / 5-hour session utilization
- 7일 주간 사용률 / 7-day weekly utilization
- Opus / Sonnet 모델별 사용률 / Per-model usage (Opus, Sonnet)
- 색상 표시: 초록(~79%) → 주황(80~94%) → 빨강(95%~) / Color-coded progress bars

### 계정 정보 / Account Info
- 이름, 이메일, 플랜 / Name, email, plan
- 로그인 방식, Claude Code 버전 / Login method, CLI version

### 설정 / Settings
- 표시 항목 선택 (5시간, 주간, Opus, Sonnet) / Toggle display items
- 상태바 포맷 (C:%, W:%, 둘 다, 숫자만) / Status bar format options
- 새로고침 주기 (1분, 3분, 5분, 10분) / Refresh interval (1/3/5/10 min)
- 부팅 시 실행 / Launch at login
- 언어 (한국어, English) / Language selection

---

## 요구사항 / Requirements

- macOS 13+
- Swift 5.9+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 로그인 필요 (OAuth 토큰을 Keychain에서 읽음)
- Claude Code CLI login required (reads OAuth token from Keychain)

---

## 설치 / Installation

### Homebrew

```bash
brew tap duaghwns/tap
brew install claude-usage-bar
```

### 직접 빌드 / Build from Source

```bash
git clone https://github.com/duaghwns/ClaudeUsageBar.git
cd ClaudeUsageBar
swift build -c release
```

빌드된 실행 파일 경로 / Built executable:
```
.build/release/ClaudeUsageBar
```

### 실행 / Run

```bash
# 디버그 / Debug
swift run ClaudeUsageBar

# 릴리즈 / Release
.build/release/ClaudeUsageBar
```

---

## 사전 준비 / Prerequisites

1. [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 설치 / Install Claude Code CLI
2. `claude` 명령어로 로그인 / Log in with `claude` command
3. ClaudeUsageBar 실행 / Run ClaudeUsageBar

앱은 Keychain에 저장된 Claude Code OAuth 토큰을 사용합니다.
The app reads the Claude Code OAuth token stored in the macOS Keychain.

---

## 라이선스 / License

MIT
