# React Dashboard with DevSecOps Pipeline

A Material Dashboard React application with complete DevSecOps CI/CD pipeline for deployment to Azure Kubernetes Service (AKS).

## 🏗️ Application Details

- **Framework**: React 17.0.2 (Material Dashboard 2)
- **Language**: JavaScript/Node.js
- **Build Tool**: Create React App (React Scripts)
- **Node Version**: >=18.20.0
- **Port**: 8080 (production), 3000 (development)

## 📁 Project Structure

```
├── .github/workflows/      # GitHub Actions CI/CD pipeline
├── k8s/                   # Kubernetes manifests
├── src/                   # React application source
├── public/                # Static assets
├── Dockerfile             # Multi-stage Docker build
├── .dockerignore          # Docker ignore rules
├── nginx.conf             # Production nginx configuration
└── package.json           # Dependencies and scripts
```

## 🔐 Security Features

### Docker Security
- Multi-stage build for minimal attack surface
- Non-root user execution (user ID: 1001)
- Security contexts and capabilities dropping
- Dependency vulnerability scanning and fixes
- Specific base image versions (no `latest` tags)
- Health checks and proper signal handling

### Kubernetes Security
- **Namespace**: `github-copilot-ns`
- **Security Context**: Non-root execution, read-only filesystem
- **Network Policies**: Ingress/egress traffic control
- **Resource Limits**: CPU and memory constraints
- **Pod Disruption Budget**: High availability
- **Service Account**: Minimal privileges
- **Health Checks**: Liveness, readiness, and startup probes

## 🚀 CI/CD Pipeline

### Workflow Triggers
- Push to `main`, `develop`, or `master` branches
- Pull requests to `main` or `master`
- Manual workflow dispatch

### Build Job Features
- ✅ Multi-stage setup with dependency installation
- ✅ Azure CLI and kubectl installation
- ✅ Manual Trivy security scanner installation
- ✅ Node.js environment setup (v18.20.4)
- ✅ Application testing and building
- ✅ Docker multi-platform image build
- ✅ Azure Container Registry push
- ✅ Trivy security scanning (CRITICAL,HIGH vulnerabilities)
- ✅ Build artifact management

### Deploy Job Features
- ✅ Automatic deployment on push to main branches
- ✅ Production environment protection
- ✅ AKS cluster connection
- ✅ Container image security verification
- ✅ Kubernetes manifest preparation
- ✅ Rolling deployment with verification
- ✅ Post-deployment health checks
- ✅ Comprehensive deployment reporting

### Security Scanning
- **Tool**: Trivy v0.28.0
- **Formats**: Table output
- **Scope**: Container images + filesystem
- **Severity**: CRITICAL and HIGH vulnerabilities
- **Exit Policy**: Fail on critical/high findings
- **Timeout**: 10 minutes

## 🔧 Configuration

### Required GitHub Secrets
```
AZURE_CLIENT_ID         # Azure service principal client ID
AZURE_CLIENT_SECRET     # Azure service principal client secret
AZURE_SUBSCRIPTION_ID   # Azure subscription ID
AZURE_TENANT_ID         # Azure tenant ID
REGISTRY_LOGIN_SERVER   # Azure Container Registry server
REGISTRY_USERNAME       # Azure Container Registry username
REGISTRY_PASSWORD       # Azure Container Registry password
AKS_CLUSTER_NAME        # Azure Kubernetes Service cluster name
AKS_RESOURCE_GROUP      # Azure resource group name
```

### Environment Variables
- `NODE_ENV`: production
- `REACT_APP_ENV`: production
- `PORT`: 8080

## 🏃‍♂️ Local Development

### Prerequisites
- Node.js >=18.20.0
- npm >=8

### Setup
```bash
# Install dependencies
npm install

# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build
```

### Docker Development
```bash
# Build image
docker build -t react-dashboard .

# Run container
docker run -p 8080:8080 react-dashboard
```

## 🚢 Deployment

### Kubernetes Deployment
The application deploys to AKS with:
- **Replicas**: 3 pods
- **Service Type**: ClusterIP
- **Resource Limits**: 512Mi memory, 500m CPU
- **Resource Requests**: 128Mi memory, 100m CPU
- **Auto-scaling**: HPA configured (3-10 replicas)

### Monitoring Endpoints
- **Health Check**: `/health`
- **Application**: `/` (serves React SPA)

## 📊 Build Information
Each deployment includes:
- Unique Build ID (git-sha + run-number)
- Git commit SHA
- Branch information
- Build timestamp
- Deployment verification

## 🔍 Troubleshooting

### Common Issues
1. **Security Scan Failures**: Check Trivy results for critical vulnerabilities
2. **Deployment Issues**: Verify AKS credentials and cluster access
3. **Image Pull Issues**: Confirm Azure Container Registry permissions
4. **Pod Startup Issues**: Check resource limits and health check configurations

### Logs and Debugging
```bash
# Check pod status
kubectl get pods -n github-copilot-ns

# View pod logs
kubectl logs -f deployment/react-dashboard-deployment -n github-copilot-ns

# Describe deployment
kubectl describe deployment react-dashboard-deployment -n github-copilot-ns
```

## 🏷️ Versioning
- Images are tagged with: `{git-sha:8}-{run-number}`
- Each build creates unique, traceable artifacts
- Latest tag maintained for quick rollbacks

## 🔄 Rollback Strategy
```bash
# List previous deployments
kubectl rollout history deployment/react-dashboard-deployment -n github-copilot-ns

# Rollback to previous version
kubectl rollout undo deployment/react-dashboard-deployment -n github-copilot-ns
```

## 📝 License
This project uses Material Dashboard 2 by Creative Tim. See their license terms for usage restrictions.
