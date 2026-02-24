# macOS 开发环境一键安装脚本

一个简单的 shell 脚本，自动安装开发环境，换电脑后一键恢复。

## 当前配置

- ✅ **JDK 8 + JDK 11** (默认 11，支持快速切换)
- ✅ **Python 3.11** + pip + frida 15.2.2 + frida-tools 12.2.1
- ✅ **Git** + 基础配置
- ✅ **adb** (Android Debug Bridge)
- ✅ **Zsh 增强** (自动补全、语法高亮、模糊查找、美化提示符)

## JDK 版本切换

安装完成后，可以使用以下命令快速切换 JDK 版本：

```bash
jdk8      # 切换到 JDK 8
jdk11     # 切换到 JDK 11（默认）
jdkls     # 查看所有已安装的 JDK 版本
```

**示例：**

```bash
$ jdk8
已切换到 JDK 8
openjdk version "1.8.0_402"

$ jdk11
已切换到 JDK 11
openjdk version "11.0.22"

$ jdkls
已安装的 JDK 版本：
    1.8.0_402:  "Temurin 8"
    11.0.22:    "Temurin 11"

当前使用版本：
openjdk version "11.0.22"
```

## 使用方法

### 当前电脑（首次使用）

```bash
# 1. 运行安装脚本
./init.sh

# 2. 重启终端或运行
source ~/.zshrc

# 3. 验证安装
git --version
python3 --version
java -version
adb --version
```

### Zsh 增强功能说明

安装完成后，你的终端会有以下增强：

**1. 命令自动建议**
- 输入命令时会根据历史记录自动提示
- 按 `→` 右箭头键接受建议
- 按 `Ctrl+F` 也可以接受建议

**2. 语法高亮**
- 正确的命令显示**绿色**
- 错误的命令显示**红色**
- 实时检查命令是否存在

**3. 模糊查找（fzf）**
- `Ctrl+R` - 搜索历史命令（超好用！）
- `Ctrl+T` - 模糊搜索文件并插入路径
- `Alt+C` - 模糊搜索目录并跳转

**4. 美化提示符（Starship）**
- 显示当前目录
- 显示 Git 分支和状态
- 显示 Python/Node 版本
- 显示命令执行时间

**5. 常用别名**
```bash
ll      # 详细列表
gs      # git status
py      # python3
adbd    # adb devices
reload  # 重新加载配置
```

查看所有别名：`cat ~/.aliases`

### 新电脑（同步环境）

```bash
# 方法1: 克隆仓库后执行
git clone <你的仓库地址> ~/环境初始化shell
cd ~/环境初始化shell
./init.sh

# 方法2: 一行命令安装
bash <(curl -fsSL https://raw.githubusercontent.com/<你的用户名>/环境初始化/main/init.sh)
```

## 自定义安装内容

直接编辑 `init.sh`，在对应位置添加安装命令即可。

### 添加新的编程语言

```bash
# 添加 Node.js
log_info "检查 Node.js..."
if ! command -v node &>/dev/null; then
    brew install node
    log_success "Node.js 安装完成"
fi

# 添加 Go
brew install go
```

### 添加开发工具

```bash
# Docker
brew install docker docker-compose
brew install --cask orbstack

# 数据库
brew install mysql
brew install postgresql@15
brew install redis

# 其他工具
brew install maven    # Java 构建工具
brew install gradle   # Java 构建工具
```

### 添加 GUI 应用

```bash
brew install --cask visual-studio-code
brew install --cask iterm2
brew install --cask google-chrome
brew install --cask postman
```

## 常见问题

### Homebrew 安装很慢？

使用国内镜像：

```bash
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
./init.sh
```

### 更新已安装的软件

```bash
brew update && brew upgrade
```

### 添加更多 JDK 版本

如果需要安装其他版本（如 JDK 17, 21）：

```bash
# 安装 JDK 17
brew install --cask temurin@17

# 安装 JDK 21
brew install --cask temurin@21

# 在 ~/.zshrc 中添加切换函数
jdk17() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    export PATH=$JAVA_HOME/bin:$PATH
    echo "已切换到 JDK 17"
    java -version
}
```
