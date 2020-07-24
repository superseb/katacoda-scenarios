# Environment is being created

Note: This environment runs `rancher/rancher:latest`, this is the latest development release. Please refer to the [official documentation](https://docs.rancher.com) how to setup Rancher in production.

The node `controlplane`` is used to run Rancher (single node install).

Please wait til the terminal displays `Rancher is ready` and shows you the URL, username and password you can use to login.

The node `node01` is used to bring up a single node Kubernetes cluster using https://github.com/rancher/rke2/blob/master/install.sh. After creating the cluster, it will be automatically imported into Rancher under the cluster name `rke2`.


When both terminals show as ready (`Rancher is ready` and `RKE2 cluster successfully imported to Rancher`), you can open the Rancher UI by clicking this link:

https://[[HOST_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com/

The username is `admin` and the password is shown in the terminal. It is also available at `/root/rancher_password`.
