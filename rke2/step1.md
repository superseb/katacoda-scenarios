# Install rke2

The first step is installing rke2. 

rke2 consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host `node01` will function as server

There is a simple `curl` oneliner to install rke2, in this example, we will retrieve the latest version from GitHub to keep it up-to-date til the installer can auto discover.

`RKE2_VERSION=$(docker run --rm --net=host appropriate/curl -s https://api.github.com/repos/rancher/rke2/releases | docker run --rm -i stedolan/jq -r .[].tag_name | sort -V | tail -1) && echo "RKE2_VERSION=${RKE2_VERSION}"`{{execute HOST2}}

Then run the `install.sh` script using the retrieved version:

`curl -sfL https://raw.githubusercontent.com/rancher/rke2/master/install.sh | INSTALL_RKE2_EXEC="--node-ip=[[HOST2_IP]]" INSTALL_RKE2_TYPE=server INSTALL_RKE2_VERSION=$RKE2_VERSION sh -`{{execute HOST2}}

Next step is to start the rke2 server:

`systemctl start rke2-server`{{execute HOST2}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node 2>/dev/null | grep node01 | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

As soon as it shows `node01` with status `Ready`, you have built your single host cluster!

```
NAME             STATUS   ROLES         AGE   VERSION
node01           Ready    etcd,master   3m    v1.18.4-alpha20+rke2
```
