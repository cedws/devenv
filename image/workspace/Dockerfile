FROM alpine

ARG SSH_PUBKEY

RUN apk add shadow git fish mise tini openssh-server curl

RUN adduser -D -s /usr/bin/fish nonroot
RUN usermod -p '*' nonroot
RUN ssh-keygen -A

ARG CHEZMOI_VERSION="2.63.1"
ARG CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_arm64.apk"

WORKDIR /tmp
RUN wget ${CHEZMOI_URL}
RUN apk add --allow-untrusted chezmoi_${CHEZMOI_VERSION}_linux_arm64.apk
RUN rm -f chezmoi_${CHEZMOI_VERSION}_linux_arm64.apk

RUN mkdir -p /home/nonroot/.zed_server /home/nonroot/.ssh /home/nonroot/.config/chezmoi

ARG ZED_VERSION="0.195.3"
ARG ZED_SERVER_URL="https://github.com/zed-industries/zed/releases/download/v${ZED_VERSION}/zed-remote-server-linux-aarch64.gz"

ADD $ZED_SERVER_URL /home/nonroot/.zed_server/zed-remote-server-stable-${ZED_VERSION}.gz
RUN gunzip /home/nonroot/.zed_server/zed-remote-server-stable-${ZED_VERSION}.gz
RUN chmod +x /home/nonroot/.zed_server/zed-remote-server-stable-${ZED_VERSION}

COPY chezmoi.toml /home/nonroot/.config/chezmoi/chezmoi.toml

RUN chown -R nonroot:nonroot /home/nonroot

USER nonroot
WORKDIR /home/nonroot
RUN chezmoi init --apply cedws

RUN echo ${SSH_PUBKEY} > /home/nonroot/.ssh/authorized_keys
RUN chmod 600 /home/nonroot/.ssh/authorized_keys

RUN mkdir /home/nonroot/project

COPY global.fish /etc/fish/conf.d/global.fish

USER root

ENTRYPOINT ["tini", "--", "/usr/sbin/sshd", "-D"]
