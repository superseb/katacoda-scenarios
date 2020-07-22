---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rancher-demo
  labels:
    app: rancher-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rancher-demo
  template:
    metadata:
      labels:
        app: rancher-demo
    spec:
      containers:
      - name: rancher-demo
        image: superseb/rancher-demo
        ports:
        - containerPort: 8080
---
kind: Service
apiVersion: v1
metadata:
  name: rancher-demo-service
spec:
  selector:
    app: rancher-demo
  ports:
  - protocol: TCP
    port: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: rancher-demo-ingress
spec:
  rules:
  - host: __HOSTNAME__
    http:
      paths:
      - path: /
        backend:
          serviceName: rancher-demo-service
          servicePort: 8080
