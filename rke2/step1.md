# Install rke2

The first step is installing rke2. 

rke2 consists of a server and an agent, where the server will run the master components, and the agent the worker components.

- Host `node01` will function as server

There is a simple `curl` oneliner to install rke2 (`get.rke2.io` is a front for `https://raw.githubusercontent.com/rancher/rke2/master/install.sh`)

`curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -`{{execute HOST2}}

Next step is create a config file at `/etc/rancher/rke2/config.yaml`:

`mkdir -p /etc/rancher/rke2 && echo -e "agent-token: thisisverysecret\ntls-san: example.rke2.io" > /etc/rancher/rke2/config.yaml && cat /etc/rancher/rke2/config.yaml`{{execute HOST2}}

The config file consists of a static agent token for the agent(s) to join (it is recommended to create a stronger token in production), and as example, another entry for the server certificate in case you have multiple servers behind a load balancer hostname.

The install scripts drops systemd files in `/usr/local/lib/systemd/system/`. To make sure these are loaded, we can reload systemd.

`systemctl daemon-reload`{{execute HOST2}}

Now you are ready to start the server:

`systemctl start rke2-server`{{execute HOST2}}

You can run the following command to check if the node is in Ready state (you might need to run the command a couple of times, can take up to 30 seconds for the node to register):

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

For your convenience, the following command will wait until the node shows up as `Ready`:

`until kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node 2>/dev/null | grep node01 | grep -q ' Ready'; do sleep 1; done; kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get node`{{execute HOST2}}

As soon as it shows `node01` with status `Ready`, you have built your single host cluster!

```
NAME             STATUS   ROLES         AGE   VERSION
node01           Ready    etcd,master   3m    v1.18.8-beta20+rke2
```
