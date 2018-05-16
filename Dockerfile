# Original credit: https://github.com/jpetazzo/dockvpn
# Forked from: kylemanna/docker-openvpn

# Debian Minimal Image
FROM bitnami/minideb:stretch

LABEL maintainer="Sam Burney <sam@burney.io>"

# Install packages
RUN install_packages openvpn iptables quagga systemd wget openssl

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

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
#ADD ./otp/openvpn /etc/pam.d/
