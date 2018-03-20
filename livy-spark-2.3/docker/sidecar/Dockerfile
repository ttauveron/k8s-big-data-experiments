FROM alpine
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl -P /usr/local/bin/ && \
    chmod +x /usr/local/bin/kubectl
EXPOSE 8443
ENTRYPOINT ["/usr/local/bin/kubectl", "proxy"]
