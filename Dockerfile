FROM python:3.10-slim

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    KALLITHEA_HOME=/opt/kallithea \
    VENV_PATH=/opt/venv \
    KALLITHEA_CONFIG=/opt/kallithea/my.ini \
    REPO_ROOT=/opt/repos

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    mercurial \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create kallithea user and necessary dirs
RUN useradd -ms /bin/bash kallithea
RUN mkdir -p $KALLITHEA_HOME $REPO_ROOT && chown -R kallithea:kallithea /opt

USER kallithea
WORKDIR $KALLITHEA_HOME

# Clone stable branch
RUN hg clone https://kallithea-scm.org/repos/kallithea -u stable $KALLITHEA_HOME

# Set up virtualenv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Install dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --upgrade -e .

# Compile translation catalogs
RUN python3 setup.py compile_catalog

# Prepare front-end
RUN kallithea-cli front-end-build

# Copy entrypoint
COPY --chown=kallithea:kallithea entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5000
CMD ["/entrypoint.sh"]
