# Install rke2

The first step is installing rke2. 

rke2 consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host 1 (`master`) will function as server and will also join the cluster by running the agent.

There is a simple `curl` oneliner to install rke2. For demo purposes, we are pre-configuring a cluster secret.

`curl -sfL https://raw.githubusercontent.com/rancher/rke2/master/install.sh | RKE2_CLUSTER_SECRET=thisisverysecret sh -`{{execute HOST1}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST1}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node 2>/dev/null | grep master | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST1}}

As soon as it shows `master` with status `Ready`, you have built your single host cluster!

```
NAME             STATUS   ROLES         AGE   VERSION
master           Ready    etcd,master   3m    v1.18.4-alpha15+rke2
```
