@echo off
setlocal enabledelayedexpansion

:: === 核心修复：通过环境变量安全传递自身路径 ===
if "%~1"=="" (
    set "MY_SCRIPT_PATH=%~f0"
    cmd /k "%~f0" RUN
    exit /b
)

:: === 初始化设置 ===
chcp 65001 > nul 2>&1
title 端口进程管理工具 (多任务模式)

:MAIN_LOOP
cls
echo.
echo ==========================================
echo      端口进程管理工具 (支持连续操作)
echo ==========================================
echo   * 输入端口号：扫描并结束占用进程
echo   * 输入 Q     ：退出工具
echo   * 输入 C     ：清屏
echo ==========================================
echo.

:INPUT_PORT
set "port="
set /p "port=请输入端口号 (1-65535) 或指令 [Q/C]: "

:: 1. 处理空输入
if "!port!"=="" goto INPUT_PORT

:: 2. 指令判断 (不区分大小写)
if /i "!port!"=="q" exit /b 0
if /i "!port!"=="c" goto MAIN_LOOP

:: 3. 核心修复：稳健的数字验证逻辑
:: 先去除可能存在的空格
set "check_num=!port: =!"
:: 尝试进行数学加法运算
set /a test_val=!check_num! + 0 2>nul
:: 如果运算结果与原值不一致，说明不是纯数字
if "!test_val!" neq "!check_num!" (
    echo [错误] 检测到非数字字符，请输入纯数字！
    timeout /t 2 >nul
    goto INPUT_PORT
)

:: 4. 范围检查
if !test_val! lss 1 (
    echo [错误] 端口号不能小于 1！
    timeout /t 2 >nul
    goto INPUT_PORT
)
if !test_val! gtr 65535 (
    echo [错误] 端口号不能大于 65535！
    timeout /t 2 >nul
    goto INPUT_PORT
)

:: === 验证通过，开始扫描 ===
set "found=0"
echo.
echo [正在扫描] 端口 !check_num! ...
echo ------------------------------------------

:: 扫描并显示占用情况
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /c:":!check_num! "') do (
    set "pid=%%a"
    set "found=1"
    
    :: 获取进程名称
    set "pname=未知进程"
    for /f "tokens=1" %%b in ('tasklist /fi "PID eq !pid!" /nh') do set "pname=%%b"
    
    echo [发现] PID: !pid!  进程: !pname!
)

echo ------------------------------------------
if "!found!"=="0" (
    echo [结果] 端口 !check_num! 当前未被占用。
    timeout /t 3 >nul
    goto MAIN_LOOP
)

:: 确认操作
choice /c YN /n /m "是否强制结束上述进程？[Y/N] "
if errorlevel 2 (
    echo [已取消]
    timeout /t 2 >nul
    goto MAIN_LOOP
)

:: 执行查杀
echo.
echo [执行中] 正在终止进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /c:":!check_num! "') do (
    taskkill /f /pid %%a >nul 2>&1 && (
        echo [成功] PID %%a 已终止
    ) || (
        echo [失败] PID %%a 终止失败 (可能需要管理员权限)
    )
)

echo.
echo [完成] 操作结束。
timeout /t 3 >nul
goto MAIN_LOOP