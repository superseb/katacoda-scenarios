# Add a host to the cluster

That was pretty easy, let's add another host to this cluster by running the agent.

To add the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server (in this case, the IP address of the host with hostname `master`)
* A cluster secret to join the cluster (in this case, pre-configured for demo purposes)

Run the following command on `node01` to add the host to the cluster:

`curl -sfL https://raw.githubusercontent.com/rancher/rke2/master/install.sh | RKE2_CLUSTER_SECRET=thisisverysecret RKE2_URL=https://[[HOST_IP]]:6443 sh -`{{execute HOST2}}

Wait for node1 to become `Ready` in the cluster by retrieving the nodes in the cluster:

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST1}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node | grep node01 | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST1}}
