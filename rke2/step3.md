# Create and access workload

Now we are ready to deploy a workload and access it. The first host has a template file at `/root/rancher-demo.yaml.tpl` which we can use to deploy a web page showing the amount of pods running for a Deployment.

`cat /root/rancher-demo.yaml.tpl | sed 's/__HOSTNAME__/[[HOST2_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/g' | kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml create -f -`{{execute HOST2}}

Wait for the pods to be running:

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml rollout status deploy/rancher-demo`{{execute HOST2}}

Now you can access the created workload by clicking on the following link:

https://[[HOST2_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/

After checking it out, scale the deployment to more replicas and see the result:

`kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml scale deploy/rancher-demo --replicas=5`{{execute HOST2}}
