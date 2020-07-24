# Add a host to the cluster

That was pretty easy, let's add another host to this cluster by running the agent.

To add the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server (in this case, the IP address of the host with hostname `node01`)
* A cluster secret to join the cluster (located at `/var/lib/rancher/rke2/server/node-token` on host `node01`)

Run the following command on `controlplane` to add the host to the cluster:

`RKE2_VERSION=$(docker run --rm --net=host $curlimage -s https://api.github.com/repos/rancher/rke2/releases | docker run --rm -i $jqimage -r .[].tag_name | sort -V | tail -1) && NODE_TOKEN=$(ssh -q node01 cat /var/lib/rancher/rke2/server/node-token) && curl -sfL https://raw.githubusercontent.com/rancher/rke2/master/install.sh | INSTALL_RKE2_VERSION=$RKE2_VERSION RKE2_TOKEN=$NODE_TOKEN RKE2_URL=https://[[HOST2_IP]]:9345 sh -`{{execute HOST1}}

Wait for node1 to become `Ready` in the cluster by retrieving the nodes in the cluster:

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node | grep controlplane | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}
