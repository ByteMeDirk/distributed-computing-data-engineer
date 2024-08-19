# Kubernetes for Data Engineers: A Beginner's Guide

This tutorial will introduce you to the core concepts of containers, Kubernetes, and Helm, with a focus on local
development and a simple data processing script.

Prerequisites

- Docker installed on your local machine
- minikube installed for local Kubernetes cluster
- kubectl installed for interacting with Kubernetes
- Helm installed for package management

So what is Kubernetes, MiniKube, and Kubectl, and Helm?

- **Kubernetes (k8s)**: An open-source container orchestration platform that automates the deployment, scaling, and
  management of containerized applications.
- **MiniKube**: A tool that runs a single-node Kubernetes cluster inside a virtual machine on your local machine.
- **Kubectl**: The command-line tool for interacting with Kubernetes clusters.
- **Helm**: A package manager for Kubernetes that helps you define, install, and upgrade applications on your cluster.

There are a few gaps in this tutorial for the purpose of learning. It is a great starting point for beginners to
understand the basics of Kubernetes and Helm.

## 1: Understanding Containers

Containers are lightweight, standalone executable packages that include everything needed to run a piece of software,
including the code, runtime, system tools, libraries, and settings. They are isolated from each other and share the same
operating system kernel, making them more efficient than virtual machines.

1. Create a Python script named data_processor.py:

```python
import time


def process_data() -> None:
    """
    This function simulates data processing.
    """
    print("Starting data processing...")
    time.sleep(5)
    print("Data processing completed!")


if __name__ == "__main__":
    while True:
        process_data()
        time.sleep(10)
```

This script does not do much... but it will be used to demonstrate how to run a containerized application.

2. Create a Dockerfile:

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY data_processor.py .

CMD ["python", "data_processor.py"]
```

In this configuration, we are using the official Python 3.9 slim image as the base image. We copy the data_processor.py
script into the /app directory and set it as the default command to run when the container starts.

The docker commands are as follows:

- **-rm**: Automatically remove the container when it exits
- **-t**: Allocate a pseudo-TTY
- **-d**: Run the container in the background
- **-p**: Publish a container's port(s) to the host
- **--name**: Assign a name to the container

3. Build the Docker image:

```bash
docker build -t data-processor .
```

4. Run the container locally:

We will run the container in the foreground to see the output from the data_processor.py script.

```bash
docker run --rm -t data-processor
```

You should see the output from the data_processor.py script in your terminal.
We can stop the container by pressing `Ctrl+C`.

## 2: Introduction to Kubernetes

Kubernetes is a container orchestration platform that automates the deployment, scaling, and management of containerized
applications.
It is designed to run distributed systems at scale, making it ideal for cloud-native applications.

Real-world examples of Kubernetes use cases include:

- Running microservices
- Deploying machine learning models
- Managing big data processing pipelines
- Scaling web applications

We will use minikube to set up a local Kubernetes cluster for development purposes.
Minikube is a tool that runs a single-node Kubernetes cluster inside a virtual machine on your local machine.
It is a great way to get started with Kubernetes without the need for a cloud provider. This is known as
bare-metal Kubernetes, because it runs directly on your local machine.

1. Start your local Kubernetes cluster:

```bash
minikube start

minikube image load data-processor:latest
```

Other minikube commands include:

- **minikube status**: Get the status of the local Kubernetes cluster
- **minikube stop**: Stop the local Kubernetes cluster
- **minikube delete**: Delete the local Kubernetes cluster
- **minikube dashboard**: Open the Kubernetes dashboard in a web browser
- **minikube service**: Access a service running in the cluster
- **minikube ip**: Get the IP address of the minikube VM
- **minikube logs**: Get the logs of the minikube VM
- **minikube ssh**: SSH into the minikube VM

2. Create a Kubernetes deployment YAML file named data-processor-deployment.yaml:

The deployment file specifies the desired state for the data-processor application, including the container image,
ports,
and replicas. We use yaml to define the configuration, and we can apply it to the Kubernetes cluster using kubectl.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-processor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-processor
  template:
    metadata:
      labels:
        app: data-processor
    spec:
      containers:
        - name: data-processor
          image: data-processor:latest
          imagePullPolicy: IfNotPresent
```

This config defines a deployment with one replica of the data-processor container image. We set the imagePullPolicy to
Never
to use the local image we built earlier. In a production environment, you would typically push the image to a container
registry.

3. Apply the deployment:

Kubectl is the command-line tool for interacting with Kubernetes clusters. We use it to apply the deployment
configuration to the cluster.

Kubectl commands include:

- **kubectl apply**: Apply a configuration to a resource by filename or stdin
- **kubectl get**: Display one or many resources
- **kubectl describe**: Show details of a specific resource or group of resources
- **kubectl logs**: Print the logs for a container in a pod
- **kubectl exec**: Execute a command in a container
- **kubectl delete**: Delete resources by filenames, stdin, resources, and names, or by resources and label selector

```bash
kubectl apply -f data-processor-deployment.yaml
```

4. Check the status of your deployment:

```bash
kubectl get deployments
kubectl get pods
```

You should see the data-processor deployment and pod running in the cluster.

5. View the logs of your running pod:

```bash
kubectl logs data-processor-<pod-id>
```

## 3: Introduction to Helm

Helm is a package manager for Kubernetes that simplifies the deployment and management of applications. We use it by
defining a chart, which is a collection of files that describe a set of Kubernetes resources.
We can get charts from the Helm Hub or create our own, and we can install, upgrade, and delete them using the Helm
command-line tool.

When you create a new Helm chart using `helm create data-processor-chart`, several files and directories are generated.
Let's explore the purpose of each file in the chart structure:

1. Create a new Helm chart:

```bash
helm create data-processor-chart
```

In this directory, files are created, each file is for the following:

- **Chart.yaml**: This file contains metadata about the chart, such as its name, version, description, and any
  dependencies.

- **values.yaml**: This file defines the default configuration values for the chart. It allows you to customize the
  behavior of your chart without modifying the template files.

- **templates/**: This directory contains the template files for Kubernetes resources. These templates use Go templating
  syntax to generate the final Kubernetes manifests.

- **templates/NOTES.txt**: This file contains plain text that gets printed out after the chart is successfully deployed.
  It's typically used to display usage notes, next steps, or additional information about the deployment.

- **templates/deployment.yaml**: This template defines the Kubernetes Deployment resource for your application.

- **templates/service.yaml**: This template defines the Kubernetes Service resource to expose your application.

- **templates/serviceaccount.yaml**: This template creates a Kubernetes ServiceAccount for your application, if needed.

- **templates/hpa.yaml**: This template defines a Horizontal Pod Autoscaler for automatically scaling your application
  based on resource usage.

- **templates/ingress.yaml**: This template defines an Ingress resource for routing external traffic to your service.

- **templates/tests/**: This directory contains test files for your chart.

- **templates/_helpers.tpl**: This file contains helper templates that can be used across your chart templates.

- **.helmignore**: Similar to .gitignore, this file specifies which files should be ignored when packaging the chart.

These files provide a structured way to define, customize, and deploy your application using Helm. You can modify these
files to suit your specific application needs and add additional resources as required.

2. Replace the contents of data-processor-chart/values.yaml with:

```yaml
replicaCount: 1

image:
  repository: data-processor
  tag: latest
  pullPolicy: Never

serviceAccount:
  create: false
  name: ""

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false

service:
  type: ClusterIP
  port: 80
```

Since we're not using a service or ingress for this simple data processing job, let's remove those templates:

```bash
rm data-processor-chart/templates/service.yaml
rm data-processor-chart/templates/ingress.yaml
rm data-processor-chart/templates/hpa.yaml
rm data-processor-chart/templates/tests/test-connection.yaml
```

What we have done here is define the configuration values for our Helm chart. We specify the number of replicas, the
container image details, and the resource limits and requests. We disable the service for this example, because we are
not exposing the application to the outside world.

Now, let's simplify the NOTES.txt file to remove references to ingress and service:

```text
Thank you for installing {{ .Chart.Name }}.

Your release is named {{ .Release.Name }}.

To learn more about the release, try:

  $ helm status {{ .Release.Name }}
  $ helm get all {{ .Release.Name }}
```

3. Replace the contents of data-processor-chart/templates/deployment.yaml with:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: { { include "data-processor-chart.fullname" . } }
  labels:
    { { - include "data-processor-chart.labels" . | nindent 4 } }
spec:
  replicas: { { .Values.replicaCount } }
  selector:
    matchLabels:
      { { - include "data-processor-chart.selectorLabels" . | nindent 6 } }
  template:
    metadata:
      labels:
        { { - include "data-processor-chart.selectorLabels" . | nindent 8 } }
    spec:
      { { - with .Values.imagePullSecrets } }
      imagePullSecrets:
        { { - toYaml . | nindent 8 } }
      { { - end } }
      serviceAccountName: { { include "data-processor-chart.serviceAccountName" . } }
      containers:
        - name: { { .Chart.Name } }
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: { { .Values.image.pullPolicy } }
          resources:
            { { - toYaml .Values.resources | nindent 12 } }
```

Here, we define the deployment template for our Helm chart. We use the values defined in values.yaml to set the number
of
replicas, the container image, and the resource limits and requests.

Finally, let's update the data-processor-chart/templates/serviceaccount.yaml file:

```yaml
{ { - if .Values.serviceAccount.create - } }
apiVersion: v1
kind: ServiceAccount
metadata:
  name: { { include "data-processor-chart.serviceAccountName" . } }
  labels:
    { { - include "data-processor-chart.labels" . | nindent 4 } }
  { { - with .Values.serviceAccount.annotations } }
  annotations:
    { { - toYaml . | nindent 4 } }
  { { - end } }
  { { - end } }
```

4. Install the Helm chart:

```bash
helm install data-processor ./data-processor-chart
```

5. Verify the deployment:

```bash
kubectl get deployments
kubectl get pods
```

You should see something like:

```text
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
data-processor-data-processor-chart   1/1     1            1           11s
```

And:

```text
NAME                                                   READY   STATUS    RESTARTS   AGE
data-processor-data-processor-chart-<pod-id>   1/1     Running   0          16s
```

6. Tail the logs of your running pod:

```bash
kubectl logs data-processor-<pod-id> -f 
```

7. To stop the deployment:

```bash
helm uninstall data-processor
```

# Conclusion

In this tutorial, we introduced you to the core concepts of containers, Kubernetes, and Helm, focusing on local
development and a simple data processing script. We covered building a Docker image, running a container locally,
setting up a local Kubernetes cluster with minikube, and deploying a containerized application using kubectl and Helm.

This is just the beginning of your journey into the world of Kubernetes and container orchestration. As you continue to
explore and learn, consider the following best practices:

1. **Container optimization**: Keep your container images small and efficient by using multi-stage builds and minimizing
   the number of layers.

2. **Resource management**: Always specify resource requests and limits for your containers to ensure efficient cluster
   utilization.

3. **Security**: Follow the principle of least privilege when setting up service accounts and RBAC policies.

4. **Monitoring and logging**: Implement comprehensive monitoring and logging solutions to gain visibility into your
   applications and cluster health.

5. **CI/CD integration**: Automate your deployment process by integrating Kubernetes and Helm into your CI/CD
   pipeline.

To further your knowledge, consider exploring:

- Advanced Kubernetes features like StatefulSets, DaemonSets, and Jobs
- Kubernetes networking concepts and service mesh technologies
- High availability and disaster recovery strategies
- Cloud-native storage solutions
- Kubernetes security best practices

Remember, the key to mastering Kubernetes and container orchestration is hands-on practice and continuous learning. As
you build more complex applications and deploy them to production environments, you'll gain valuable experience and
insights.

Happy containerizing! 🐳🚀

