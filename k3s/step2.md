# Add a node

That was pretty easy, let's add another host to this cluster by running the agent.

To start, we need the k3s binary. On the first host we used a simple all-in-one script to setup the server and agent simultaneously, for this host we only need to run the agent.

* Download k3s binary: `wget -O /usr/local/bin/k3s https://github.com/rancher/k3s/releases/download/v0.1.0/k3s`{{execute HOST2}}

* Make the k3s binary executable: `chmod +x /usr/local/bin/k3s`{{execute HOST2}}

To join the host as an agent to the cluster, we need two things:

* The IP address or DNS name of the server
* A node token to join the cluster (this is generated automatically by the server on startup, and is stored at `/var/lib/rancher/k3s/server/node-token`)

Run the following command on the master to generate the agent command to join the cluster:

`k3s agent -s https://$(ip -o -4 addr show dev ens3 | cut -d' ' -f7 | cut -d'/' -f1) -t $(cat /var/lib/rancher/k3s/server/node-token)`{{execute HOST1}}
