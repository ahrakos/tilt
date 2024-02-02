load('ext://helm_resource', 'helm_resource', 'helm_repo')
load('ext://helm_remote', 'helm_remote')

# Load the Dockerfile from the current directory
# default_registry('localhost:5000')
allow_k8s_contexts('k3d-k3s-default')

# Configure live updates
live_update=[
    # Sync all .ts files into the container
    sync('./src', '/usr/src/app/src')
    # Rebuild and restart the application when files in 'src' change
    # run('npm run watch', trigger='./src'),
    # restart_container()
]

# Function to build and load image into k3d
def build_scheduler():
    local_resource('build_scheduler', 'docker build -f Dockerfile-scheduler -t opti-k8s-scheduler:latest . && k3d image import opti-k8s-scheduler:latest -c k3s-default')

def build_scaler():
    local_resource('build_scaler', 'docker build -f Dockerfile-autoscaler -t opti-k8s-autoscaler:latest . && k3d image import opti-k8s-autoscaler:latest -c k3s-default')

build_scheduler()
build_scaler()

# Use custom build for your image
custom_build(
    'opti-k8s-scheduler', 
    'echo custom build complete',  # This is a placeholder; the real build is triggered by the local_resource
    ['.'],
    live_update=live_update,
    tag='latest',
    disable_push=True,
    skips_local_docker=True
)

# Use custom build for your image
custom_build(
    'opti-k8s-autoscaler',
    'echo custom build complete',  # This is a placeholder; the real build is triggered by the local_resource
    ['.'],
    live_update=live_update,
    tag='latest',
    disable_push=True,
    skips_local_docker=True
)

# docker_build(
#     'opti-k8s-scheduler', 
#     '..', 
#     live_update=live_update
# )

# Define how to run the service
k8s_yaml(['./deployment/scheduler-deployment.yaml', './deployment/scheduler-service.yaml'])
k8s_resource('opti-k8s-scheduler', port_forwards="4000:4000")


# Define how to run the service
k8s_yaml(['./deployment/scaler-deployment.yaml', './deployment/scaler-service.yaml', './deployment/scaler-sa.yaml', './deployment/scaler-role.yaml', './deployment/scaler-rolebinding.yaml'])
# Specify the service name (as defined in your Kubernetes YAML) and the port to forward
k8s_resource('opti-k8s-autoscaler', port_forwards="4001:4001")

# Define how to run the service
k8s_yaml(['./deployment/euclid-deployment.yaml', './deployment/euclid-service.yaml'])
# Specify the service name (as defined in your Kubernetes YAML) and the port to forward
k8s_resource('euclid')


# helm_repo('bitnami', 'https://charts.bitnami.com/bitnami')
helm_remote('redis', repo_url='https://charts.bitnami.com/bitnami', repo_name='redis', release_name='redis', set=['auth.enabled=false', 'master.service.nodePorts.redis=30007', 'master.service.type=NodePort'])
