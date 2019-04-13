#!/bin/bash -x
curlimage="appropriate/curl"
jqimage="stedolan/jq"

for image in $curlimage $jqimage; do
  until docker inspect $image > /dev/null 2>&1; do
    docker pull $image
    sleep 2
  done
done

if [ $HOSTNAME == "node01" ]; then
    # Create password
    RANCHER_PASSWORD=$(openssl rand -base64 12)
    
    echo $RANCHER_PASSWORD > /root/rancher_password
    
    until docker inspect rancher/rancher:latest > /dev/null 2>&1; do
      docker pull rancher/rancher:latest
      sleep 2
    done

    RANCHER_VERSION=$(docker run --rm --net=host $curlimage -s https://api.github.com/repos/rancher/rancher/releases | docker run --rm -i $jqimage -r .[].tag_name | grep ^v2 | head -1)
    
    docker run --restart=unless-stopped -d -p 80:80 -p 443:443 rancher/rancher:$RANCHER_VERSION
    
    while true; do
      docker run --rm --net=host $curlimage -sLk https://127.0.0.1/ping && break
      # check if Rancher is not in restarting mode
      if [ $(docker inspect $(docker ps -q --filter ancestor=rancher/rancher:latest) --format='{{.State.Restarting}}') == "true" ]; then docker rm -f $(docker ps -q --filter ancestor=rancher/rancher:latest); docker run --restart=unless-stopped -d -p 80:80 -p 443:443 rancher/rancher:latest; fi
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
    
    clear
    
    echo "Rancher is ready"
    echo "Login to Rancher: $RANCHER_SERVER"
    echo "Username: admin"
    echo "Password: $(cat /root/rancher_password)"
    
else
    # This is for master
    RANCHER_HOSTNAME="[[HOST2_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com"
    
    # Disable built-in kubelet
    systemctl disable kubelet
    systemctl stop kubelet

    # Install k3s
    K3S_VERSION=$(docker run --rm --net=host $curlimage -s https://api.github.com/repos/rancher/k3s/releases | docker run --rm -i $jqimage -r .[].tag_name | head -1)
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -
    until k3s kubectl get node | grep master | grep -q ' Ready'; do echo "Waiting for master to become Ready"; sleep 1; done
    
    # wait for Rancher to be started
    while true; do
      docker run --rm $curlimage -sLk https://$RANCHER_HOSTNAME/ping && break
      echo "Waiting for Rancher to start on ${RANCHER_HOSTNAME}..."
      sleep 5
    done
    
    RANCHER_PASSWORD=$(ssh -o StrictHostKeyChecking=no node01 cat /root/rancher_password)
    
    # Login
    while true; do
    
        LOGINRESPONSE=$(docker run \
            --rm \
            $curlimage \
            -s "https://${RANCHER_HOSTNAME}/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"'"${RANCHER_PASSWORD}"'"}' --insecure)
        LOGINTOKEN=$(echo $LOGINRESPONSE | docker run --rm -i $jqimage -r .token)
    
        if [ "$LOGINTOKEN" != "null" ] && [ "$LOGINTOKEN" != "" ]; then
            break
        else
            echo "Waiting for login to succeed"
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
          "https://$RANCHER_HOSTNAME/v3/clusters?name=k3s" | docker run --rm -i $jqimage -r '.data[].id')
    
      if [ -n "$CLUSTERID" ]; then
        break
      else
        echo "Waiting for cluster to be created..."
        sleep 5
      fi
    done
    
    # Run import command on master
    until ssh -o StrictHostKeyChecking=no node01 cat /root/importcmd >/dev/null 2>&1; do sleep 1; done

    IMPORTCMD=$(ssh -o StrictHostKeyChecking=no node01 cat /root/importcmd)
    k3s $IMPORTCMD

    # Wait til cluster agent is running
    k3s kubectl rollout status deploy cattle-cluster-agent -n cattle-system

    # Wait til cluster is active
    while true; do
      CLUSTERSTATE=$(docker run \
        --rm \
        $curlimage \
          -sLk \
          -H "Authorization: Bearer $LOGINTOKEN" \
          "https://$RANCHER_HOSTNAME/v3/clusters?name=k3s" | docker run --rm -i $jqimage -r '.data[].state')
    
      if [ "$CLUSTERSTATE" == "active" ]; then
        break
      else
        echo "Waiting for cluster to be ready..."
        sleep 5
      fi
    done

    clear
    
    echo "k3s cluster successfully imported to Rancher"
    k3s kubectl get nodes
fi
