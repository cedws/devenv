FROM cgr.dev/chainguard/wolfi-base:latest

RUN apk add --no-cache tinyproxy

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY whitelist.txt /etc/tinyproxy/whitelist.txt

RUN mkdir -p /var/run/tinyproxy && \
    chown -R nonroot:nonroot /var/run/tinyproxy && \
    chown nonroot:nonroot /etc/tinyproxy/tinyproxy.conf && \
    chown nonroot:nonroot /etc/tinyproxy/whitelist.txt

EXPOSE 8888

USER nonroot

CMD ["tinyproxy", "-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]
