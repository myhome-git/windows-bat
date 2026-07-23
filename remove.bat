@echo off
:: 1. 提示用户输入路径
set /p "TARGET_PATH=请输入需要清理的完整文件夹路径: "

:: 2. 检查路径是否存在，防止误操作
if not exist "%TARGET_PATH%" (
    echo 错误：你输入的路径 "%TARGET_PATH%" 不存在，请检查后重试！
    pause
    exit /b
)

:: 3. 安全确认
echo.
echo 警告：即将永久删除以下目录及其所有内容（包含子目录和文件）：
echo %TARGET_PATH%
echo 此操作不可逆，且不会经过回收站！
set /p CONFIRM=确定要继续吗？(Y/N): 
if /i not "%CONFIRM%"=="Y" (
    echo 操作已取消。
    pause
    exit /b
)

:: 4. 开始执行删除（控制台会实时滚动显示删除的文件）
echo.
echo 正在开始清理文件，控制台将实时显示进度...
del /f /s /q "%TARGET_PATH%\*"

echo.
echo 文件清理完毕，正在删除空文件夹...
rd /s /q "%TARGET_PATH%"

echo.
echo 全部清理完成！
pause