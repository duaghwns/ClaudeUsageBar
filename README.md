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
- 5시간 세션 사용률
- 7일 주간 사용률
- Opus / Sonnet 모델별 사용률
- 색상 표시: 초록(~79%) → 주황(80~94%) → 빨강(95%~)

### 계정 정보
- 이름, 이메일, 플랜
- 로그인 방식, Claude Code 버전

### 설정
- 표시 항목 선택 (5시간, 주간, Opus, Sonnet)
- 상태바 포맷 (C:%, W:%, 둘 다, 숫자만)
- 새로고침 주기 (1분, 3분, 5분, 10분)
- 부팅 시 실행
- 언어 (한국어, English)

---

## 요구사항

- macOS 13+
- Swift 5.9+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 로그인 필요 (OAuth 토큰을 Keychain에서 읽음)

---

## 설치

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
```

빌드된 실행 파일 경로:
```
.build/release/ClaudeUsageBar
```

### 실행

```bash
# 디버그
swift run ClaudeUsageBar

# 릴리즈
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
- 5-hour session utilization
- 7-day weekly utilization
- Per-model usage (Opus, Sonnet)
- Color-coded progress bars: green (~79%) → orange (80~94%) → red (95%~)

### Account Info
- Name, email, plan
- Login method, Claude Code version

### Settings
- Toggle display items (5-hour, weekly, Opus, Sonnet)
- Status bar format (C:%, W:%, both, number only)
- Refresh interval (1 / 3 / 5 / 10 min)
- Launch at login
- Language (Korean, English)

---

## Requirements

- macOS 13+
- Swift 5.9+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) login required (reads OAuth token from Keychain)

---

## Installation

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
```

Built executable:
```
.build/release/ClaudeUsageBar
```

### Run

```bash
# Debug
swift run ClaudeUsageBar

# Release
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
