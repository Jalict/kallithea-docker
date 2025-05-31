FROM python:3.13-alpine

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    KALLITHEA_HOME=/opt/kallithea \
    VENV_PATH=/opt/venv \
    KALLITHEA_CONFIG=/opt/kallithea/my.ini \
    REPO_ROOT=/opt/repos

# Install system dependencies
RUN apk add --no-cache \
    git \
    mercurial \
    npm \
    bash \
    build-base \
    libffi-dev \
    openssl-dev \
    gettext \
    musl-dev \
    gcc \
    py3-pip \
    py3-wheel \
    py3-setuptools \
    linux-headers \
    curl

# Create kallithea user and necessary dirs
RUN adduser -D -h /home/kallithea kallithea && \
    mkdir -p $KALLITHEA_HOME $REPO_ROOT && \
    chown -R kallithea:kallithea /opt

USER kallithea
WORKDIR $KALLITHEA_HOME

# Clone stable branch
RUN hg clone https://kallithea-scm.org/repos/kallithea -u stable $KALLITHEA_HOME

# Set up virtualenv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --upgrade -e .

# Compile translation catalogs
RUN python3 setup.py compile_catalog

# Build front-end
RUN kallithea-cli front-end-build

# Copy entrypoint
COPY --chown=kallithea:kallithea entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5000
CMD ["/entrypoint.sh"]
