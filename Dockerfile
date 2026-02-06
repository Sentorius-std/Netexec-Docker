FROM python:3.11-slim


# Install system deps
RUN apt-get update && apt-get install -y && apt-get install -y bash jq\
    git \
    libffi-dev \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install NetExec
RUN git clone https://github.com/Pennyw0rth/NetExec.git /opt/netexec
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

RUN pip install --upgrade pip
WORKDIR /opt/netexec
RUN pip install .

# Create output directory
RUN mkdir /output
RUN mkdir -p /data \
    && rm -rf /root/.nxc \
    && ln -s /data /root/.nxc

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
