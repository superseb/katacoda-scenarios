# Add a node

That was pretty easy, let's add another host to this cluster by running the agent.

To start, we need the k3s binary. On the first host we used a simple all-in-one script to setup the server and agent simultaneously, for this host we only need to run the agent.

* Download k3s binary: `wget -O /usr/local/bin/k3s https://github.com/rancher/k3s/releases/download/v0.1.0/k3s`{{execute HOST2}}
* Make the k3s binary executable: `chmod +x /usr/local/bin/k3s`{{execute HOST2}}

When host 1 was setup as server, it generated a node token which we can use to join the cluster. The node token is stored at `/var/lib/rancher/k3s/server/node-token`.
