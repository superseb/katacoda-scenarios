# Install k3s

The first step is installing k3s. 

k3s consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host 1 will function as server and will also join the cluster by running the agent.

There is a simple install script which can be used to install k3s server, you can click on the command to execute it on the correct host:

`curl -sfL https://get.k3s.io | sh -`{{execute HOST1}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`k3s kubectl get node`{{execute HOST1}}

As soon as it shows `master` with status `Ready`, you have built your single host cluster!
