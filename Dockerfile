FROM debian
RUN apt update
RUN apt install ssh wget npm -y
RUN npm install -g wstunnel
RUN wget https://raw.githubusercontent.com/MvsCode/frps-onekey/master/install-frps.sh -O ./install-frps.sh
RUN chmod 700 ./install-frps.sh
RUN sh -c '/bin/echo -e "2\n5130\n5131\n5132\n5133\nadmin\nadmin\n\n\n\n\n\n\n\n\n\n" | ./install-frps.sh install'
RUN mkdir /run/sshd
RUN echo 'wstunnel -s 0.0.0.0:80 &' >>/1.sh
RUN echo '/usr/sbin/sshd -D' >>/1.sh
RUN echo '/etc/init.d/frps restart' >>/1.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo root:uncleluo|chpasswd
RUN chmod 755 /1.sh
EXPOSE 80 8888 443 5130 5131 5132 5133 5134 5135 3306 9993/udp


## NOTE: to retain configuration; mount a Docker volume, or use a bind-mount, on /var/lib/zerotier-one

## Supports x86_64, x86, arm, and arm64

RUN apt-get update && apt-get install -y curl gnupg
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 0x1657198823e52a61  && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list
RUN apt-get update && apt-get install -y zerotier-one=1.8.4
COPY ext/installfiles/linux/zerotier-containerized/main.sh /var/lib/zerotier-one/main.sh

FROM debian:buster-slim
LABEL version="1.8.4"
LABEL description="Containerized ZeroTier One for use on CoreOS or other Docker-only Linux hosts."

# ZeroTier relies on UDP port 9993 

RUN mkdir -p /var/lib/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /usr/sbin/zerotier-one
COPY --from=builder /var/lib/zerotier-one/main.sh /main.sh

RUN chmod 0755 /main.sh

CMD  /1.sh
