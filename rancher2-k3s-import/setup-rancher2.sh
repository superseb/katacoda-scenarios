#!/bin/bash
if [ $HOSTNAME == "node01" ]; then
curlimage="appropriate/curl"
jqimage="stedolan/jq"
# Create password
RANCHER_PASSWORD=$(openssl rand -base64 12)

echo $RANCHER_PASSWORD > /root/rancher_password

until docker inspect rancher/rancher:master > /dev/null 2>&1; do
  docker pull rancher/rancher:master
  sleep 2
done

docker run --restart=unless-stopped -d -p 80:80 -p 443:443 rancher/rancher:master

while true; do
  docker run --rm --net=host $curlimage -sLk https://127.0.0.1/ping && break
  sleep 5
done

# Login
while true; do

    LOGINRESPONSE=$(docker run \
        --rm \
        --net=host \
        $curlimage \
        -s "https://127.0.0.1/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure)
    LOGINTOKEN=$(echo $LOGINRESPONSE | docker run --rm -i $jqimage -r .token)
    echo "Login Token is $LOGINTOKEN"
    if [ "$LOGINTOKEN" != "null" ]; then
        break
    else
        sleep 5
    fi
done

# Change password
docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"'"${RANCHER_PASSWORD}"'"}' --insecure

# Create API key
APIRESPONSE=$(docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure)

# Extract and store token
APITOKEN=`echo $APIRESPONSE | docker run --rm -i $jqimage -r .token`

# Configure server-url
RANCHER_SERVER="https://[[HOST2_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com"
docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/settings/server-url' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"server-url","value":"'"${RANCHER_SERVER}"'"}' --insecure

# Create import cluster
CLUSTERRESPONSE=$(docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"dockerRootDir":"/var/lib/docker","enableNetworkPolicy":false,"type":"cluster","name":"k3s"}' --insecure)

# Extract import command
CLUSTERID=`echo $CLUSTERRESPONSE | docker run --rm -i $jqimage -r .id`

IMPORTCMD=$(docker run \
    --rm \
    $curlimage \
      -sLk \
      -H "Authorization: Bearer $LOGINTOKEN" \
      "https://${RANCHER_SERVER}/v3/clusterregistrationtoken?clusterId=$CLUSTERID" | docker run --rm -i $jqimage -r '.data[].command' | head -1)

echo $IMPORTCMD > /root/importcmd

else
# Install k3s on node01
ssh -o StrictHostKeyChecking=no node01 "curl -sfL https://get.k3s.io | sh -"
until ssh -o StrictHostKeyChecking=no node01 "k3s kubectl get node"; do 
  sleep 2
done

# Run import command on node01
#ssh -o StrictHostKeyChecking=no node01 "k3s ${IMPORTCMD}"
fi
