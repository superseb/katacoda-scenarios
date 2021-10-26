# Run Rancher

The node `node01` is used to run Rancher. For this scenario we are using Docker to run Rancher, referred in the documentation as [Single Node Install](https://rancher.com/docs/rancher/v2.x/en/installation/single-node/)

`docker run --name=rancher --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:latest`{{execute HOST2}}

Rancher should be accessible within 60 seconds after pulling the Docker image. You can use the following command to check if Rancher is ready:

`while true; do curl -sLk https://127.0.0.1/ping && break; sleep 2; done`{{execute HOST2}}

Starting with Rancher v2.6.0, an initial password is generated that can be used to set your own password. You can use the following command to look up the initial password:

`docker logs rancher 2>&1 | grep "Bootstrap Password:"`{{execute HOST2}}

You can access Rancher using the following URL:

https://[[HOST2_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com/
