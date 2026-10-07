# Vivado MCP: Claude Code로 Vivado 제어하기 (Windows)

Claude Code가 AMD Vivado를 직접 실행하고 제어하게 해 주는 MCP 서버입니다.
"합성 돌려줘", "타이밍 만족했어?", "시뮬레이션 1us 돌리고 신호 값 보여줘"처럼 말로 요청하면
Claude가 Vivado TCL 명령을 대신 실행합니다.

> 원본 프로젝트: [coreyhahn/vivado_mcp](https://github.com/coreyhahn/vivado_mcp)
> (Windows 지원: [newtonsart/vivado_mcp](https://github.com/newtonsart/vivado_mcp))
> 원본 영문 문서: [README.en.md](README.en.md)

---

## 0. 준비물

| 항목 | 확인 방법 |
|------|-----------|
| Windows 10/11 | |
| AMD Vivado (2023.2 이상, 실습실 기준 2026.1) | 설치 폴더에 `Vivado\bin\vivado.bat`가 있어야 함 |
| Python 3.10 이상 | PowerShell에서 `python --version` |
| Git | `git --version` |
| Claude Code (로그인 완료) | `claude --version` |

Vivado 기본 설치 경로는 `C:\AMDDesignTools\2026.1\Vivado\bin`이라고 가정합니다.
다른 곳에 설치했다면 아래 명령의 경로를 **본인 경로로 바꿔서** 입력하세요.

---

## 1. 빠른 설치 (스크립트)

PowerShell을 열고 아래를 순서대로 실행합니다.

```powershell
cd C:\
git clone https://github.com/binghin2/Vivado_mcp_student.git vivado_mcp
cd vivado_mcp
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
```

Vivado를 다른 경로에 설치했다면:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1 -VivadoBin "D:\Xilinx\Vivado\2025.2\bin"
```

스크립트가 하는 일:
1. Vivado `bin` 폴더를 사용자 PATH에 등록
2. `pip install -e .` (필요한 `mcp`, `pywinpty` 자동 설치)
3. 설치 확인
4. Claude Code에 `vivado` MCP 서버 등록

`Done.`이 나오면 **3. 동작 확인**으로 넘어가세요.

---

## 2. 수동 설치 (스크립트를 쓰지 않는 경우)

### 2-1. Vivado를 PATH에 등록

```powershell
$vivadoBin = "C:\AMDDesignTools\2026.1\Vivado\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$vivadoBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$vivadoBin", "User")
}
```

**PowerShell 창을 닫고 새로 연 뒤** 확인합니다.

```powershell
vivado -version
```

버전 정보가 출력되면 성공입니다.

### 2-2. 저장소 받기 & 설치

```powershell
cd C:\
git clone https://github.com/binghin2/Vivado_mcp_student.git vivado_mcp
cd vivado_mcp
pip install -e .
```

### 2-3. Vivado 연결 테스트

저장소 폴더 안에서 실행합니다. Vivado가 뜨는 데 수십 초 걸릴 수 있습니다.

```powershell
python -c "from vivado_session import VivadoSession; s=VivadoSession(); r=s.start(); print(r.success, r.output); print(s.run_tcl('version').output); s.stop()"
```

`True`와 Vivado 버전이 출력되면 성공입니다.

### 2-4. Claude Code에 등록

**저장소 폴더 밖**(예: 홈 폴더)으로 이동한 뒤 등록합니다.

```powershell
cd ~
claude mcp add --scope user vivado -- python -m vivado_mcp
```

`--scope user`로 등록하면 어느 폴더에서 Claude Code를 켜도 사용할 수 있습니다.

---

## 3. 동작 확인

새 PowerShell 창에서:

```powershell
claude
```

Claude Code 안에서 `/mcp`를 입력하면 `vivado` 서버가 **connected**로 보여야 합니다.

그다음 이렇게 말해 보세요.

```
Vivado 세션 시작하고 버전 알려줘
```

---

## 4. 사용 예시

```
Vivado 세션 시작해줘
C:\work\lab3\lab3.xpr 프로젝트 열어줘
합성 돌리고 끝나면 리소스 사용량 보여줘
구현까지 돌리고 타이밍 만족하는지 확인해줘
timing violation 나는 경로 상위 5개 보여줘
비트스트림 생성해줘
테스트벤치 tb_counter로 behavioral 시뮬레이션 1us 돌리고 count 신호 값 알려줘
Vivado 세션 종료해줘
```

**팁**
- 세션을 한 번 켜 두면 계속 재사용되므로 명령마다 Vivado를 다시 띄우지 않습니다.
- 합성, 구현, 비트스트림 생성은 백그라운드에서 진행됩니다. "합성 진행 상황 알려줘"라고 물어보면 상태를 확인해 줍니다.
- 작업이 끝나면 "세션 종료해줘"로 Vivado 프로세스를 닫아 주세요. (메모리 절약)
- 프로젝트 경로는 공백, 한글이 없는 경로를 권장합니다. (Vivado 자체 제약)

---

## 5. 사용 가능한 기능

| 분류 | 도구 |
|------|------|
| 세션 | `start_session`, `stop_session`, `session_status`, `check_session_health` |
| 프로젝트 | `open_project`, `close_project`, `get_project_info` |
| 설계 흐름 | `run_synthesis`, `run_implementation`, `generate_bitstream` |
| 리포트 | `get_timing_summary`, `get_timing_paths`, `get_utilization`, `get_clocks`, `get_messages` |
| 설계 조회 | `get_design_hierarchy`, `get_ports`, `get_nets`, `get_cells` |
| 시뮬레이션 | `launch_simulation`, `run_simulation`, `restart_simulation`, `close_simulation`, `step_simulation`, `get_signal_value(s)`, `add_signals_to_wave`, `set_simulation_top`, `get_scopes`, `add_breakpoint` 등 |
| 고급 | `run_tcl` (임의 TCL 실행), `generate_full_report`, `read_report_section` |

도구 이름을 외울 필요는 없습니다. 하고 싶은 작업을 말로 요청하면 Claude가 알맞은 도구를 고릅니다.

---

## 6. 제거

```powershell
claude mcp remove --scope user vivado
pip uninstall vivado-mcp
```

---

## License

MIT License. [LICENSE](LICENSE) 참고.
