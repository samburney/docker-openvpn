# Original credit: https://github.com/jpetazzo/dockvpn
# Forked from: kylemanna/docker-openvpn

# Debian Minimal Image
FROM bitnami/minideb:stretch

LABEL maintainer="Sam Burney <sam@burney.io>"

# Needed for systemd
ENV container docker

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

# Install packages
RUN install_packages openvpn iptables quagga systemd wget openssl
RUN systemctl set-default multi-user.target

# Install easy-rsa 3.x
RUN cd /usr/local/share && wget -nv --no-check-certificate https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz && tar xf EasyRSA-3.0.4.tgz && mv EasyRSA-3.0.4 easy-rsa && rm EasyRSA-3.0.4.tgz
RUN ln -s /usr/local/share/easy-rsa/easyrsa /usr/local/bin

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/local/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp
VOLUME ["/etc/openvpn"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Fix openvpn.service so it creates the /dev/net/tun device
ADD ./service /lib/systemd/system
RUN mkdir -p /etc/systemd/system/basic.target.wants && ln -s /lib/systemd/system/openvpn-create-devices.service /etc/systemd/system/basic.target.wants/openvpn-create-devices.service

# Run systemd
RUN ln -s /lib/systemd/systemd /sbin/init
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]

# Add support for OTP authentication using a PAM module
#ADD ./otp/openvpn /etc/pam.d/
