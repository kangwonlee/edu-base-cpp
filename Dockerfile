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
      wget \
      unzip \
      tar \
      gzip \
      openjdk11-jre \
      && clang-format --version \
      && java --version  # Verify Java installation

# Install CodeQL CLI and bundle
RUN wget -q https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.18.2/codeql-bundle-linux64.tar.gz \
    && mkdir -p /opt/codeql \
    && tar -xzf codeql-bundle-linux64.tar.gz -C /opt/codeql \
    && rm -rf /opt/codeql/codeql/tools/linux64/java \
    && rm codeql-bundle-linux64.tar.gz \
    && chmod -R +x /opt/codeql

# Set JAVA_HOME to system Java and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH="/opt/codeql/codeql:${JAVA_HOME}/bin:${PATH}"

RUN git clone --depth=1 --branch v0.3.5 https://github.com/kangwonlee/gemini-python-tutor /app/temp/ \
    && mkdir -p /app/ai_tutor/ \
    && mv /app/temp/*.py /app/ai_tutor \
    && mv /app/temp/locale/ /app/ai_tutor/locale/

RUN uv pip install --system --requirement /app/temp/requirements.txt \
    && rm -rf /app/temp \
    && chown -R runner:runner /app/ai_tutor/

COPY ./requirements.txt /app/requirements.txt

RUN uv pip install --system --requirement /app/requirements.txt \
    && rm /app/requirements.txt

USER runner

RUN uv pip list \
    && clang-format --version \
    && java --version \
    && python3 -c "import pytest; import requests; import clang.cindex" \
    && JAVA_HOME=${JAVA_HOME} codeql --version  # Verify CodeQL with system Java

WORKDIR /tests/

# end Dockerfile
