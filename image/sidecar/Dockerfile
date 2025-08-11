FROM cgr.dev/chainguard/wolfi-base:latest

RUN apk add --no-cache socat

ENV TARGET_CONTAINER=project
ENV TARGET_PORT=22
ENV LISTEN_PORT=22

EXPOSE 22

USER nonroot

CMD socat TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr TCP:${TARGET_CONTAINER}:${TARGET_PORT}
