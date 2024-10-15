## K3d vs Argo CD

### K3d:
- Runs lightweight Kubernetes clusters inside Docker containers.
- Quick and easy way to set up Kubernetes clusters on your local machine for development and testing.

### Argo CD:
- Automates app deployments in Kubernetes using Git as the source of truth.
- Keeps your apps in sync with the desired state defined in a Git repository.

### Key Differences:

#### Main Focus:
- **K3d**: Setting up and managing Kubernetes clusters locally.
- **Argo CD**: Deploying and syncing apps in those Kubernetes clusters.

#### Role in Workflow:
- **K3d**: Creates the Kubernetes environment.
- **Argo CD**: Manages apps inside the Kubernetes environment.

---

## Pods vs Namespaces

### Pod:
- The smallest unit in Kubernetes, usually running one or more containers.
- To run applications.

### Namespace:
- A way to group and separate resources in a Kubernetes cluster.
- To organize resources and prevent naming conflicts.

### Key Differences:

#### Function:
- Runs the actual app.
- Organizes and separates pods and other resources.

#### Relationship:
- **Pods** live inside **namespaces**.
- **Namespaces** contain multiple resources, including pods.

---

#### install and setup environment


`./setup.sh`

#### create argocd cluster , the namespaces:


`./start.sh`

### how to check the namespaces (the script alrdy do it) : 

`kubectl get ns".`

### check if there is at least 1 pod in the "dev" namespace : 


`kubectl get pods -n dev`

#### clone the app and change version (just change the var APP_VERSION in the script)

`./update_version`

### curl the app:

`curl http://localhost:8888/`

#### Delete the k3d cluster 

`k3d cluster delete cjunkercluster`