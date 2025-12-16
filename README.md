
# AIOps OS Agent - Enterprise K3s Infrastructure

[![Infrastructure Status](https://img.shields.io/badge/infrastructure-enterprise--ready-brightgreen)](./docs/reports/)
[![Kubernetes K3s](https://img.shields.io/badge/k3s-v1.33.6-blue)](https://k3s.io/)
[![Security Posture](https://img.shields.io/badge/security-hardened-green)](./docs/reports/)
[![Documentation](https://img.shields.io/badge/docs-executive--level-orange)](./docs/reports/FINAL-Informe_K3s_Enterprise_CORREGIDO.md)

## Índice

- [Descripción](#descripción)
- [Migración enterprise Minikube → K3s](#migración-enterprise-minikube--k3s)
- [Arquitectura enterprise](#arquitectura-enterprise)
- [Documentación ejecutiva](#documentación-ejecutiva)
- [Estado del proyecto](#estado-del-proyecto)
- [Instalación y despliegue](#instalación-y-despliegue)
- [Evidencia técnica](#evidencia-técnica)
- [Security posture](#security-posture)
- [Exposición de competencias](#exposición-de-competencias)
- [Portfolio profesional](#portfolio-profesional)

---

## Descripción

Sistema AIOps (Artificial Intelligence for IT Operations) con **infraestructura K3s enterprise** completamente migrada y validada. Proyecto que demuestra competencias de **Infrastructure Architect** con stack completo de observabilidad, seguridad y automatización.

**Desarrollado por:** Alberto (BoFeLu) - Infrastructure Architect / DevOps  
**Proyecto:** ASIR Final - Transición a Independent Researcher-Architect-Developer  
**Estado:** **MIGRACIÓN K3S ENTERPRISE COMPLETADA CON ÉXITO**

## Migración enterprise Minikube → K3s

### Resultados de la migración

- Incremento memoria: +400% (9.6GB vs 2GB)
- Performance: containerd nativo (elimina Docker-in-Docker)
- Escalabilidad: multi-node ready, service mesh prepared
- Troubleshooting: 15+ incidencias críticas resueltas
- Documentación: evidencia técnica completa con capturas

### Informe ejecutivo completo

**[Ver informe ejecutivo K3s enterprise](./docs/reports/FINAL-Informe_K3s_Enterprise_CORREGIDO.md)**
- 25+ páginas de documentación profesional
- 13 capturas técnicas con evidencia visual
- Benchmarking comparativo completo
- Security posture enterprise
- Roadmap estratégico Q1-Q4 2026

## Arquitectura enterprise

### Stack tecnológico actual
```
┌─────────────────────────────────────────┐
│                 Git                     │
│                  ↓                      │
│    ┌─────────┐  ┌─────────┐  ┌─────────┐│
│    │   K3s   │→ Prometheus│→ │Grafana  ││
│    └─────────┘  └─────────┘  └─────────┘│
│         ↓                               │
│    ┌────────────────────────────────────┤
│    │            ArgoCD                  │
│    └────────────────────────────────────┤
└─────────────────────────────────────────┘
```

### Especificaciones

- **Kubernetes:** K3s v1.33.6+k3s1 (migrado desde Minikube)
- **Runtime:** containerd 2.1.5-k3s1.33 nativo
- **CNI:** Flannel VXLAN enterprise
- **Observabilidad:** Prometheus + Grafana stack enterprise
- **GitOps:** ArgoCD con troubleshooting completo documentado
- **Seguridad:** RBAC granular, NetworkPolicies, PodSecurity Standards
- **Plataforma:** VM Ubuntu 24.04 LTS enterprise

## Documentación ejecutiva

### Informes principales

| Documento | Descripción | Estado |
|-----------|-------------|---------|
| **[Informe K3s enterprise](./docs/reports/FINAL-Informe_K3s_Enterprise_CORREGIDO.md)** | **Migración completa Minikube→K3s** | COMPLETADO |
| [Security assessment](./docs/security-assessment.md) | Análisis vulnerabilidades y mitigaciones | Completado |
| [Fase 1: infraestructura](./docs/1er-informe.docx) | Base Kubernetes hardened | Completado |
| [Fase 2: observabilidad](./docs/2o-informe.docx) | Prometheus + Grafana enterprise | Completado |

### Evidencia técnica

- 13 capturas técnicas con troubleshooting ArgoCD
- Benchmarking comparativo Minikube vs K3s
- Security posture completo con RBAC y NetworkPolicies
- Comandos de validación y YAMLs enterprise

## Estado del proyecto

### FASE ENTERPRISE: Migración K3s (COMPLETADA)
- **Migración exitosa** Minikube → K3s nativo
- **Stack enterprise operativo:** Prometheus + Grafana + ArgoCD
- **Troubleshooting completo:** 15+ problemas críticos resueltos
- **Documentación ejecutiva:** informe 25+ páginas con evidencia visual
- **Performance:** +400% incremento memoria, containerd nativo

### Fase 1-3: infraestructura, observabilidad, CI/CD (COMPLETADAS)
- Cluster Kubernetes hardened con security contexts
- Prometheus metrics collection con 26+ horas uptime  
- GitHub Actions pipeline con security scanning
- ArgoCD GitOps configurado y validado

### Roadmap estratégico 2026

- **Q1 2026:** application rebuilding (HPA, PodDisruptionBudgets)
- **Q2 2026:** security & governance (SealedSecrets, OPA/Gatekeeper, Falco)
- **Q3-Q4 2026:** service mesh & multi-node (Istio, chaos engineering)

## Instalación y despliegue

### Prerequisitos enterprise

- **K3s v1.33.6+** 
- **kubectl** configurado
- **VM Ubuntu 24.04 LTS**
- **Git** y acceso al repositorio

### Instalación K3s stack
```bash
# Clonar repositorio
git clone https://github.com/BoFeLu/aiops_os_agent.git
cd aiops_os_agent

# Instalación K3s enterprise
curl -sfL https://get.k3s.io | sh -
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Desplegar stack enterprise
kubectl apply -f k8s/
kubectl apply -f manifests/

# Setup ArgoCD (con troubleshooting documentado)
./scripts/setup-argocd.sh
```

### Accesos validados
```bash
# Port-forward enterprise (concurrente y estable)
kubectl port-forward svc/prometheus -n monitoring 9090:9090 &
kubectl port-forward svc/grafana -n monitoring 3000:3000 &  
kubectl port-forward svc/argocd-server -n argocd 8080:80 &
```

- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000
- **ArgoCD:** http://localhost:8080

## Evidencia técnica

### Capturas documentadas

| Evidencia | Descripción |
|-----------|-------------|
| **Troubleshooting ArgoCD** | RBAC y secrets resolution completo |
| **Estado pods recovery** | CreateContainerConfigError → Running |
| **ArgoCD UI operativa** | "ArgoCD K3s Enterprise Ready" |
| **Grafana dashboard** | "Welcome to Grafana" accesible |
| **Prometheus interface** | Query interface operativa |

Ver todas las capturas en: [informe ejecutivo](./docs/reports/FINAL-Informe_K3s_Enterprise_CORREGIDO.md)

## Security posture

### Hardening implementado

- **RBAC granular:** ServiceAccounts específicos por aplicación
- **NetworkPolicies:** microsegmentación implementada
- **PodSecurity Standards:** "restricted" enforced
- **Secret management:** Kubernetes secrets con rotation capability
- **Security contexts:** non-root obligatorios

### Compliance enterprise

- RBAC granular: least privilege implementado
- Network segmentation: namespaces aislados
- Audit logging: K3s audit logs habilitados
- En progreso: SealedSecrets, OPA/Gatekeeper
- Planificado: Falco runtime security, Vault integration

## Exposición de competencias

### Architecture & platform engineering
- **Migración completa** de plataforma enterprise
- **Infrastructure design** cloud-native
- **Performance optimization** systemd integration

### DevOps & operational excellence  
- **Troubleshooting sistemático** multi-capa
- **Root cause analysis** metodológico
- **Documentation excellence** auditabilidad enterprise

### Enterprise security & governance
- **RBAC implementation** granular
- **Secret management** lifecycle
- **Enterprise standards** compliance

## Portfolio profesional

Este proyecto forma parte del **portfolio para transición a Infrastructure Architect** con evidencia completa de:

### Logros técnicos validados
- **Migración platform** exitosa con documentación ejecutiva
- **Performance enterprise** +400% incremento recursos
- **Stack operativo** completo con evidencia visual
- **Metodología rigurosa** sistemática documentada

### Valor empresarial
- **Competencias** Infrastructure Architect demostradas
- **Portfolio professional** evidencia técnica completa  
- **Roadmap estratégico** evolución enterprise
- **Preparación roles** DevOps organizaciones

---

## Contribución

**Metodología:** documentación exhaustiva, verificación paso a paso, enterprise-ready standards.

## Licencia

MIT License - Ver [LICENSE](LICENSE) para detalles

---

**Alberto (BoFeLu)** - Infrastructure Architect / DevOps  
[GitHub](https://github.com/BoFeLu) | [Portfolio](https://github.com/BoFeLu?tab=repositories)  
**MIGRACIÓN K3S ENTERPRISE COMPLETADA CON ÉXITO**
