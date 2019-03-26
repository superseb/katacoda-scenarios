# Add a host to the cluster

That was pretty easy, let's add another host to this cluster by running the agent.

To start, we need the k3s binary just like on the first host. The difference is that we will run it as agent on the second host, and not as server.

* Download k3s binary and make executable:
`wget -O /usr/local/bin/k3s https://github.com/rancher/k3s/releases/download/v0.2.0/k3s && chmod +x /usr/local/bin/k3s`{{execute HOST2}}

To add the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server
* A node token to join the cluster

Run the following command on `node01` to add the host to the cluster:

`K3S_CLUSTER_SECRET=thisisverysecret k3s agent -s https://[[HOST_IP]]:6443 > /dev/null 2>&1 &`{{execute HOST2}}

Wait for node1 to become `Ready` in the cluster by retrieving the nodes in the cluster:

`k3s kubectl get node`{{execute HOST1}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until k3s kubectl get node | grep node01 | grep -q ' Ready'; do sleep 1; done; k3s kubectl get node`{{execute HOST1}}
