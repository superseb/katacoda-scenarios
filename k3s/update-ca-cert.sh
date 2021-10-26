apt update && apt -y install ca-certificates && sed -i -e 's=^mozilla/DST_Root_CA_X3.crt=!mozilla/DST_Root_CA_X3.crt=' /etc/ca-certificates.conf && update-ca-certificates
