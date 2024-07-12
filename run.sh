#!/bin/bash
# 定义模型目录和模型名称
MODEL_DIR="/app/model"
MODEL_NAME="meta-llama/Meta-Llama-3-70B-Instruct"
# 检查模型是否已经存在
if [ -d "$MODEL_DIR/$MODEL_NAME" ]; then
  echo "模型已存在，运行应用程序。"
else
  echo "模型不存在，开始下载模型..."
  mkdir -p $MODEL_DIR
  huggingface-cli download --token "$HUGGINGFACE_TOKEN" $MODEL_NAME -d $MODEL_DIR
  if [ $? -ne 0 ]; then
    echo "模型下载失败，请检查您的 Hugging Face token 和模型名称。"
    exit 1
  fi
  echo "模型下载完成。"
fi
# 运行应用程序
python /app/app.py
