# Use the official Golang base image
FROM golang:1.21.3-alpine

# Set the environment variables
ENV GLIBC_VER=2.33-r0

# Install dependencies
RUN apk --no-cache add \
    curl \
    bash \
    python3

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Verify installations
RUN gcloud version && \
    gsutil version -l && \
    kubectl version --client

# Set the working directory
WORKDIR /go/src/app

COPY scripts/monitor.sh .

CMD ["./monitor.sh"]
