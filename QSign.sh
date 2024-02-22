#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

QSVersion=1.1.0

LANG=en_US.UTF-8

script_shell="$(readlink /proc/$$/exe | sed "s/.*\///")"
if [[ "${script_shell}" != "bash" ]]; then
	echo "请使用bash命令执行本脚本！"
	exit 1
fi

if [ "$(whoami)" != "root" ]; then
	echo "请使用root权限执行本脚本！"
	exit 1
fi

if [ -z "$1" ]; then
	echo "请选择操作:"
	echo "0.重新定义jdk路径"
	echo "1. 重启 qsign"
	echo "2. 停止 qsign"
	echo "3. 启动 qsign"
	echo "4. 修改 qsign 版本"
	echo "5. 卸载 qsign 服务"
	echo "6. 查看签名服务状态"
	echo "7. 打开 qsign 日志"
	echo "8. 修改签名端口"
	echo "当前脚本版本:$QSVersion"
	echo "温馨提示，脚本快捷键为小写y，默认端口为7860，密钥为Y"
	echo -n "请输入数字选项: "
	
	# shellcheck disable=SC2162
	read option
else
	option=$1
fi

case $option in
0)
	# 定义可能的 JDK 路径
	jdk_paths=(
		"/usr/lib/jvm"
		"/usr/local/java"
		"/usr/local/btjdk"
	)

	# 检查 JAVA_HOME 环境变量
	if [ -z "$JAVA_HOME" ]; then
		echo -e "\nJAVA_HOME 环境变量未找到，将查找可能的 JDK 安装目录。"

		jdk_found=false

		# 在可能的路径中查找 JDK
		for path in "${jdk_paths[@]}"; do
			if [[ -d "$path" ]]; then
				# shellcheck disable=SC2207
				jdk_dirs=($(ls -d "$path"/*jdk* 2>/dev/null))
				if [[ ${#jdk_dirs[@]} -gt 0 ]]; then
					jdk_found=true
					for jdk_dir in "${jdk_dirs[@]}"; do
						if [[ -d "$jdk_dir/jre" && ! -d "$jdk_dir/bin" ]]; then
							jdk_dir="$jdk_dir/jre"
							break
						fi
					done
					break
				fi
			fi
		done

		# 输出结果
		if [[ $jdk_found == true ]]; then
			if [[ -n "$jdk_dir" ]]; then
				echo "JDK is installed at: ${jdk_dir}"
				export JAVA_HOME="${jdk_dir}"
			else
				echo "JDK is installed at: ${jdk_dirs[0]}"
				export JAVA_HOME="${jdk_dirs[0]}"
			fi
		else
			echo "没有找到 JDK 目录，请先安装或设置 JAVA_HOME 环境变量！"
			exit 1
		fi
	fi

	#必须判断工作目录
	script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" #脚本目录
	current_dir="$PWD"                                         #当前环境目录
	if [ "$current_dir" != "$script_dir" ]; then
		echo -e "\n当前目录与脚本所在目录不一致，正在切换到脚本目录...\n"
		cd "$script_dir"
	fi

	# 检查 unidbg-fetch-qsign 是否存在
	if [ ! -f "bin/unidbg-fetch-qsign" ]; then
		echo "错误：找不到 unidbg-fetch-qsign 文件！"
		exit 1
	fi
    ;;

1)
	tmux kill-session -t QSign
    chmod +x /home/QSignY/app
    tmux new-session -d -s QSign -n "QSign" "cd /home/QSignY && ./app; sleep infinity"
	echo "开始执行重启操作，少女祈祷中…"
	sleep 3
	clear
	exec /home/QSignY/QSign.sh
	;;
2)
	tmux kill-session -t QSign
	echo "已经关闭签名服务，少女祈祷中…"
	sleep 3
	clear
	exec /home/QSignY/QSign.sh
	;;
3)
	if tmux has-session -t QSign 2>/dev/null; then
    echo -e "\e[36m签名正在运行中，\e[35m少女祈祷中~\e[0m"
    sleep 3
    clear
    exec /home/QSignY/QSign.sh
else
    echo -e "\e[31m签名不存在，\e[36m正在启动签名，\e[0m\e[35m少女祈祷中~\e[0m"
    sleep 2
    chmod +x /home/QSignY/app
    tmux new-session -d -s QSign -n "QSign" "cd /home/QSignY && ./app; sleep infinity"
    exec /home/QSignY/QSign.sh
    fi
	;;
4)
	while true; do
    # 提示用户输入版本信息
    echo "当前可用版本:"
    version_count=1
    for dir in /home/QSignY/txlib/*; do
        if [ -d "$dir" ]; then
            echo "$version_count. $(basename $dir)"
            ((version_count++))
        fi
    done
    
    read -p "请输入版本序号: " version_number

    # 检查用户输入的序号是否在范围内
    total_versions=$(ls -l /home/QSignY/txlib/ | grep -c ^d)
    if [ $version_number -ge 1 ] && [ $version_number -le $total_versions ]; then
        # 获取用户选择的版本
        version=$(ls /home/QSignY/txlib/ | sed -n ${version_number}p)
        
        tmux kill-session -t QSign
        echo -e "\033[1;36m修改成功\033[0m，\033[1;35m少女祈祷中...\033[0m"

        # 读取app文件内容并修改android_version字段
        app_path="/home/QSignY/app"
        sed -i "s/android_version=.*/android_version=$version/g" "$app_path"

        # 给app文件赋予可执行权限
        chmod +x /home/QSignY/app
        
        sleep 3
        clear
      
        exec /home/QSignY/QSign.sh

        break
    else
        echo "输入错误，请重新输入版本序号"
        # 继续循环，提示用户重新输入版本序号
    fi
done

	;;
5)
    rm -rf /usr/local/bin/y
    echo -e "\033[0;31m少女为你痛哭\033[0m"
    sleep 2
    clear
    rm -rf /home/QSignY
	;;
6)
    clear
    echo -e "\e[94m正在为您查询\e[0m，\e[95m少女祈祷中…\e[0m"
    sleep 3
	# 读取app文件中的android_version
qsign_version=$(grep -oP 'android_version=\K[^ ]+' /home/QSignY/app)

# 输出当前签名版本
echo -e "当前签名版本为 [\e[94m$qsign_version\e[0m]"

# 读取config.json文件中的key
key=$(grep -oP '"key": "\K[^" ]+' /home/QSignY/txlib/$qsign_version/config.json)

# 输出当前密钥key
echo -e "当前密钥key为 [\e[94m$key\e[0m]"

# 检查QSign的tmux会话状态
if tmux list-sessions | grep -q "QSign"; then
  echo -e "签名服务状态 [\e[92m已启动\e[0m]"
  else
  echo -e "签名服务状态 [\e[91m未启动\e[0m]"
fi
	;;
7)
	tmux attach-session -t QSign
	;;
8)
while true; do
    read -p "请输入端口号：" port_input
    
    if [[ -z $port_input ]] || ! [[ $port_input =~ ^[0-9]+$ ]] || ((port_input < 0)) || ((port_input > 65536)); then
        echo "输入错误，请重新输入"
        continue
    fi
    
    port=$port_input
    
    if ((port > 65535)); then
        echo "当前输入端口超出范围，请输入1024-65535之间的端口号"
        continue
    fi
    
    if ((port >= 0 && port <= 1023)); then
        echo "当前输入端口为系统端口，可能会导致签名无法正常运行，是否要设置为$port？"
        read -p "Y/N: " confirm
        
        if [[ $confirm == "Y" || $confirm == "y" ]]; then
            app_file="/home/QSignY/app"
            sed -i 's/\(URL="http:\/\/127\.0\.0\.1:\)[0-9]*\(\/sign"\)/\1'"$port"'\2/' $app_file
            
            for config_file in /home/QSignY/txlib/*/config.json; do
                sed -i 's/\("port":[[:space:]]*\)[0-9]*/\1'"$port"'/' $config_file
            done
            echo "修改成功"
            
            break
        fi
        
    elif ((port >= 1024 && port <= 65535)); then
        app_file="/home/QSignY/app"
        sed -i 's/\(URL="http:\/\/127\.0\.0\.1:\)[0-9]*\(\/sign"\)/\1'"$port"'\2/' $app_file
        
        for config_file in /home/QSignY/txlib/*/config.json; do
            sed -i 's/\("port":[[:space:]]*\)[0-9]*/\1'"$port"'/' $config_file
        done
        echo "修改成功"
        
        break
    
    else
        echo "已取消"
        continue
    fi
    done
    ;;
esac