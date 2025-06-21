# Portfolio App - Docker & Kubernetes Infrastructure

This document explains the complete infrastructure setup for deploying the portfolio application using Docker and Kubernetes.

## 🏗️ Architecture Overview

```mermaid
graph TB
    A[Source Code] --> B[Docker Build]
    B --> C[Container Registry]****
    C --> D[Kubernetes Cluster]
    D --> E[Development]
    D --> F[Staging]
    D --> G[Production]
```

## 📁 Infrastructure Structure

```
├── Dockerfile                 # Multi-stage container build
├── docker-compose.yml         # Local development
├── nginx.conf                # Nginx configuration
├── VERSION                   # Semantic version file
├── scripts/
│   ├── version.sh            # Version management
│   └── deploy.sh             # Deployment automation
└── k8s/
    ├── base/                 # Base Kubernetes manifests
    │   ├── deployment.yaml   # Application deployment
    │   ├── service.yaml      # Internal networking
    │   ├── ingress.yaml      # External access
    │   ├── configmap.yaml    # Configuration
    │   └── kustomization.yaml
    └── overlays/             # Environment-specific configs
        ├── development/      # Dev environment (minimal resources)
        ├── staging/          # Staging (production-like)
        └── production/       # Production (HPA, high availability)
```

## 🚀 Quick Start

### Prerequisites

1. **Docker** - For building and running containers
2. **kubectl** - For Kubernetes deployments
3. **kustomize** - For manifest management
4. **Kubernetes cluster** - Local (minikube/kind) or cloud (GKE/EKS/AKS)

### Local Development

```bash
# Build the Docker image
docker build -t portfolio-app:latest .

# Run locally with Docker Compose
docker-compose up -d

# View the application
open http://localhost:3000
```

### Version Management

```bash
# Bump version (patch/minor/major)
./scripts/version.sh patch

# Current version is automatically read from VERSION file
cat VERSION
```

### Kubernetes Deployment

```bash
# Make deployment script executable
chmod +x scripts/deploy.sh

# Deploy to development
./scripts/deploy.sh development deploy

# Deploy to staging
./scripts/deploy.sh staging deploy

# Deploy to production
./scripts/deploy.sh production deploy

# Check deployment status
./scripts/deploy.sh production status

# View what would be deployed (dry run)
./scripts/deploy.sh development dry-run
```

## 🐳 Docker Setup

### Multi-Stage Build Process

1. **Build Stage** (`oven/bun:1-alpine`)

   - Installs dependencies with Bun
   - Builds React application
   - Creates optimized production bundle

2. **Production Stage** (`nginx:alpine`)
   - Lightweight Alpine Linux
   - Nginx for serving static files
   - Health checks enabled
   - Security hardened

### Key Features

- **🔒 Security**: Non-root user, minimal attack surface
- **📦 Size**: ~49MB final image size
- **🚀 Performance**: Gzip compression, caching headers
- **🔍 Monitoring**: Built-in health checks
- **♻️ Caching**: Docker layer caching for faster builds

## ☸️ Kubernetes Configuration

### Base Resources

| Resource       | Purpose                                       |
| -------------- | --------------------------------------------- |
| **Deployment** | Manages application pods and rolling updates  |
| **Service**    | Internal load balancing and service discovery |
| **Ingress**    | External access with SSL/TLS termination      |
| **ConfigMap**  | Environment-specific configuration            |

### Environment Differences

| Feature        | Development   | Staging           | Production     |
| -------------- | ------------- | ----------------- | -------------- |
| **Replicas**   | 1             | 2                 | 3+ (with HPA)  |
| **Resources**  | 32Mi/25m CPU  | 64Mi/50m CPU      | 128Mi/100m CPU |
| **Debug Logs** | ✅            | ❌                | ❌             |
| **HPA**        | ❌            | ❌                | ✅ (3-10 pods) |
| **Namespace**  | portfolio-dev | portfolio-staging | portfolio-prod |

### Auto-scaling (Production)

```yaml
# HPA Configuration
minReplicas: 3
maxReplicas: 10
targetCPUUtilization: 70%
```

## 🔄 CI/CD Workflow

### Typical Deployment Process

1. **Development**

   ```bash
   # Make changes to code
   git add .
   git commit -m "feat: new feature"

   # Bump version
   ./scripts/version.sh patch

   # Build and tag image
   export VERSION=$(cat VERSION)
   docker build -t portfolio-app:v$VERSION .

   # Deploy to development
   ./scripts/deploy.sh development deploy
   ```

2. **Staging**

   ```bash
   # Tag image for staging
   docker tag portfolio-app:v$VERSION registry.company.com/portfolio-app:v$VERSION
   docker push registry.company.com/portfolio-app:v$VERSION

   # Deploy to staging
   ./scripts/deploy.sh staging deploy
   ```

3. **Production**

   ```bash
   # Deploy to production (after testing)
   ./scripts/deploy.sh production deploy
   ```

## 🛠️ Customization

### Environment Variables

Modify `k8s/overlays/[environment]/kustomization.yaml`:

```yaml
configMapGenerator:
  - name: portfolio-app-config
    literals:
      - NODE_ENV=production
      - LOG_LEVEL=info
      - CUSTOM_VAR=value
```

### Resource Limits

Modify `k8s/overlays/[environment]/resource-patch.yaml`:

```yaml
- op: replace
  path: /spec/template/spec/containers/0/resources
  value:
    requests:
      memory: '128Mi'
      cpu: '100m'
    limits:
      memory: '256Mi'
      cpu: '200m'
```

### Custom Domain

Update `k8s/base/ingress.yaml`:

```yaml
spec:
  rules:
    - host: your-domain.com # Change this
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: portfolio-app-service
                port:
                  number: 80
  tls:
    - hosts:
        - your-domain.com # Change this
      secretName: portfolio-tls
```

## 🔍 Monitoring & Debugging

### Check Application Health

```bash
# Port-forward to access application locally
kubectl port-forward -n portfolio-prod svc/portfolio-app-service-prod 8080:80

# Check health endpoint
curl http://localhost:8080/health
```

### View Logs

```bash
# View application logs
kubectl logs -n portfolio-prod -l app=portfolio-app -f

# View specific pod logs
kubectl logs -n portfolio-prod deployment/portfolio-app-prod -f
```

### Debug Deployment Issues

```bash
# Check pod status
kubectl get pods -n portfolio-prod -l app=portfolio-app

# Describe problematic pod
kubectl describe pod -n portfolio-prod <pod-name>

# Check events
kubectl get events -n portfolio-prod --sort-by='.lastTimestamp'
```

## 🔒 Security Best Practices

### Container Security

- ✅ **Non-root user**: Runs as nginx user (UID 101)
- ✅ **Read-only filesystem**: Prevents runtime modifications
- ✅ **Dropped capabilities**: Removes unnecessary privileges
- ✅ **Security context**: Enforces security policies

### Kubernetes Security

- ✅ **Network policies**: Control pod-to-pod communication
- ✅ **RBAC**: Role-based access control
- ✅ **Pod security standards**: Enforce security standards
- ✅ **SSL/TLS**: Encrypted communication via Ingress

### Image Security

```bash
# Scan image for vulnerabilities
docker scan portfolio-app:latest

# Use specific base image versions (not latest)
FROM nginx:1.25.3-alpine
```

## 📊 Performance Optimization

### Docker Optimizations

- **Multi-stage builds**: Minimize final image size
- **Layer caching**: Optimize Dockerfile layer order
- **Alpine Linux**: Lightweight base images
- **.dockerignore**: Exclude unnecessary files

### Kubernetes Optimizations

- **Resource requests/limits**: Prevent resource contention
- **HPA**: Auto-scale based on metrics
- **Node affinity**: Schedule pods on appropriate nodes
- **PodDisruptionBudget**: Ensure availability during updates

### Nginx Optimizations

- **Gzip compression**: Reduce transfer size
- **Browser caching**: Cache static assets
- **HTTP/2**: Improve connection efficiency
- **Security headers**: Enhance security

## 🆘 Troubleshooting

### Common Issues

1. **Image Pull Errors**

   ```bash
   # Check if image exists locally
   docker images portfolio-app

   # Re-tag with correct version
   export VERSION=$(cat VERSION)
   docker tag portfolio-app:latest portfolio-app:v$VERSION
   ```

2. **Pod CrashLoopBackOff**

   ```bash
   # Check container logs
   kubectl logs -n portfolio-prod <pod-name> --previous

   # Check if health check endpoint is working
   kubectl exec -n portfolio-prod <pod-name> -- curl localhost/health
   ```

3. **Ingress Not Working**

   ```bash
   # Check ingress controller
   kubectl get pods -n ingress-nginx

   # Check ingress resource
   kubectl describe ingress -n portfolio-prod portfolio-app-ingress-prod
   ```

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Tutorial](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Nginx Configuration](https://nginx.org/en/docs/)

---

## 🎉 Summary

You now have a **production-ready infrastructure** that includes:

- ✅ **Containerized application** with multi-stage Docker builds
- ✅ **Kubernetes manifests** with environment-specific overlays
- ✅ **Automated deployment scripts** for easy management
- ✅ **Semantic versioning** for release tracking
- ✅ **Security hardening** following best practices
- ✅ **Monitoring and health checks** built-in
- ✅ **Auto-scaling** for production workloads

Your portfolio application is ready to scale from development to production! 🚀
