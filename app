#!/bin/bash

# 设置签名安卓版本
android_version=8.9.83
# 服务正常重新检测间隔 （秒
time=30
URL="http://127.0.0.1:7860/sign"

while true; do

  script_dir=$(cd "$(dirname "$0")" && pwd)
  echo -e "\e[1;33m位于$script_dir\e[0m"
  echo -e "\e[1;36m少女祈祷中...\e[0m"

  # 启动 QSign 签名服务
  bash bin/unidbg-fetch-qsign --basePath=txlib/$android_version &
  # 多人用会很卡 等一会再启动检测
  sleep 60

  while true; do

# 指定配置文件路径
config_file="txlib/$android_version/config.json"

# 检查配置文件是否存在
if [ ! -f "$config_file" ]; then
  echo "$android_version 安卓版本错误"
  sleep 114514
  exit
fi

# 使用jq工具来解析JSON并提取qua字段的内容
qua=$(jq -r '.protocol.qua' "$config_file")

# 检查qua字段是否存在
if [ -z "$qua" ]; then
  echo "配置文件中没有找到qua字段"
  sleep 114514
  exit
fi

    response=$(curl --max-time 15 -X POST -H "Content-Type: application/x-www-form-urlencoded" --data "uin=114514&qua="$qua"&cmd=sign&seq=1848698645&buffer=0C099F0C099F0C099F&guid=123456&android_id=114514" $URL)

    if [ $? -ne 0 ]; then
      echo "curl请求失败"
      echo "服务异常 3秒后重启"
      sleep 3
      pkill -f unidbg-fetch-qsign
      break
    fi

    code=$(echo "$response" | jq -r '.code')

    if ! [[ "$code" =~ ^[0-9]+$ ]]; then
      echo "无效的code值: $code"
      echo "服务异常 3秒后重启"
      sleep 3
      pkill -f unidbg-fetch-qsign
      break
    fi

    if [ "$code" -eq 0 ]; then
    echo "↓>-----------------------------------------------<↓"
      echo "$response"
      echo "服务正常 $time 秒后重新检测"
    else
      echo "$response"
      echo "服务异常 3秒后重启"
      sleep 3
      pkill -f unidbg-fetch-qsign
      break
    fi

    echo "↑>-----------------------------------------------↑<"
    sleep $time
  done
done

exit
