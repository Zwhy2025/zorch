#!/bin/bash

# 获取脚本所在的目录路径
SCRIPT_DIR=$(dirname "$0")

# 切换到脚本所在的目录
cd "$SCRIPT_DIR" || exit

# 打印当前目录
echo "当前目录: $(pwd)"

# 清理旧的分发文件
rm -rf dist/*

# 创建新的分发文件
if ! python setup.py sdist; then
    echo "创建分发文件失败"
    exit 1
fi

# 安装分发文件
# 使用绝对路径确保安装的是正确版本的 Python 包
DIST_FILE=$(realpath dist/zorch-*.tar.gz)
if ! pip install "$DIST_FILE"; then
    echo "安装 Python 包失败"
    exit 1
fi

twine upload dist/*

echo "脚本执行成功"