# 一键脚本
apt update && apt-get update

# 查看cuda版本
nvidia-smi

# 实时监控：在终端输入以下命令，即可每秒自动刷新 GPU 状态（包括利用率、显存占用、温度等）
watch -n 1 nvidia-smi

# 检查实际安装的 CUDA Toolkit 版本
nvcc --version

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb

dpkg -i cuda-keyring_1.1-1_all.deb && apt-get update 

apt-get install -y cuda-toolkit-12-4

# 配置环境变量
tee /etc/profile.d/cuda.sh > /dev/null << 'EOF'
export PATH=/usr/local/cuda-12.4/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:${LD_LIBRARY_PATH}
EOF

# 立即加载：
source /etc/profile.d/cuda.sh

# 检查环境变量：
echo $PATH          # 应包含 /usr/local/cuda-12.4/bin
nvcc --version      # 应显示 CUDA 12.4 编译器版本

# 下载模型
# 1. 安装/更新下载工具
python3 -m pip install -U huggingface_hub hf_xet

# 2. 创建模型存放目录
mkdir -p /data/coding/models/qwen3/qwen3.6

# 3. 下载指定的 GGUF 模型文件
hf download HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive \
  Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf \
  --local-dir /data/coding/models/qwen3/qwen3.6


# 运行llama.cpp
/data/coding/llama.cpp/build/bin/llama-server \
-m "/data/coding/models/qwen3/qwen3.6/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf" \
--alias "qwen3/Qwen3.6-35B-A3B-UD-Q4_K_M" \
--fit on \
--fit-ctx 131072 \
--fit-target 256 \
-c 131072 \
-b 2048 \
-ub 2048 \
-t 8 \
--n-cpu-moe 8 \
--no-mmap \
--cache-type-k q4_0 \
--cache-type-v q4_0 \
--temp 0.3 \
--reasoning 'default' \
--batch-size 512 \
--parallel 4 \
--ubatch-size 512 \
--host 0.0.0.0 \
--port 8081


# 安装cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
mv ./cloudflared-linux-amd64 ./cloudflared && chmod +x cloudflared

./cloudflared service install eyJhIjoiYmYzYWIzMWM5NGRkNjBhYTM3MDc2OGNjNThlOGU1YWEiLCJ0IjoiODc3OTJkM2YtZjI0My00YzU5LTk0MDQtMDhiNTAxZjU0M2VkIiwicyI6Ik5UVXlPVFl5TjJFdE16ZzNaaTAwWmpkbUxXSXhaamd0T0RneU1HRTBPVFF6WVRJeiJ9


