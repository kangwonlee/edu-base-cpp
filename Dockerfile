# begin Dockerfile

FROM ghcr.io/kangwonlee/edu-base-raw:14e3e21

USER root

RUN apk add --no-cache \
      cmake \
      make \
      gcc \
      g++ \
      musl-dev \
      valgrind \
      clang-extra-tools \
      && clang-format --version

RUN git clone --depth=1 --branch v0.3.5 https://github.com/kangwonlee/gemini-python-tutor /app/temp/ \
    && mkdir -p /app/ai_tutor/ \
    && mv /app/temp/*.py /app/ai_tutor \
    && mv /app/temp/locale/ /app/ai_tutor/locale/

RUN uv pip install --system --requirement /app/temp/requirements.txt \
    && rm -rf /app/temp \
    && chown -R runner:runner /app/ai_tutor/

COPY requirement.txt /app/requirements.txt

RUN uv pip install --system --requirement /app/requirements.txt \
    && rm /app/requirements.txt

USER runner

RUN uv pip list \
    && python3 -c "import pytest; import requests; import pycparser"

WORKDIR /tests/


# end Dockerfile
