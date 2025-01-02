@echo off

echo AWCP 시작 중...
echo ------------------------------------------

REM 현재 스크립트 위치 저장
set "CURRENT_DIR=%~dp0"

REM 상위 디렉토리 경로로 이동
pushd ..

REM scrcpy_win64-for-hyper_plus-v001-030 디렉토리 확인 및 절대 경로 설정
set "TARGET_DIR="
for /d %%D in (scrcpy_win64-for-hyper_plus-v001-030) do (
    set "TARGET_DIR=%%~fD"
)

REM 디렉토리가 발견되면 PATH에 추가
if defined TARGET_DIR (
    echo Adding %TARGET_DIR% to PATH...
    set "ORIGINAL_PATH=%PATH%"
    set PATH=%TARGET_DIR%;%PATH%
) else (
    echo Directory scrcpy_win64-for-hyper_plus-v001-030 not found in the parent folder.
    exit /b 1
)

echo adb 서버 초기화...
adb kill-server
adb start-server
cls
echo 휴대폰의 개발자 옵션에서 활성화하세요!
echo ------------------------------------------
echo 1. USB 디버깅
echo 2. USB 디버깅 (보안 설정) ← 오래된 안드로이드 버전에 존재하지 않음
echo 3. 무선 디버깅 ← 존재하지 않는 경우, USB 선을 PC와 연결하여 진행
echo ------------------------------------------
pause
cls
echo AWCP... 동일한 공유기에 연결된 안드로이드 장치를 무선으로 연결합니다.
echo ------------------------------------------
echo [QR 코드로 기기 페어링]을 선택하고 아래의 QR 코드를 스캔하세요.

REM 현재 디렉토리에 exe 파일 실행 (변경 필요한 경우 파일 이름 수정)
cd "%CURRENT_DIR%"
set "EXE_FILE=apg.exe"
if exist "%EXE_FILE%" (
    echo.
    echo.
    "%EXE_FILE%"
) else (
    echo File %EXE_FILE% not found in the current directory.
    REM PATH 복원
    set PATH=%ORIGINAL_PATH%
    exit /b 2
)

REM PATH 복원
set PATH=%ORIGINAL_PATH%

REM 원래 경로로 복원
popd

echo 연결에 실패한 경우, USB 선을 PC와 연결하여 진행하세요.
pause

:: 해당 프로그램은 lx200916님의 ADB_Pair_Go를 기반으로 합니다.
:: https://github.com/lx200916/ADB_Pair_Go
:: AWCP의 무단 수정과 배포에 대하여 부정적입니다.
