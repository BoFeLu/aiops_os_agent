# AIOps OS Agent - Enterprise Kubernetes Infrastructure

[![CI/CD Pipeline](https://github.com/BoFeLu/aiops_os_agent/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/BoFeLu/aiops_os_agent/actions)
[![Security Scan](https://img.shields.io/badge/security-hardened-green)](./docs/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.34.0-blue)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/argocd-gitops-orange)](https://argoproj.github.io/argo-cd/)

## Descripción

Sistema AIOps (Artificial Intelligence for IT Operations) con infraestructura Kubernetes enterprise-grade, observabilidad completa y automatización CI/CD GitOps.

**Desarrollado por:** Alberto (BoFeLu) - DevOps Engineer  
**Proyecto:** ASIR Final - Transición a Independent Researcher-Architect-Developer

## Arquitectura

### Stack Tecnológico
- **Kubernetes:** Minikube v1.37.0 con k8s v1.34.0 (migración desde K3s)
- **Observabilidad:** Prometheus + Grafana stack enterprise
- **CI/CD:** GitHub Actions + ArgoCD GitOps
- **Seguridad:** RBAC, NetworkPolicies, PodSecurity Standards restricted
- **Automatización:** Scripts bash enterprise-ready con logging

### Componentes Principales
```
├── AIOps Agent (namespace: aiops)
├── Observability Stack (namespace: monitoring)  
├── ArgoCD GitOps (namespace: argocd)
└── CI/CD Pipeline (GitHub Actions)
```

## Estado del Proyecto

### ✅ Fase 1: Infraestructura Base (COMPLETADA)
- Cluster Kubernetes hardened con security contexts
- Namespaces con Pod Security Standards restricted
- RBAC configurado con principio mínimo privilegio

### ✅ Fase 2: Observabilidad Enterprise (COMPLETADA)  
- Prometheus metrics collection con 26+ horas uptime
- Grafana dashboards configurados (ver screenshots)
- AlertManager integrado con notificaciones
- 630+ heartbeats AIOps Agent documentados

### ✅ Fase 3: CI/CD GitOps (COMPLETADA)
- GitHub Actions pipeline con Trivy security scanning
- ArgoCD instalado y configurado con auto-sync
- Multi-environment deployments (staging/production)
- Automated container builds multi-platform (amd64/arm64)

###  Próximas Fases
- **Fase 4:** Políticas seguridad avanzada (OPA/Gatekeeper)
- **Fase 5:** Migración VM producción (K3s nativo)

## Screenshots

### Grafana Dashboard
![Grafana Dashboard](docs/grafana-dashboard.png)

### ArgoCD Applications
![ArgoCD Apps](docs/argocd-applications.png)

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
**LECCIONES APRENDIDAS sobre WSL2 y Kubernetes 1.32.0.Actualización de la sección de 'Instalación' y 'Problemas Conocidos':**
**Asegúrate de que en Windows 11/WSL2 la versión recomendada es la 1.32.0 y que el uso de un usuario no-root es obligatorio para el hardening del sistema**

## Especificaciones de Despliegue en Entornos Virtualizados (Windows 11 + WSL2)

Debido a las particularidades de red y virtualización del driver de Docker en WSL2, se han establecido las siguientes directrices obligatorias para garantizar la estabilidad del API Server (puerto 8443).

### Requisitos de Infraestructura Local
* **Recursos Asignados:** Mínimo 2 vCPUs y 4096 MB de RAM. Configuraciones inferiores provocan el fallo de los probes de salud en el stack de observabilidad.
* **Versión de Kubernetes:** Se establece la v1.32.0 como estándar de estabilidad para este entorno, evitando los timeouts de conectividad identificados en la v1.34.0.

### Protocolo de Seguridad y Gestión (Hardening)
* **Gestión de Privilegios:** Queda estrictamente prohibida la ejecución de Minikube bajo el usuario `root`. Se ha implementado el usuario dedicado `aiops_user` para todas las operaciones del clúster.
* **Identificación de Errores (Troubleshooting):**
    * `DRV_AS_ROOT`: Error de seguridad por ejecución con privilegios de superusuario. Solución: `su - aiops_user`.
    * `K8S_APISERVER_MISSING`: Fallo crítico de conectividad con el control plane. Solución: Verificación de recursos y downgrade a v1.32.0.

### Accesos
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000 (credenciales en `scripts/argocd-credentials.txt`)
- **ArgoCD:** https://localhost:8080 (credenciales en `scripts/argocd-credentials.txt`)

## Seguridad

### Hardening Implementado
- PodSecurity Standards "restricted" enforced
- NetworkPolicies restrictivas activas (4 políticas)
- Security Contexts non-root obligatorios
- Resource limits configurados
- RBAC mínimo privilegio

### Gestión de Vulnerabilidades
- **CVE Scan:** 496 críticas, 54 altas identificadas
- **Mitigaciones:** Implementadas para entorno desarrollo
- **Informe completo:** Ver [`docs/security-assessment.md`](./docs/)
- **Evaluación de riesgo:** ACEPTABLE con controles implementados

## Documentación

- [`docs/security-assessment.md`](./docs/) - Informe seguridad y mitigaciones
- [`docs/1er-informe.docx`](./docs/) - Informe Fase 1
- [`docs/2o-informe.docx`](./docs/) - Informe Fase 2  
- [`informe-fase2`](./informe-fase2) - Documentación técnica Fase 2
- [`INFORME BRUTAL Y DIVERTIDO.docx`](.) - Informe completo proyecto

## Scripts Automatización

### Gestión Cluster
```bash
# Gestión completa K8s con logging
./scripts/aiops_k8s_manager_enhanced.sh

# Hardening seguridad enterprise
./scripts/harden_aiops_k8s.sh

# Gestión imágenes Docker
./scripts/manage_aiops_images.sh

# Setup ArgoCD con verificación
./scripts/setup-argocd.sh
```

## CI/CD Pipeline

### GitHub Actions
- **Security scanning:** Trivy filesystem y container scan
- **Multi-platform builds:** amd64/arm64 con cache optimizado
- **Automated deployments:** Staging (develop) y Production (main)
- **Container registry:** GitHub Container Registry

### ArgoCD GitOps
- **Auto-sync:** Habilitado con self-healing
- **Multi-environment:** Support staging/production
- **RBAC integrado:** Políticas granulares
- **Rollback automático:** En caso de fallos

## Monitorización

### Métricas Clave
- **AIOps Agent:** 630+ heartbeats documentados, 26+ horas uptime
- **Prometheus:** Métricas cluster completas con retention 15d
- **Grafana:** Dashboards enterprise con alertas configuradas
- **ArgoCD:** Deployment tracking automático con notificaciones

### Alerts Configuradas
- Pod health checks con threshold 90%
- Resource utilization (CPU >80%, Memory >85%)
- Network connectivity cross-namespace
- Security compliance violations

## Contribución

Este proyecto forma parte del portfolio profesional para transición a trabajo independiente en DevOps y AI Infrastructure.

**Metodología:** Documentación exhaustiva, verificación paso a paso, enterprise-ready standards.

## Licencia

MIT License - Ver [LICENSE](LICENSE) para detalles

---

**Alberto (BoFeLu)** - DevOps Engineer  
📧 [Contacto via GitHub](https://github.com/BoFeLu)  
🔗 [Portfolio Projects](https://github.com/BoFeLu?tab=repositories)
