#!/usr/bin/env bash

# ============================================
# macOS 开发环境一键安装脚本
# ============================================
# 自动安装: JDK + Python3 + Git
# 使用方法: ./init.sh
# ============================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo ""
echo "============================================"
echo "  macOS 开发环境自动安装"
echo "============================================"
echo ""

# ============================================
# 1. 检查并安装 Homebrew
# ============================================
log_info "检查 Homebrew..."

if ! command -v brew &>/dev/null; then
    log_info "正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Apple Silicon Mac 添加到 PATH
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log_success "Homebrew 安装完成"
else
    log_success "Homebrew 已安装: $(brew --version | head -n1)"
fi

# ============================================
# 2. 安装 Git
# ============================================
log_info "检查 Git..."

if ! command -v git &>/dev/null; then
    log_info "正在安装 Git..."
    brew install git
    log_success "Git 安装完成"
else
    log_success "Git 已安装: $(git --version)"
fi

# 配置 Git
log_info "配置 Git..."
if [[ -z $(git config --global user.name) ]]; then
    read -p "请输入 Git 用户名: " GIT_USERNAME
    git config --global user.name "$GIT_USERNAME"
fi

if [[ -z $(git config --global user.email) ]]; then
    read -p "请输入 Git 邮箱: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi

git config --global init.defaultBranch main
log_success "Git 配置完成"

# ============================================
# 3. 安装 Python3
# ============================================
log_info "检查 Python3..."

if ! command -v python3 &>/dev/null || [[ $(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2) == "3.9" ]]; then
    log_info "正在安装 Python 3.11..."
    brew install python@3.11
    
    # 创建软链接
    brew link python@3.11
    
    log_success "Python3 安装完成"
else
    log_success "Python3 已安装: $(python3 --version)"
fi

# 配置 Python 环境
log_info "配置 Python 环境..."

# 配置 pip 允许全局安装
if [[ ! -f ~/.pip/pip.conf ]]; then
    log_info "配置 pip..."
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf <<'EOF'
[global]
break-system-packages = true
EOF
fi

log_info "当前 pip 版本: $(pip3 --version | cut -d' ' -f2)"

# 安装 Python 包
log_info "安装 Python 包..."
pip3 install \
    virtualenv \
    requests \
    pytest \
    frida==15.2.2 \


log_success "Python 包安装完成（frida 15.2.2 )"

# ============================================
# 4. 安装 Android Platform Tools (adb)
# ============================================
log_info "检查 adb..."

if ! command -v adb &>/dev/null; then
    log_info "正在安装 Android Platform Tools (adb)..."
    brew install android-platform-tools
    log_success "adb 安装完成"
else
    log_success "adb 已安装: $(adb --version | head -n1)"
fi

# ============================================
# 5. 安装 JDK 8 和 JDK 11
# ============================================
log_info "检查 JDK 版本..."

# 检查 JDK 8
if ! /usr/libexec/java_home -v 1.8 &>/dev/null; then
    log_info "正在安装 JDK 8 (Temurin)..."
    brew install --cask temurin@8
    log_success "JDK 8 安装完成"
else
    log_success "JDK 8 已安装"
fi

# 检查 JDK 11
if ! /usr/libexec/java_home -v 11 &>/dev/null; then
    log_info "正在安装 JDK 11 (Temurin)..."
    brew install --cask temurin@11
    log_success "JDK 11 安装完成"
else
    log_success "JDK 11 已安装"
fi

# 配置 JAVA_HOME 和版本切换函数
if ! grep -q "# JDK 版本管理" ~/.zshrc 2>/dev/null; then
    log_info "配置 JDK 版本切换功能..."
    
    cat >> ~/.zshrc <<'EOF'

# ============================================
# JDK 版本管理
# ============================================

# 默认使用 JDK 11
export JAVA_HOME=$(/usr/libexec/java_home -v 11 2>/dev/null)
export PATH=$JAVA_HOME/bin:$PATH

# JDK 版本切换函数
jdk8() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
    export PATH=$JAVA_HOME/bin:$PATH
    echo "已切换到 JDK 8"
    java -version
}

jdk11() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 11)
    export PATH=$JAVA_HOME/bin:$PATH
    echo "已切换到 JDK 11"
    java -version
}

# 查看所有已安装的 JDK 版本
jdkls() {
    echo "已安装的 JDK 版本："
    /usr/libexec/java_home -V 2>&1 | grep -E "^\s+[0-9]"
    echo ""
    echo "当前使用版本："
    java -version
}
EOF
    
    log_success "JDK 版本切换功能配置完成"
fi

# ============================================
# 5. 配置 Zsh 增强
# ============================================
log_info "配置 Zsh 增强功能..."

# 安装 zsh 增强插件
brew install zsh-autosuggestions zsh-syntax-highlighting fzf starship

log_success "Zsh 插件安装完成"

# 配置自动补全建议
if ! grep -q "zsh-autosuggestions" ~/.zshrc 2>/dev/null; then
    log_info "配置命令自动建议..."
    cat >> ~/.zshrc <<'EOF'

# ============================================
# Zsh 自动建议（根据历史命令）
# ============================================
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# 按右箭头键 → 接受建议
bindkey '^[[C' forward-char  # 右箭头
bindkey '^F' forward-char     # Ctrl+F 也可以接受建议
EOF
fi

# 配置语法高亮
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc 2>/dev/null; then
    log_info "配置语法高亮..."
    cat >> ~/.zshrc <<'EOF'

# ============================================
# Zsh 语法高亮（命令正确显示绿色，错误显示红色）
# ============================================
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
fi

# 配置 Starship 美化提示符
if ! grep -q "starship" ~/.zshrc 2>/dev/null; then
    log_info "配置 Starship 提示符..."
    cat >> ~/.zshrc <<'EOF'

# ============================================
# Starship 美化提示符
# ============================================
eval "$(starship init zsh)"
EOF
fi

# 创建常用别名
if [[ ! -f ~/.aliases ]]; then
    log_info "创建命令别名..."
    cat > ~/.aliases <<'EOF'
# ============================================
# 命令别名配置
# ============================================

# 目录操作
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'
alias la='ls -lAh'



# 系统
alias reload='source ~/.zshrc'


# 网络
alias ip='ipconfig getifaddr en0'
alias localip='ipconfig getifaddr en0'
alias publicip='curl -s https://api.ipify.org'

# 端口查看
port() {
    lsof -i ":$1"
}

# 快速启动 HTTP 服务器
server() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}
EOF
    
    # 在 .zshrc 中加载别名
    if ! grep -q ".aliases" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# 加载命令别名" >> ~/.zshrc
        echo "[[ -f ~/.aliases ]] && source ~/.aliases" >> ~/.zshrc
    fi
    
    log_success "命令别名配置完成"
fi

log_success "Zsh 增强配置完成"

# ============================================
# 6. 验证安装
# ============================================
echo ""
echo "============================================"
log_success "所有环境安装完成！"
echo "============================================"
echo ""

log_info "环境版本信息："
echo "  Git:     $(git --version)"
echo "  Python3: $(python3 --version)"
echo "  pip3:    $(pip3 --version | cut -d' ' -f1-2)"
echo "  adb:     $(adb --version 2>&1 | head -n1)"
echo ""
echo "  已安装的 JDK 版本："
/usr/libexec/java_home -V 2>&1 | grep -E "^\s+[0-9]" || echo "  未找到（可能需要重启终端）"
echo ""

log_info "重启终端或执行以下命令生效："
echo "  source ~/.zshrc"
echo ""

log_info "JDK 版本切换命令："
echo "  jdk8      # 切换到 JDK 8"
echo "  jdk11     # 切换到 JDK 11（默认）"
echo "  jdkls     # 查看所有已安装的 JDK 版本"
echo ""
