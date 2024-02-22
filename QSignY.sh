#!/bin/bash

# 添加颜色变量
RED="\e[31m"           # 红色
GREEN="\e[32m"         # 绿色
YELLOW="\e[33m"        # 黄色
RESET="\e[0m"          # 重置颜色

# 添加函数以显示不同颜色的消息
print_message() {
    local message="$1"
    local color="$2"
    echo -e "${color}${message}${RESET}"
}

# 定义协议内容
protocol="欢迎使用本程序，请阅读以下协议：

1. 本程序仅供学习和演示目的使用。
2. 禁止用于非法目的。
3. 禁止用于商业

如果您并不清楚这是什么，请立即退出该脚本
"

print_message "$protocol" "$YELLOW"

sleep 3

# 提示用户输入确认信息
read -p "请输入'我同意该协议'以同意协议并确认您了解您的操作： " confirmation

# 判断用户输入是否正确
if [ "$confirmation" != "我同意该协议" ]; then
    print_message "您的确认信息不正确，程序将退出" "$RED"
    exit 1
fi

# 检查是否具有 root 权限
if [ "$(whoami)" != "root" ]; then
    print_message "请使用 root 权限执行本脚本！" "$RED"
    exit 1
fi

print_message "正在下载并检查所需软件包，请稍等..." "$GREEN"

sleep 1

# 函数：安装软件包
install_package() {
    local package_name="$1"
    local message="$2"

    if ! command -v "$package_name" &> /dev/null; then
        print_message "$message" "$YELLOW"
        
        if command -v apt &> /dev/null; then
            apt install -y "$package_name" > /dev/null
        elif command -v apt-get &> /dev/null; then
            apt-get install -y "$package_name" > /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y "$package_name" > /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y "$package_name" > /dev/null
        elif command -v pacman &> /dev/null; then
            pacman -Syu --noconfirm "$package_name" > /dev/null
        else
            print_message "无法确定操作系统的包管理器，请手动安装软件包 $package_name" "$RED"
            exit 1
        fi
        print_message "$package_name 工具安装完成" "$GREEN"
    else
        print_message "已安装 $package_name 工具，跳过安装" "$GREEN"
    fi
}

# 检查并安装 pv
install_package "pv" "未检测到 pv 工具，开始安装..."

sleep 1

# 检查并安装 git
install_package "git" "未检测到 git 工具，开始安装..."

sleep 1

install_package "tmux" "未检测到 tmux 工具，开始安装…"

sleep 1

install_package "jq" "未检测到 jq 工具，开始安装…"

# 检查是否安装 jdk
if ! command -v java &> /dev/null; then
    print_message "未检测到 Java 环境，开始安装 JDK..." "$YELLOW"

    if command -v apt &> /dev/null; then
        apt update > /dev/null
        apt install -y openjdk-11-jdk > /dev/null
    elif command -v apt-get &> /dev/null; then
        apt-get update > /dev/null
        apt-get install -y openjdk-11-jdk > /dev/null
    elif command -v dnf &> /dev/null; then
        dnf update -y > /dev/null
        dnf install -y java-11-openjdk-devel > /dev/null
    elif command -v yum &> /dev/null; then
        yum update -y > /dev/null
        yum install -y java-11-openjdk-devel > /dev/null
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm jdk11-openjdk > /dev/null
    else
        print_message "无法确定操作系统的包管理器，请手动安装 Java JDK" "$RED"
        exit 1
    fi
    print_message "Java JDK 环境安装完成" "$GREEN"
else
    print_message "已安装 Java 环境，跳过安装" "$GREEN"
fi

sleep 1

cd /home

# 如果非第一次启动
if [ -d "/home/QSignY" ]; then
    options=("启动 QSign脚本" "重新配置 QSign" "退出脚本")

    PS3="发现已有目录 QSignY，请选择操作: "
    select choice in "${options[@]}"; do
        case $choice in
            "启动 QSign脚本")
                if [ -f "/home/QSignY/QSign.sh" ]; then
                    cd /home/QSignY
                    ./QSign.sh
                    exit
                else
                    print_message "文件 QSign.sh 不存在，请重新配置（若是 nohup 管理请直接使用 nohup 命令）" "$RED"
                    exit 1
                fi
                ;;
            "重新配置 QSign")
                print_message "正在进入配置流程中..." "$YELLOW"
                rm -r "/home/QSignY"
                sleep 1
                break
                ;;
            "退出脚本")
                print_message "已退出脚本，Have a Fun!" "$RED"
                exit 0
                break
                ;;
            *)
                print_message "输入错误，无效的选择！" "$RED"
                ;;
        esac
    done
fi

# 提示用户选择线路
options=("国内线路" "国外线路")

# 显示菜单
PS3="请选择线路："
select option in "${options[@]}"; do
    case "$REPLY" in
        1) # 选择了国内线路
            break
            ;;
        2) # 选择了国外线路
            break
            ;;
        *)
            print_message "输入错误，请重新输入！" "$RED"
            ;;
    esac
done

sleep 1

print_message "正在下载 QSign，请稍等..." "$GREEN"

# 下载相应线路的压缩包
if [ "$option" == "国内线路" ]; then
    cd /home
    git clone --depth=1 https://gitee.com/theqingyao/QSignY ./QSignY  # 国内镜像地址
else
     cd /home
     git clone --depth=1 https://github.com/yusheng929/QSignY ./QSignY # 原始地址
fi

# 下载文件并检查错误
if [ ! -e "/home/QSignY/QSign.sh" ]; then
    print_message "下载失败，请检查网络连接或稍后再试" "$RED"
    exit 1
fi

sleep 1

# 查找 Java 路径并设置 JAVA_HOME
java_path=$(readlink -f $(which java))
if [ -n "$java_path" ]; then
    java_home=$(dirname $(dirname "$java_path"))
    export JAVA_HOME="$java_home"
    print_message "已设置 JAVA_HOME 为：$JAVA_HOME" "$GREEN"
else
    print_message "未找到 Java 安装路径，等待程序自动识别" "$YELLOW"
fi

sleep 1

# 进入解压后的文件夹
cd /home/QSignY

# 给予脚本执行权限
    chmod +x "QSign.sh"
    mv /home/QSignY/y /usr/local/bin
    chmod +x "/usr/local/bin/y"
    chmod +x "QSignYS.sh"
    chmod +x "app"

    print_message "下载脚本成功，5 秒钟后启动...脚本快捷键为y" "$GREEN"

    sleep 5

    # 运行脚本
    ./QSign.sh
    rm -rf /home/QSignY/QSignY.sh