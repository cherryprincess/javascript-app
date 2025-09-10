# Standardized DevSecOps Implementation Prompt

## Copy and Use This Prompt for ANY Application

```
**UNIVERSAL DEVSECOPS IMPLEMENTATION REQUEST**

Start generating below required files, do it step by step, move to next step only after finishing generating the current file.

**Step 1: Intelligent Application Analysis**
Analyze the provided workspace/codebase and automatically detect:
- Primary language, version, and framework
- Package manager and build system  
- Application type (web app, API, microservice, static site, etc.)
- Dependencies and runtime requirements
- Port configuration and environment needs
- Special requirements (databases, background jobs, etc.)

**Step 2: Create Secure Dockerfile**
Intelligently generate a production-ready, secure Dockerfile:
- Auto-select latest secure base images for detected language/version
- Dynamically determine multi-stage build requirements
- Apply security hardening (non-root user, minimal attack surface)
- Generate framework-appropriate health checks and endpoints
- Include robust dependency installation with language-specific fallbacks
- Create optimized .dockerignore with intelligent exclusions

**Step 3: Create Kubernetes Deployment Files**
Generate intelligent Kubernetes manifests:
- Auto-size resources based on application complexity and framework
- Apply progressive health check timing appropriate for detected technology
- Configure security contexts and network policies
- Generate ConfigMaps from detected environment requirements
- Include HorizontalPodAutoscaler with appropriate metrics
- Use namespace: github-copilot-ns

**Step 4: Push to GitHub Repository**
Commit and push all generated files to the GitHub repository:
- Repository URL: https://github.com/cherryprincess/javascript-app.git
- Ensure proper git workflow and branch management

**Step 5: Create GitHub Actions CI/CD Pipeline**
Generate dynamic CI/CD workflow:
- Auto-detect language versions from config files (package.json, pom.xml, etc.)
- Apply robust dependency installation with technology-specific fallbacks
- Generate build processes using detected build systems and scripts
- Configure Trivy security scanning appropriate for application type
- Set intelligent deployment timeouts based on framework complexity
- Deploy to target infrastructure with proper rollback strategies

**Infrastructure Requirements:**
- Platform: Azure AKS
- Container Registry: ACR
- Deployment Target: Kubernetes cluster
- Triggers: push to master

**Security Credentials (stored as individual GitHub secrets):**
[AZURE]
- AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID
- REGISTRY_LOGIN_SERVER, REGISTRY_USERNAME, REGISTRY_PASSWORD
- AKS_CLUSTER_NAME, AKS_RESOURCE_GROUP

**Important Notes:**
- I don't have Docker or Kubernetes locally, so ensure all commands run in CI/CD pipeline
- Use individual credential secrets (NOT JSON format)
- Include comprehensive error handling and fallback strategies
- Generate production-ready configurations with security best practices
- Ensure compatibility with the detected technology stack
```

## 📋 Troubleshooting Guide

### Common Issues & Solutions:
1. **npm ci failure**: Use `npm install --legacy-peer-deps` as fallback
2. **Missing package-lock.json**: Generate and commit to repository for consistent builds
3. **react-scripts binary missing**: Install explicitly with `npm install react-scripts@5.0.0`
4. **Security scan failures**: Review Trivy output, update base images and dependencies
5. **Deployment timeouts**: Increase health check `initialDelaySeconds` and `failureThreshold`
6. **Pod startup failures**: Check resource limits and security contexts
7. **Image pull errors**: Verify ACR credentials and registry connectivity

### Debug Commands:
```bash
# Check deployment status
kubectl get pods -n github-copilot-ns
kubectl describe deployment <app-name> -n github-copilot-ns

# View logs
kubectl logs -f deployment/<app-name> -n github-copilot-ns

# Check services and endpoints
kubectl get svc,endpoints -n github-copilot-ns

# Verify security policies
kubectl get networkpolicy,psp -n github-copilot-ns
```

---

## 🎯 Usage Instructions

1. **Copy the prompt above**
2. **Update the repository URL** if different from the example
3. **Choose your cloud platform** (modify Azure sections for AWS/GCP if needed)
4. **Provide your application codebase** to the AI agent
5. **The agent will automatically adapt** all configurations for your technology stack

## ✅ What This Prompt Delivers

- **Secure Dockerfile** with multi-stage builds and vulnerability management
- **Production Kubernetes manifests** with security best practices
- **Complete CI/CD pipeline** with automated security scanning
- **Infrastructure as Code** approach with GitOps workflow
- **Comprehensive monitoring** and health check configuration
- **Robust error handling** with proven fallback strategies

## 🚀 Supported Technologies

This prompt automatically works with:
- **Languages**: Node.js, Python, Java, .NET, Go, Rust, PHP
- **Frameworks**: React, Vue, Angular, Express, Django, Flask, Spring Boot
- **Build Systems**: npm/yarn, pip, maven/gradle, dotnet, go build, cargo
- **Application Types**: SPAs, APIs, microservices, static sites, full-stack apps

The AI agent will detect your technology stack and generate appropriate configurations automatically!
