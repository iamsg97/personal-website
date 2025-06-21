# Kubernetes Monitoring with Kustomize - Quick Reference

This guide shows you how to monitor, debug, and troubleshoot your Kubernetes deployments that were created using Kustomize.

## 🔍 Quick Monitoring Commands

### Basic Status Check

```bash
# Quick overview of all resources
./scripts/deploy.sh development status

# Detailed status with troubleshooting info
./scripts/deploy.sh development detailed

# Check production environment
./scripts/deploy.sh production status
```

### Pod Monitoring

```bash
# List all pods in the namespace
kubectl get pods -n portfolio-dev -l app=portfolio-app

# Get detailed pod information
kubectl get pods -n portfolio-dev -l app=portfolio-app -o wide

# Watch pods in real-time
kubectl get pods -n portfolio-dev -l app=portfolio-app -w
```

### Deployment Monitoring

```bash
# Check deployment status
kubectl get deployments -n portfolio-dev -l app=portfolio-app

# Check deployment rollout status
kubectl rollout status deployment/portfolio-app-dev -n portfolio-dev

# Check deployment history
kubectl rollout history deployment/portfolio-app-dev -n portfolio-dev
```

## 📋 Log Management

### Application Logs

```bash
# Show recent logs (last 50 lines)
./scripts/deploy.sh development logs

# Follow logs in real-time
./scripts/deploy.sh development logs -f

# Show last 100 lines
./scripts/deploy.sh development logs -l 100

# Show logs for specific pod
./scripts/deploy.sh development logs -p portfolio-app-dev-xxxxx
```

### Direct kubectl Log Commands

```bash
# Get logs from all pods with label
kubectl logs -n portfolio-dev -l app=portfolio-app --tail=50

# Follow logs from all pods
kubectl logs -n portfolio-dev -l app=portfolio-app -f

# Get logs from specific pod
kubectl logs -n portfolio-dev portfolio-app-dev-xxxxx

# Get previous container logs (if pod restarted)
kubectl logs -n portfolio-dev portfolio-app-dev-xxxxx --previous
```

## 🔧 Debugging Commands

### Describe Resources

```bash
# Describe all resources
./scripts/deploy.sh development describe

# Describe only pods
./scripts/deploy.sh development describe pods

# Describe deployments
./scripts/deploy.sh development describe deployments

# Describe services
./scripts/deploy.sh development describe services
```

### Debug Common Issues

```bash
# Run comprehensive debugging
./scripts/deploy.sh development debug

# Check events in the namespace
kubectl get events -n portfolio-dev --sort-by='.lastTimestamp'

# Check node resources
kubectl top nodes

# Check pod resource usage
kubectl top pods -n portfolio-dev
```

## 🚨 Troubleshooting Scenarios

### 1. Pod Not Starting (CrashLoopBackOff)

```bash
# Check pod status
kubectl get pods -n portfolio-dev -l app=portfolio-app

# Describe the problematic pod
kubectl describe pod <pod-name> -n portfolio-dev

# Check logs
kubectl logs <pod-name> -n portfolio-dev --previous

# Common issues to look for:
# - Image pull errors
# - Application startup failures
# - Resource constraints
# - Health check failures
```

### 2. Service Not Accessible

```bash
# Check service
kubectl get svc -n portfolio-dev -l app=portfolio-app

# Check endpoints
kubectl get endpoints -n portfolio-dev

# Check if service selector matches pod labels
kubectl describe svc portfolio-app-service-dev -n portfolio-dev
```

### 3. Ingress Issues

```bash
# Check ingress status
kubectl get ingress -n portfolio-dev -l app=portfolio-app

# Describe ingress
kubectl describe ingress portfolio-app-ingress-dev -n portfolio-dev

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### 4. Image Pull Problems

```bash
# Check if image exists locally or in registry
docker images portfolio-app

# Verify image tag in deployment
kubectl get deployment portfolio-app-dev -n portfolio-dev -o yaml | grep image:

# Check imagePullSecrets if using private registry
kubectl get secrets -n portfolio-dev
```

## 📊 Resource Monitoring

### Check Resource Usage

```bash
# Pod resource usage
kubectl top pods -n portfolio-dev -l app=portfolio-app

# Node resource usage
kubectl top nodes

# Check resource requests/limits
kubectl describe pod <pod-name> -n portfolio-dev | grep -A 10 "Requests\|Limits"
```

### Horizontal Pod Autoscaler (Production)

```bash
# Check HPA status
kubectl get hpa -n portfolio-prod

# Describe HPA
kubectl describe hpa portfolio-app-hpa -n portfolio-prod

# Watch HPA in real-time
kubectl get hpa -n portfolio-prod -w
```

## 🔄 Deployment Operations

### Rolling Updates

```bash
# Check rollout status
kubectl rollout status deployment/portfolio-app-dev -n portfolio-dev

# Check rollout history
kubectl rollout history deployment/portfolio-app-dev -n portfolio-dev

# Rollback to previous version
kubectl rollout undo deployment/portfolio-app-dev -n portfolio-dev

# Rollback to specific revision
kubectl rollout undo deployment/portfolio-app-dev -n portfolio-dev --to-revision=2
```

### Scaling Operations

```bash
# Scale deployment manually
kubectl scale deployment portfolio-app-dev -n portfolio-dev --replicas=3

# Check current replica count
kubectl get deployment portfolio-app-dev -n portfolio-dev
```

## 🔗 Connectivity Testing

### Test Service Connectivity

```bash
# Port-forward to test locally
kubectl port-forward -n portfolio-dev svc/portfolio-app-service-dev 8080:80

# Test health endpoint
curl http://localhost:8080/health

# Test from within cluster (using a debug pod)
kubectl run debug-pod --image=curlimages/curl -it --rm -- /bin/sh
# Then inside the pod: curl http://portfolio-app-service-dev.portfolio-dev.svc.cluster.local/health
```

### DNS Resolution Testing

```bash
# Test DNS resolution from within cluster
kubectl run dns-test --image=busybox -it --rm -- nslookup portfolio-app-service-dev.portfolio-dev.svc.cluster.local
```

## 📋 Environment Comparison

### Compare Configurations Across Environments

```bash
# Generate manifests for different environments
kustomize build k8s/overlays/development > dev-manifests.yaml
kustomize build k8s/overlays/production > prod-manifests.yaml

# Compare the differences
diff dev-manifests.yaml prod-manifests.yaml
```

## ⚡ Quick Commands Cheat Sheet

```bash
# 🔍 MONITORING
./scripts/deploy.sh <env> status          # Quick status
./scripts/deploy.sh <env> detailed        # Detailed status
./scripts/deploy.sh <env> logs -f         # Follow logs
./scripts/deploy.sh <env> debug           # Debug issues

# 🚀 DEPLOYMENT
./scripts/deploy.sh <env> deploy          # Deploy
./scripts/deploy.sh <env> dry-run         # Preview
./scripts/deploy.sh <env> diff            # Show changes

# 🔧 TROUBLESHOOTING
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl top pods -n <namespace>

# 🔄 OPERATIONS
kubectl rollout status deployment/<name> -n <namespace>
kubectl rollout undo deployment/<name> -n <namespace>
kubectl scale deployment <name> -n <namespace> --replicas=N
```

## 🎯 Environment-Specific Namespaces

- **Development**: `portfolio-dev`
- **Staging**: `portfolio-staging`
- **Production**: `portfolio-prod`

Replace `<env>` with: `development`, `staging`, or `production`
Replace `<namespace>` with the appropriate namespace above.

---

## 💡 Pro Tips

1. **Use labels consistently** - All resources have `app=portfolio-app` label for easy filtering
2. **Monitor events** - Events often contain the most useful debugging information
3. **Check health endpoints** - Use `/health` endpoint to verify application is responding
4. **Resource monitoring** - Always check if pods have enough CPU/memory
5. **Log aggregation** - In production, consider using ELK stack or similar for centralized logging
6. **Alerting** - Set up monitoring and alerting for production environments

This comprehensive monitoring setup gives you full visibility into your Kubernetes deployments! 🚀
