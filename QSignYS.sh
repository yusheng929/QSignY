#!/bin/bash

QSignsh_URL="https://raw.githubusercontent.com/yusheng929/QSignY/main/QSign.sh"
Qnew=/home/QSignY/QSignnew.sh

content=$(cat /home/QSignY/QSign.sh)

# 使用正则表达式匹配版本号
QSVersionold=$(grep -oP '(?<=QSVersion=)[^"]+' /home/QSignY/QSign.sh)

# 下载云端脚本
curl -o $Qnew $QSignsh_URL

# 获取脚本版本
QSVersionNEW=$(grep -oP '(?<=QSVersion=)[^"]+' /home/QSignY/QSignnew.sh)

# 检测版本是否一致
if [ "$QSVersionold" = "$QSVersionNEW" ]; then
    # 版本号一致，运行指定命令
    rm /home/QSignY/QSignnew.sh
    chmod +x /home/QSignY/QSign.sh
    cd /home/QSignY && bash QSign.sh
else
    # 版本号不一致，开始更新
    echo "发现新版本，是否更新[Y/n]: "
    read choice
    choice=${choice:-Y}
    if [[ $choice == "Y" || $choice == "y" ]]; then
        echo "正在更新..."
        sleep 2
        
        # 执行更新操作
        cd /home/QSignY && git pull --no-rebase
        
        if [ $? -eq 0 ]; then
            echo "更新完成，正在启动"
            sleep 2
            chmod +x /home/QSignY/QSign.sh
            cd /home/QSignY && bash QSign.sh
        else
            echo "更新出现冲突，是否强制更新[Y/n]: "
            read force_choice
            choice=${choice:-Y}
            if [[ $force_choice == "Y" || $force_choice == "y" ]]; then
                echo "强制更新..."
                sleep 2
                
                # 强制更新并且丢弃本地修改
                cd /home/QSignY && git checkout . && git pull --no-rebase
                
                rm /usr/local/bin/y
                mv /home/QSignY/y /usr/local/bin/y
                chmod +x /usr/local/bin/y
                chmod +x /home/QSignY/QSign.sh
                echo "更新完成，正在启动"
                sleep 2
                cd /home/QSignY && bash QSign.sh
            else
                echo "取消更新，正在启动中"
                sleep 2
                cd /home/QSignY && bash QSign.sh
            fi
        fi
        
    else
        echo "正在启动中"
        sleep 2
        cd /home/QSignY && bash QSign.sh
    fi
fi