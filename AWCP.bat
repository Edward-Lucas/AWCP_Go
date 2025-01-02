@echo off

echo AWCP ���� ��...
echo ------------------------------------------

REM ���� ��ũ��Ʈ ��ġ ����
set "CURRENT_DIR=%~dp0"

REM ���� ���丮 ��η� �̵�
pushd ..

REM scrcpy_win64-for-hyper_plus-v001-030 ���丮 Ȯ�� �� ���� ��� ����
set "TARGET_DIR="
for /d %%D in (scrcpy_win64-for-hyper_plus-v001-030) do (
    set "TARGET_DIR=%%~fD"
)

REM ���丮�� �߰ߵǸ� PATH�� �߰�
if defined TARGET_DIR (
    echo Adding %TARGET_DIR% to PATH...
    set "ORIGINAL_PATH=%PATH%"
    set PATH=%TARGET_DIR%;%PATH%
) else (
    echo Directory scrcpy_win64-for-hyper_plus-v001-030 not found in the parent folder.
    exit /b 1
)

echo adb ���� �ʱ�ȭ...
adb kill-server
adb start-server
cls
echo �޴����� ������ �ɼǿ��� Ȱ��ȭ�ϼ���!
echo ------------------------------------------
echo 1. USB �����
echo 2. USB ����� (���� ����) �� ������ �ȵ���̵� ������ �������� ����
echo 3. ���� ����� �� �������� �ʴ� ���, USB ���� PC�� �����Ͽ� ����
echo ------------------------------------------
pause
cls
echo AWCP... ������ �����⿡ ����� �ȵ���̵� ��ġ�� �������� �����մϴ�.
echo ------------------------------------------
echo [QR �ڵ�� ��� ��]�� �����ϰ� �Ʒ��� QR �ڵ带 ��ĵ�ϼ���.

REM ���� ���丮�� exe ���� ���� (���� �ʿ��� ��� ���� �̸� ����)
cd "%CURRENT_DIR%"
set "EXE_FILE=apg.exe"
if exist "%EXE_FILE%" (
    echo.
    echo.
    "%EXE_FILE%"
) else (
    echo File %EXE_FILE% not found in the current directory.
    REM PATH ����
    set PATH=%ORIGINAL_PATH%
    exit /b 2
)

REM PATH ����
set PATH=%ORIGINAL_PATH%

REM ���� ��η� ����
popd

echo ���ῡ ������ ���, USB ���� PC�� �����Ͽ� �����ϼ���.
pause

:: �ش� ���α׷��� lx200916���� ADB_Pair_Go�� ������� �մϴ�.
:: https://github.com/lx200916/ADB_Pair_Go
:: AWCP�� ���� ������ ������ ���Ͽ� �������Դϴ�.
