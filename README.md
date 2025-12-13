# AIOps OS Agent - Enterprise Kubernetes Infrastructure

[![CI/CD Pipeline](https://github.com/BoFeLu/aiops_os_agent/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/BoFeLu/aiops_os_agent/actions)
[![Security Scan](https://img.shields.io/badge/security-hardened-green)](./docs/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.29-blue)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/argocd-gitops-orange)](https://argoproj.github.io/argo-cd/)

## Descripción

Sistema AIOps (Artificial Intelligence for IT Operations) con infraestructura Kubernetes enterprise-grade, observabilidad completa y automatización CI/CD GitOps.

**Desarrollado por:** Alberto (BoFeLu) - DevOps Engineer  
**Proyecto:** ASIR Final - Transición a Independent Researcher-Architect-Developer

## Arquitectura

### Stack Tecnológico
- **Kubernetes:** Minikube v1.37.0 (migración desde K3s)
- **Observabilidad:** Prometheus + Grafana stack
- **CI/CD:** GitHub Actions + ArgoCD GitOps
- **Seguridad:** RBAC, NetworkPolicies, PodSecurity Standards
- **Automatización:** Scripts bash enterprise-ready

### Componentes Principales
```
├── AIOps Agent (namespace: aiops)
├── Observability Stack (namespace: monitoring)  
├── ArgoCD GitOps (namespace: argocd)
└── CI/CD Pipeline (GitHub Actions)
```

## Estado del Proyecto

### ✅ Fase 1: Infraestructura Base (COMPLETADA)
- Cluster Kubernetes hardened
- Namespaces con security contexts
- RBAC configurado

### ✅ Fase 2: Observabilidad Enterprise (COMPLETADA)  
- Prometheus metrics collection
- Grafana dashboards configurados
- AlertManager integrado
- 630+ heartbeats AIOps Agent documentados

### ✅ Fase 3: CI/CD GitOps (COMPLETADA)
- GitHub Actions pipeline con security scanning
- ArgoCD instalado y configurado
- Multi-environment deployments (staging/production)
- Automated container builds y pushes

### 🚀 Próximas Fases
- **Fase 4:** Políticas seguridad avanzada (OPA/Gatekeeper)
- **Fase 5:** Migración VM producción (K3s nativo)

## Inicio Rápido

### Prerequisitos
- Minikube v1.37.0+
- kubectl configurado
- Docker Desktop
- Git

### Instalación
```bash
# Clonar repositorio
git clone https://github.com/BoFeLu/aiops_os_agent.git
cd aiops_os_agent

# Iniciar Minikube
minikube start

# Desplegar infraestructura
kubectl apply -f manifests/

# Instalar ArgoCD
./scripts/setup-argocd.sh

# Acceso a servicios
kubectl port-forward svc/prometheus -n monitoring 9090:9090
kubectl port-forward svc/grafana -n monitoring 3000:3000  
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Accesos
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000 (admin/aiops123)
- **ArgoCD:** https://localhost:8080 (admin/ver credentials.txt)

## Seguridad

### Hardening Implementado
- PodSecurity Standards "restricted" enforced
- NetworkPolicies restrictivas activas
- Security Contexts non-root obligatorios
- Resource limits configurados
- RBAC mínimo privilegio

### Vulnerabilidades Gestionadas
- CVE Scan: 496 críticas, 54 altas identificadas
- Mitigaciones implementadas para desarrollo
- Evaluación de riesgo: ACEPTABLE con controles

## Documentación

- [`docs/1er-informe.docx`](./docs/) - Informe Fase 1
- [`docs/2o-informe.docx`](./docs/) - Informe Fase 2  
- [`informe-fase2`](./informe-fase2) - Documentación técnica Fase 2
- [`INFORME BRUTAL Y DIVERTIDO.docx`](.) - Informe completo proyecto

## Scripts Automatización

### Gestión Cluster
```bash
# Gestión completa K8s
./scripts/aiops_k8s_manager_enhanced.sh

# Hardening seguridad
./scripts/harden_aiops_k8s.sh

# Gestión imágenes  
./scripts/manage_aiops_images.sh

# Setup ArgoCD
./scripts/setup-argocd.sh
```

## CI/CD Pipeline

### GitHub Actions
- Security scanning (Trivy)
- Multi-platform builds (amd64/arm64)
- Automated deployments
- Container registry (GitHub Container Registry)

### ArgoCD GitOps
- Auto-sync habilitado
- Multi-environment support
- Self-healing deployments
- RBAC integrado

## Monitorización

### Métricas Clave
- **AIOps Agent:** 630+ heartbeats documentados, 26+ horas uptime
- **Prometheus:** Métricas cluster completas
- **Grafana:** Dashboards enterprise configurados
- **ArgoCD:** Deployment tracking automático

### Alerts Configuradas
- Pod health checks
- Resource utilization
- Network connectivity
- Security compliance

## Contribución

Este proyecto forma parte del portfolio profesional para transición a trabajo independiente en DevOps y AI Infrastructure.

**Metodología:** Documentación exhaustiva, verificación paso a paso, enterprise-ready standards.

## Licencia

Proyecto académico - ASIR DevOps Specialization

---

**Alberto (BoFeLu)** - DevOps Engineer  
📧 [Contacto via GitHub](https://github.com/BoFeLu)  
🔗 [Portfolio Projects](https://github.com/BoFeLu?tab=repositories)
