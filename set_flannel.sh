#!/bin/bash
mkdir -p /etc/cni/net.d/
cat <<EOF> /etc/cni/net.d/10-flannel.conf
{
"name": "cbr0",
"type": "flannel",
"delegate": {
"isDefaultGateway": true
}
}
EOF

mkdir /usr/share/oci-umount/oci-umount.d -p
mkdir -p /run/flannel/

cat <<EOF> /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
