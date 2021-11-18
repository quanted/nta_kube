# NTA Web - Kubernetes
### Description
The nta_kube repository consists of the entire code base for developing and deploying the NTA web technology stack through kubernetes. 
The technology stack consists of several components:
1. Nginx - Web server for routing traffic to programs within the stack and serves up static files.
2. Django - Web framework for generating html templates, views, and API.
3. Flask - Web framework (light-weight) for REST API endpoints
4. Dask - Scheduler and worker used for asynchronous and parallel processing of requests
5. MongoDB - Database for storing the results of API tasks

### Technologies
The technology stack is containerized with Docker, Dockerfiles, which are built on docker hub. Kubernetes pulls those images, as specified by the k8s manifest image sources. 
Local development can replicate a deployed environment by using Minikube, https://minikube.sigs.k8s.io/. A minikube supported driver will be required, such as docker desktop, VirtualBox, HyperV, etc.

### Local Deployment/Development
#### Startup
After installing minikube spin up a new single node cluster with
```
minikube start --driver=DRIVER --cpus=CPUS --memory=MEM
```
Where DRIVER will be whichever minikube supported driver you have installed, such as 'docker'; CPUS is the number of cpus you want the cluster to have access to; and MEM is the total memory you want the cluster to have (such as '4G').

#### Mounts
The k8s directory contains the kubernetes manifests for creating the resources. One big difference between local development and server deployment are the mounted volumes and how they are handled.
Minikube provides options for mounting volumes from a specified hostPath. These have been provided in the manifests for nginx, django, flask and dask.
To run the stack using the code within the image itself (copied at image build time from the repo), we only need to mount volumes for app-data and collected-static. That can be done with the following:
```
minikube mount LOCAL_PATH_TO_DIR:HOST_PATH
```
Which may look like, where we need the host path to be the same as what is specified in the manifests
```
minikube mount /Users/test/Documents/git/mounts/collected-static:/host/collected-static
```
#### Code Mounts
To develop directly with the code being executed by the stack, we can mount volumes from your local code base to the pods directly.
For django:
```commandline
minikube mount /Users/test/Documents/git/nta_kube/nta_app:/host/django-code
```
For flask:
```commandline
minikube mount /Users/test/Documents/git/nta_kube/nta_flask:/host/flask-code
```
then in the manifests for django, flask and/or dask, uncomment the corresponding volumes. With these mounts, changes can be made within an IDE which are then instantly testable within the Pod (may require a pod restart). All minikube mount commands are examples and the LOCAL_PATH_TO_DIR will need to be properly specified for your local environment.
#### Creating Resources
Once all the mounts have been set up (each requiring an open terminal), we can begin creating the resources for the stack.
Apply each of the resources, taking into consideration dependencies like the ConfigMap. To create a resource run:
```commandline
kubectl apply -f PATH_TO_MANIFEST
```
where PATH_TO_MANIFEST will be the relative/absolute path to the yml file, such as 'k8s/nta-django-deployment.yml'

To monitor and check logs, we can use the minikube dashboard which is accessible through
```commandline
minikube dashboard
```
Finally to access the stack through the browser we can create a tunnel to the nta-nginx service with
```commandline
minikube service nta-nginx --url
```
this will provide an IP and port to access the stack from your local browser.

### AWS Deployment

#### Mounts
The deployment of the stack to AWS requires a few adjustments from the local deployment strategy. The first changes are setting up the shared PersistentVolumes and PersistentVolumeClaims need to run the applications.
Those PVs and PVCs will correspond to the lower block of Volumes in the manifest files, which will not point to hostPaths but to PVCs. We comment out all the hostPath volumes, uncomment the PVCs, and comment out all source code mounts (not used in aws deployment).

#### Ingress
Unlike in the local deployment, where Nginx manages all traffic, we have an Ingress which manages all traffic to the apprropriate Nginx service. For example, Ingress can be configured to point all traffic with the url prefix '/nta' to the nta-nginx service.

#### ConfigMap
If necessary multiple ConfigMaps, which are key/value pairs for setting environment variables, can be created and used to account for possible differences in deployment configurations.
