@echo off
:: 设置控制台编码为 UTF-8，防止中文乱码
chcp 65001 >nul

:: 设置模型路径
set MODEL_PATH=D:\AI\models\qwen3\Qwen3.5-0.8B-Q4_K_M-GGUF\qwen3.5-0.8b-Q4_K_M.gguf

:: 启动 llama-server
llama-server.exe ^
-m %MODEL_PATH% ^
--alias "qwen3/qwen3.5-0.8b" ^
-c 128000 ^
-b 512 ^
-t 4 ^
--mlock ^
--no-mmap ^
--port 8080

pause