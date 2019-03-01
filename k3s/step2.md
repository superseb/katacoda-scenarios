# Add a host to the cluster

That was pretty easy, let's add another host to this cluster by running the agent.

To start, we need the k3s binary. On the first host we used a simple all-in-one script to setup the server and agent simultaneously, for this host we only need to run the agent.

* Download k3s binary and make executable: `wget -O /usr/local/bin/k3s https://github.com/rancher/k3s/releases/download/v0.1.0/k3s && chmod +x /usr/local/bin/k3s`{{execute HOST2}}

To join the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server
* A node token to join the cluster

The following command will print the command for the agent to join the cluster, you can copy paste this command and execute it on node1:

`K3S_CLUSTER_SECRET=thisisverysecret k3s agent -s https://[[HOST_IP]]:6443 &`{{execute HOST2}}

Wait for node1 to become Ready in the cluster:

`k3s kubectl get node`{{execute HOST1}}
