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

#### Docker-Desktop (Windows)

Docker-Desktop is an alternative option for running a single-node kubernetes cluster. After installing Docker-Desktop, or updating to the latest version, turn Kubernetes on in Settings and restart docker-desktop. A new kubernetes context will be created 'docker-desktop' which can be used to run the stack.

To allow for the mounts, the mounted directories need to be specified or be a sub-directory of a directory which docker-desktop has access to 'Resources > File Sharing'. The compute resources which are specified are the max that the kubernetes cluster will have access to.
Depending on existing kubectl configurations, the new context may need to be set as current.
```commandline
kubectl config current-context
```
If 'docker-desktop' is not the current config, check to see if it is listed in the available contexts
```commandline
kubectl config get-contexts
```
if available, set 'docker-desktop' to the current context by
```commandline
kubectl config set-context docker-desktop
```
or
```commandline
kubectl config use-context docker-desktop
```
Now any kubectl will use the docker-desktop context, the kubernetes resources for nta can now be applied.
The order to apply the resources should be: ConfigMap, PersistentVolumes, PersistentVolumeClaims, Services, StatefulSet, Deployments, HPAs.

Or to apply all the kubernetes manifests for the application at once, run the following from the root of the repo:
```commandline
kubectl apply -f k8s\
```

To create the resources for the  kubernetes dashboard, run the following commands
```commandline
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
kubectl proxy
```
The resources necessary for the dashboard are now running, and can be accessed at:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

The first time reaching the dashboard will prompt for a login token or key, to skip this step open the kubernetes-dashboard deployment for editing 
```commandline
kubectl edit deploy/kubernetes-dashboard -n kubernetes-dashboard
```
and add the following line under spec.containers.args after the others in the list of args:
```yaml
- --enable-skip-login
```
Those changes will automatically apply once the editing is completed and the yaml is valid. Then revisiting or reloading the dashboard will again prompt for a token/login but also have the option to skip.

Django and Dask have optional hostPath mounts which can be used for local code development and testing, code is mounted directly to the pod so no image rebuilds required (typically requires a pod restart).
To use these hostPaths make sure that the 'django-code' Volume and VolumeMount blocks are both uncommented. If the hostPath mounts are not used, Django and Dask will use the current code in the image being used (most likely the last commit to github on the main branch).

To access the running technology stack, we can access the open NodePort on vb-nginx that is specified to be port 31000. http://localhost:31000/nta will open up the web application, alternatively http requests can be made to the same base url via Postman or curl.
 
Resource metrics can also be tracked by deploying the metric-server
```commandline
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```


### AWS Deployment

#### Mounts
The deployment of the stack to AWS requires a few adjustments from the local deployment strategy. The first changes are setting up the shared PersistentVolumes and PersistentVolumeClaims need to run the applications.
Those PVs and PVCs will correspond to the lower block of Volumes in the manifest files, which will not point to hostPaths but to PVCs. We comment out all the hostPath volumes, uncomment the PVCs, and comment out all source code mounts (not used in aws deployment).

#### Ingress
Unlike in the local deployment, where Nginx manages all traffic, we have an Ingress which manages all traffic to the apprropriate Nginx service. For example, Ingress can be configured to point all traffic with the url prefix '/nta' to the nta-nginx service.

#### ConfigMap
If necessary multiple ConfigMaps, which are key/value pairs for setting environment variables, can be created and used to account for possible differences in deployment configurations.
