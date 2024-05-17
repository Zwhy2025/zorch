#!/bin/bash

# 获取脚本所在的目录路径
SCRIPT_DIR=$(dirname "$0")

# 切换到脚本所在的目录
cd "$SCRIPT_DIR" || exit

# 打印当前目录
echo "当前目录: $(pwd)"

# 读取当前版本号
CURRENT_VERSION=$(grep -oP '__version__ = '\''\K\d+\.\d+\.\d+' zorch/__init__.py)
echo "当前版本号: $CURRENT_VERSION"

# 解析版本号
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# 增加 PATCH 部分
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# 更新版本号到文件
sed -i "s/__version__ = '.*'/__version__ = '$NEW_VERSION'/" zorch/__init__.py

# 打印新版本号
echo "新版本号: $NEW_VERSION"

# 清理旧的分发文件
rm -rf dist/*

# 打包新的分发文件
if ! python setup.py sdist; then
    echo "创建分发文件失败"
    exit 1
fi

# 安装分发文件
DIST_FILE=$(realpath dist/zorch-*.tar.gz)
if ! pip install "$DIST_FILE"; then
    echo "安装 Python 包失败"
    exit 1
fi

# 打印安装后的版本号
INSTALLED_VERSION=$(python -c "import zorch; print(zorch.__version__)")
echo "安装后的新版本号: $INSTALLED_VERSION"

# 上传分发文件
if ! twine upload dist/*; then
    echo "上传分发文件失败"
    exit 1
fi

echo "脚本执行成功"
