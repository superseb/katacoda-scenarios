# Install k3s

The first step is installing k3s. 

k3s consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host 1 will function as server and will also join the cluster by running the agent.

First, we will need to download the k3s binary on the host. This binary is used to start the server.

* Download k3s binary and make executable:
`wget -O /usr/local/bin/k3s https://github.com/rancher/k3s/releases/download/v0.2.0/k3s && chmod +x /usr/local/bin/k3s`{{execute HOST1}}

Now we are ready to start the server. For demo purposes, we are pre-configuring a node token and running the k3s server as a background process.

`K3S_CLUSTER_SECRET=thisisverysecret k3s server >/dev/null 2>&1 &`{{execute HOST1}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`k3s kubectl get node`{{execute HOST1}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until k3s kubectl get node 2>/dev/null | grep master | grep -q ' Ready'; do sleep 1; done; k3s kubectl get node`{{execute HOST1}}

As soon as it shows `master` with status `Ready`, you have built your single host cluster!

```
NAME     STATUS   ROLES    AGE   VERSION
master   Ready    <none>   0s    v1.13.3-k3s.6
```
