# Install k3s

The first step is installing k3s. 

k3s consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host 1 (`master`) will function as server and will also join the cluster by running the agent.

There is a simple `curl` oneliner to install k3s. For demo purposes, we are pre-configuring a cluster secret.

`curl -sfL https://get.k3s.io | K3S_CLUSTER_SECRET=thisisverysecret sh -`{{execute HOST1}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`k3s kubectl get node`{{execute HOST1}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until k3s kubectl get node 2>/dev/null | grep master | grep -q ' Ready'; do sleep 1; done; k3s kubectl get node`{{execute HOST1}}

As soon as it shows `master` with status `Ready`, you have built your single host cluster!

```
NAME           STATUS   ROLES                  AGE     VERSION
controlplane   Ready    control-plane,master   3m30s   v1.21.5+k3s2
```
