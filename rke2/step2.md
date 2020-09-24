# Add a host to the cluster

That was pretty easy, let's add another host to this cluster by running the agent.

To add the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server (in this case, the IP address of the host with hostname `node01`)
* A cluster secret to join the cluster (this was set to `thisisverysecret` in the server config)

Run the following commands on `controlplane` to add the host to the cluster:

* Run the `install.sh` script with the retrieved variables

`curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -`{{execute HOST1}}

* Create a config file for the agent

`mkdir -p /etc/rancher/rke2 && echo -e "server: https://[[HOST2_IP]]:9345\ntoken: thisisverysecret\nnode-ip: [[HOST1_IP]]" > /etc/rancher/rke2/config.yaml && cat /etc/rancher/rke2/config.yaml`{{execute HOST1}}

The install scripts drops systemd files in `/usr/local/lib/systemd/system/`. To make sure these are loaded, we can reload systemd.

`systemctl daemon-reload`{{execute HOST1}}

Next step is to start the rke2 agent:

`systemctl start rke2-agent`{{execute HOST1}}

Wait for node1 to become `Ready` in the cluster by retrieving the nodes in the cluster:

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node | grep controlplane | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}
