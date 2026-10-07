# Vivado MCP: AI로 Vivado 조작하기 (Windows 학생용)

AI(Claude Code, Codex, Gemini)에게 **말로 시키면 Vivado가 알아서 움직이게** 해 주는 도구입니다.

```
"lab3 프로젝트 열고 합성 돌려줘"
"타이밍 만족했어?"
"시뮬레이션 1us 돌리고 count 신호 값 알려줘"
```

> 아래 순서대로 **위에서부터 하나씩** 따라 하면 됩니다. 건너뛰지 마세요.
> 회색 상자 안의 명령어는 **복사해서 붙여넣기**만 하면 됩니다. 직접 타이핑하지 마세요.

---

## 한눈에 보기

| 단계 | 할 일 | 걸리는 시간 |
|------|-------|-------------|
| STEP 0 | PowerShell 여는 법 익히기 | 1분 |
| STEP 1 | 필요한 프로그램 설치 | 10~20분 |
| STEP 2 | 이 프로그램 다운로드 | 1분 |
| STEP 3 | `setup.bat` 더블클릭 | 2~3분 |
| STEP 4 | AI 켜서 확인 | 1분 |

**Vivado는 이미 설치되어 있다고 가정합니다.** (수업 시간에 설치한 그 Vivado)

---

## STEP 0. PowerShell 여는 법

앞으로 "PowerShell을 연다"는 말이 나오면 이렇게 하세요.

1. 키보드의 **Windows 키**를 누릅니다.
2. `powershell` 이라고 입력합니다.
3. **Windows PowerShell**이 나오면 **Enter**를 누릅니다.
4. 파란색 또는 검은색 창이 뜨면 성공입니다.

**명령어 붙여넣는 법:** 아래 회색 상자 오른쪽 위의 복사 버튼을 누르고, PowerShell 창에서 **마우스 오른쪽 클릭** (또는 `Ctrl + V`) 한 뒤 **Enter**.

**"창을 닫고 새로 연다"** 는 말이 나오면 PowerShell 창의 **X 버튼**으로 닫고, 위 1~3번을 다시 하면 됩니다.

---

## STEP 1. 필요한 프로그램 설치

### 1-1. PowerShell 스크립트 허용 (모두 필수, 처음 한 번만)

PowerShell을 열고 붙여넣기 → Enter:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
```

아무 메시지도 안 나오면 정상입니다.

### 1-2. Python, Git 설치 (모두 필수)

같은 창에 아래 **두 줄을 한 줄씩** 붙여넣고 Enter. 각각 끝날 때까지 기다리세요.

```powershell
winget install -e --id Python.Python.3.12 --override "/quiet InstallAllUsers=0 PrependPath=1" --accept-source-agreements --accept-package-agreements
```

```powershell
winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
```

> 중간에 "이 앱이 디바이스를 변경하도록 허용하시겠어요?" 창이 뜨면 **예**를 누르세요.

**PowerShell 창을 닫고 새로 연 뒤** 확인:

```powershell
python --version
```

`Python 3.12.x` 처럼 나오면 성공입니다.

### 1-3. AI 도구 설치 (셋 중 하나만 골라서)

어떤 걸 쓸지 모르겠으면 **수업에서 안내한 것**을 고르세요.

<details>
<summary><b>A. Claude Code를 쓸 경우 (클릭해서 펼치기)</b></summary>

PowerShell에 붙여넣기 → Enter:

```powershell
irm https://claude.ai/install.ps1 | iex
```

**창을 닫고 새로 연 뒤** 아래를 입력하고, 안내에 따라 로그인합니다.

```powershell
claude
```

로그인이 끝나면 `/exit` 를 입력해서 나옵니다.

</details>

<details>
<summary><b>B. Codex를 쓸 경우 (클릭해서 펼치기)</b></summary>

먼저 Node.js를 설치합니다.

```powershell
winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
```

**창을 닫고 새로 연 뒤:**

```powershell
npm install -g @openai/codex
```

설치가 끝나면 아래를 입력하고, **Sign in with ChatGPT**를 골라 로그인합니다.

```powershell
codex
```

로그인이 끝나면 `/quit` 를 입력해서 나옵니다.

> Codex **데스크톱 앱**을 쓰는 경우에도 이 설치 과정은 그대로 따라 하면 됩니다. (설정이 앱과 공유됩니다)

</details>

<details>
<summary><b>C. Gemini를 쓸 경우 (클릭해서 펼치기)</b></summary>

먼저 Node.js를 설치합니다.

```powershell
winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
```

**창을 닫고 새로 연 뒤:**

```powershell
npm install -g @google/gemini-cli
```

설치가 끝나면 아래를 입력하고, **Login with Google**을 골라 로그인합니다.

```powershell
gemini
```

로그인이 끝나면 `/quit` 를 입력해서 나옵니다.

</details>

---

## STEP 2. 이 프로그램 다운로드

PowerShell을 열고 아래를 **한 줄씩** 붙여넣기 → Enter:

```powershell
cd C:\
```

```powershell
git clone https://github.com/binghin2/Vivado_mcp_student.git vivado_mcp
```

이제 `C:\vivado_mcp` 폴더가 생겼습니다.

> **중요:** 이 폴더는 **지우거나 옮기지 마세요.** 지우면 AI가 Vivado를 못 씁니다.

---

## STEP 3. 설치 프로그램 실행

1. **파일 탐색기**를 엽니다. (`Windows 키 + E`)
2. 주소창에 `C:\vivado_mcp` 를 입력하고 Enter.
3. **`setup.bat`** 파일을 **더블클릭**합니다.
   - "Windows의 PC 보호" 창이 뜨면 **추가 정보** → **실행**을 누르세요.
4. 검은 창에서 설치가 진행됩니다. **건드리지 말고 기다리세요.** (2~3분)

화면이 이렇게 나오면 성공입니다.

```
[1/6] Python 확인
  [OK] Python 3.12
[2/6] Vivado 찾기
  [OK] C:\AMDDesignTools\2026.1\Vivado\bin
[3/6] Vivado 를 PATH 에 등록
  [OK] 등록 완료
[4/6] vivado_mcp 설치 (1~2분 걸릴 수 있습니다)
  [OK] 설치 완료
[5/6] Vivado 실행 테스트 (30초~1분 걸릴 수 있습니다)
  [OK] Vivado 가 정상적으로 실행됩니다.
[6/6] AI 도구에 등록 (Claude Code / Codex / Gemini)
  [OK] Claude Code
  [OK] Codex
  [OK] Gemini

==============================================
 설치 완료!
==============================================
```

- 설치하지 않은 AI 도구는 `[건너뜀]`으로 나와도 괜찮습니다.
- **`[실패]`가 보이면** 아래 [문제가 생겼을 때](#문제가-생겼을-때)를 보세요.
- **"Vivado 를 자동으로 찾지 못했습니다"** 가 나오면 [여기](#vivado-를-자동으로-찾지-못했습니다)를 보세요.

마지막에 `계속하려면 아무 키나 누르십시오...` 가 나오면 아무 키나 눌러 창을 닫습니다.

---

## STEP 4. AI 켜서 확인

**열려 있는 PowerShell 창을 전부 닫고**, 새 PowerShell을 엽니다.

먼저 작업용 폴더를 만들고 그 안으로 이동합니다. (한 줄씩 붙여넣기)

```powershell
mkdir C:\work -Force
```

```powershell
cd C:\work
```

> 앞으로 Vivado 프로젝트도 `C:\work` 안에 만들면 편합니다. (예: `C:\work\lab3`)

그다음 **내가 설치한 AI**를 실행합니다.

| 쓰는 AI | 입력할 명령 |
|---------|-------------|
| Claude Code | `claude` |
| Codex | `codex` |
| Gemini | `gemini` |

AI가 켜지면 `/mcp` 를 입력하고 Enter.
목록에 **vivado** 가 보이면 성공입니다.

이제 이렇게 입력해 보세요.

```
Vivado 세션 시작하고 버전 알려줘
```

> AI가 "이 도구를 실행해도 될까요?" 라고 물어보면 **허용 (Yes / Allow)** 을 고르세요.
> 매번 묻는 게 귀찮으면 "항상 허용 (Always allow / don't ask again)" 을 골라도 됩니다.

---

## 사용 예시

그냥 **한국어로 시키면 됩니다.** 복사해서 써 보세요.

```
Vivado 세션 시작해줘
```
```
C:\work\lab3\lab3.xpr 프로젝트 열어줘
```
```
합성 돌리고 끝나면 리소스 사용량 보여줘
```
```
구현까지 돌리고 타이밍 만족하는지 확인해줘
```
```
타이밍 위반 나는 경로 상위 5개 보여주고 원인 설명해줘
```
```
비트스트림 생성해줘
```
```
tb_counter 테스트벤치로 시뮬레이션 1us 돌리고 count 신호 값 알려줘
```
```
Vivado 세션 종료해줘
```

**꼭 알아둘 것**
- **처음에 "Vivado 세션 시작해줘"** 를 해야 합니다. Vivado가 켜지는 데 30초~1분 걸립니다.
- 합성, 구현은 오래 걸립니다. 중간에 **"진행 상황 알려줘"** 라고 물어보면 됩니다.
- **다 쓰면 "Vivado 세션 종료해줘"** 를 꼭 하세요. 안 하면 Vivado가 컴퓨터 메모리를 계속 차지합니다.
- 프로젝트 폴더 경로에 **한글이나 띄어쓰기가 없게** 하세요. (Vivado 자체 제약)
  - 좋은 예: `C:\work\lab3`
  - 나쁜 예: `C:\Users\홍길동\바탕 화면\실습 3`

---

## 문제가 생겼을 때

### `winget` 을(를) 인식할 수 없습니다
Microsoft Store를 열고 **앱 설치 관리자**를 검색해서 **업데이트**(또는 설치)하세요. 그다음 PowerShell을 새로 엽니다.

### `python` 을 입력했더니 Microsoft Store가 열려요
Python이 설치되지 않은 상태입니다. [1-2](#1-2-python-git-설치-모두-필수)를 다시 하고, **창을 닫고 새로 연 뒤** 확인하세요.

### "이 시스템에서 스크립트를 실행할 수 없으므로..." 라는 빨간 글씨
[1-1](#1-1-powershell-스크립트-허용-모두-필수-처음-한-번만)을 하지 않은 것입니다. 1-1을 하고 다시 시도하세요.

### `claude` / `codex` / `gemini` 을(를) 인식할 수 없습니다
설치 직후라면 **창을 닫고 새로 열어** 보세요. 그래도 안 되면 [1-3](#1-3-ai-도구-설치-셋-중-하나만-골라서)을 다시 하세요.

### Vivado 를 자동으로 찾지 못했습니다
Vivado가 기본 위치가 아닌 곳에 설치된 경우입니다.
1. 파일 탐색기에서 `vivado.bat` 파일을 찾습니다. (보통 `...\Vivado\2023.2\bin` 같은 폴더 안)
2. 그 폴더를 연 상태에서 **주소창을 클릭**하고 `Ctrl + C`로 경로를 복사합니다.
3. 설치 창의 `경로:` 부분에 마우스 오른쪽 클릭으로 붙여넣고 Enter.

### `/mcp` 에 vivado 가 안 보여요
1. PowerShell 창을 **전부** 닫고 새로 열어서 다시 해 보세요.
2. 그래도 안 되면 `C:\vivado_mcp\setup.bat` 을 **한 번 더** 더블클릭하세요.
3. AI 도구를 `setup.bat` **보다 나중에** 설치했다면 반드시 `setup.bat` 을 다시 실행해야 합니다.

### 그래도 안 돼요
`setup.bat` 실행 화면 전체를 **캡처**해서 조교/교수님께 보내 주세요.

---

## (참고) 수동 등록 방법

`setup.bat` 이 자동으로 해 주는 내용입니다. 보통은 볼 필요 없습니다.

<details>
<summary>펼치기</summary>

**Claude Code**

```powershell
claude mcp add --scope user vivado -- python -m vivado_mcp
```

**Codex** — `C:\Users\<내이름>\.codex\config.toml` 맨 아래에 추가:

```toml
[mcp_servers.vivado]
command = "python"
args = ["-m", "vivado_mcp"]
startup_timeout_sec = 60
tool_timeout_sec = 600
```

**Gemini 수동 등록** — `C:\Users\<내이름>\.gemini\settings.json` 에 `mcpServers` 항목 추가:

```json
{
  "mcpServers": {
    "vivado": {
      "command": "python",
      "args": ["-m", "vivado_mcp"],
      "timeout": 600000
    }
  }
}
```

기존 내용이 있으면 지우지 말고 `mcpServers` 부분만 합쳐 넣으세요.
`setup.bat` 은 기존 설정 파일을 수정하기 전에 `.bak` 백업 파일을 만들어 둡니다.

</details>

---

## 삭제하기

PowerShell에서:

```powershell
claude mcp remove --scope user vivado
python -m pip uninstall -y vivado-mcp
```

그다음 `C:\vivado_mcp` 폴더를 지우면 됩니다.
(Codex/Gemini는 위 설정 파일에서 `vivado` 부분을 지우세요.)

---

## 사용 가능한 기능 (참고)

도구 이름을 외울 필요는 없습니다. 하고 싶은 걸 말로 시키면 AI가 알아서 고릅니다.

| 분류 | 할 수 있는 일 |
|------|---------------|
| 세션 | Vivado 켜기/끄기, 상태 확인 |
| 프로젝트 | `.xpr` 프로젝트 열기/닫기, 정보 보기 |
| 설계 흐름 | 합성, 구현, 비트스트림 생성 |
| 리포트 | 타이밍 요약, 위반 경로, 리소스 사용량, 클럭, 경고/에러 메시지 |
| 설계 조회 | 모듈 계층, 포트, 넷, 셀 |
| 시뮬레이션 | 시뮬레이션 실행/재시작, 신호 값 읽기, 파형 추가, 브레이크포인트 |
| 고급 | 임의 TCL 명령 실행, 전체 리포트 저장 |

---

원본 프로젝트: [coreyhahn/vivado_mcp](https://github.com/coreyhahn/vivado_mcp)
(Windows 지원: [newtonsart/vivado_mcp](https://github.com/newtonsart/vivado_mcp)) ·
영문 원본 문서: [README.en.md](README.en.md) · License: MIT ([LICENSE](LICENSE))
