#!/bin/bash

set -e  # 有错误就退出

# 检查 pyenv 是否存在
if ! command -v pyenv &> /dev/null; then
    echo "❌ pyenv 未安装，请先安装 pyenv。"
    exit 1
fi

# 检查 .python-version 文件是否存在
if [ ! -f ".python-version" ]; then
    echo "❌ 未找到 .python-version 文件。"
    exit 1
fi

PYTHON_VERSION=$(cat .python-version)

# 检查是否安装了指定版本的 Python
if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
    echo "🔧 安装 Python $PYTHON_VERSION ..."
    pyenv install "$PYTHON_VERSION"
fi

# 设置本地 Python 版本
echo "📌 设置 Python 版本为 $PYTHON_VERSION"
pyenv local "$PYTHON_VERSION"

# 创建并激活虚拟环境
VENV_DIR=".venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "🐍 创建虚拟环境 $VENV_DIR ..."
    python -m venv "$VENV_DIR"
fi

# 激活虚拟环境（仅对当前 shell 有效）
source "$VENV_DIR/bin/activate"

# 安装依赖
if [ ! -f "requirements.txt" ]; then
    echo "❌ 未找到 requirements.txt"
    deactivate
    exit 1
fi

echo "📦 安装依赖 ..."
pip install -r requirements.txt

# 数据初始化
echo "🛠 初始化数据库 ..."
python manage.py makemigrations
python manage.py migrate

echo "✅ 初始化完成！"