#!/bin/bash -x
curlimage="appropriate/curl"
jqimage="stedolan/jq"

if [ $HOSTNAME == "node01" ]; then
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
CLUSTERRESPONSE=$(docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X POST --data-binary '{"dockerRootDir":"/var/lib/docker","enableNetworkPolicy":false,"type":"cluster","name":"k3s"}' --insecure)

# Extract import command
CLUSTERID=`echo $CLUSTERRESPONSE | docker run --rm -i $jqimage -r .id`

# Generate registrationtoken
docker run --rm --net=host $curlimage -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'"$CLUSTERID"'"}' --insecure

IMPORTCMD=$(docker run \
    --rm \
    --net=host \
    $curlimage \
      -s \
      -H "Authorization: Bearer $APITOKEN" \
      "https://127.0.0.1/v3/clusterregistrationtoken?clusterId=$CLUSTERID" --insecure | docker run --rm -i $jqimage -r '.data[].command' | head -1)

echo $IMPORTCMD > /root/importcmd

echo "Login to Rancher"
echo "$RANCHER_SERVER"
echo "Username: admin"
echo "Password: $(cat /root/rancher_password)"

else
RANCHER_HOSTNAME="[[HOST2_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com"
RANCHER_PASSWORD=$(ssh -o StrictHostKeyChecking=no node01 cat /root/rancher_password)

# Install k3s on node01
curl -sfL https://get.k3s.io | sh -

# wait for Rancher to be started
while true; do
  docker run --rm $curlimage -sLk https://$RANCHER_HOSTNAME/ping && break
  sleep 5
done

# Login
while true; do

    LOGINRESPONSE=$(docker run \
        --rm \
        $curlimage \
        -s "https://$RANCHER_HOSTNAME/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"'"${RANCHER_PASSWORD}"'"}' --insecure)
    LOGINTOKEN=$(echo $LOGINRESPONSE | docker run --rm -i $jqimage -r .token)

    if [ "$LOGINTOKEN" != "null" ]; then
        break
    else
        sleep 5
    fi
done

# Test if cluster is created
while true; do
  CLUSTERID=$(docker run \
    --rm \
    $curlimage \
      -sLk \
      -H "Authorization: Bearer $LOGINTOKEN" \
      "https://$RANCHER_HOSTNAME/v3/clusters?name=${cluster_name}" | docker run --rm -i $jqimage -r '.data[].id')

  if [ -n "$CLUSTERID" ]; then
    break
  else
    sleep 5
  fi
done

# Run import command on master
IMPORTCMD=$(ssh -o StrictHostKeyChecking=no node01 cat /root/importcmd)
k3s $IMPORTCMD
fi
