# Install k3s

The first step is installing k3s. 

k3s consists of a server and an agent, where the server will run the master components, and the agent the worker components.

We have 2 hosts available in this scenario:

- Host 1 will function as server and will also join the cluster by running the agent.
- Host 2 will join the cluster by just running the agent.

There is a simple install script which can be used to install k3s server:

`curl -sfL https://get.k3s.io | sh -`{{execute HOST1}}

You can run the following command to check if the node is in Ready state:

`k3s kubectl get node`{{execute HOST1}}
