# FROM image.sourcefind.cn:5000/dcu/admin/base/pytorch:1.13.1-ubuntu20.04-dtk-23.04-py39-latest
# RUN pip install --no-cache-dir transformers langchain langchain-huggingface accelerate
# COPY . /app
# ENV HF_ENDPOINT=https://hf-mirror.com
# RUN pip install auto-gptq --no-build-isolation --extra-index-url https://huggingface.github.io/autogptq-index/whl/rocm573/
# CMD ["/app/run.sh"]

FROM rocm/dev-ubuntu-22.04:6.0.2

LABEL maintainer="Hugging Face"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    libsndfile1-dev \
    tesseract-ocr \
    espeak-ng \
    rocthrust-dev \
    hipsparse-dev \
    hipblas-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    python -m pip install -U pip

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0 --no-cache-dir
RUN pip install -U --no-cache-dir ninja packaging git+https://github.com/facebookresearch/detectron2.git pytesseract "itsdangerous<2.1.0"

ARG FLASH_ATT_V2_COMMIT_ROCM=2554f490101742ccdc56620a938f847f61754be6

RUN git clone https://github.com/ROCm/flash-attention.git flash-attention-v2 && \
    cd flash-attention-v2 && git submodule update --init --recursive && \
    GPU_ARCHS="gfx90a;gfx942" PYTORCH_ROCM_ARCH="gfx90a;gfx942" python setup.py install && \
    cd .. && \
    rm -rf flash-attention

COPY . /app
WORKDIR /app
RUN git clone --depth 1 --branch main https://github.com/huggingface/transformers.git && cd transformers
RUN pip install --no-cache-dir -e ./transformers[dev-torch,testing,video]
RUN pip uninstall -y tensorflow flax
RUN pip install auto-gptq --no-build-isolation --extra-index-url https://huggingface.github.io/autogptq-index/whl/rocm573/

ENV HF_ENDPOINT=https://hf-mirror.com
CMD ["/app/run.sh"]
