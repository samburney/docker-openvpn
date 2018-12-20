# Original credit: https://github.com/jpetazzo/dockvpn
# Forked from: kylemanna/docker-openvpn

# linuxserver.io Alpine 3.8 image
FROM lsiobase/alpine:3.8

LABEL maintainer="Sam Burney <sam@burney.io>"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester frr && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

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

# Copy system files
RUN rm /etc/cont-init.d/10-adduser
COPY ./root/ /
RUN chmod a+x /usr/local/bin/*

# Be compatible with old Quagga configs
RUN ln -s /etc/frr /etc/quagga

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

# Start s6-init
ENTRYPOINT ["/init"]
