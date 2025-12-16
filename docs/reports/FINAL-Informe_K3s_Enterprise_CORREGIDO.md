# INFORME EJECUTIVO UNIFICADO - MIGRACIÓN A K3S ENTERPRISE

## Identificación del Documento

**Proyecto:** AIOps OS Agent - Infraestructura Enterprise K3s  
**Autor:** Alberto (BoFeLu)  
**Rol:** Infrastructure Architect / DevOps Senior  
**Plataforma:** VM Ubuntu 24.04 LTS - VMware Workstation 17 Pro  
**Fecha de finalización:** 15 de diciembre de 2025  
**Estado:** STACK ENTERPRISE K3S COMPLETAMENTE OPERATIVO

---

# ÍNDICE

- [1. Resumen Ejecutivo y Métricas de Impacto](#1-resumen-ejecutivo-y-métricas-de-impacto)
  - [Métricas clave](#métricas-clave)
- [2. Arquitectura Enterprise y Especificaciones Técnicas](#2-arquitectura-enterprise-y-especificaciones-técnicas)
  - [2.1 Plataforma Base](#21-plataforma-base)
  - [2.2 Distribución Kubernetes K3s](#22-distribución-kubernetes-k3s)
  - [2.3 Stack de Aplicaciones](#23-stack-de-aplicaciones)
- [3. Comparativa Técnica Minikube vs K3s](#3-comparativa-técnica-minikube-vs-k3s)
- [4. Análisis de Riesgos y Problemas Resueltos](#4-análisis-de-riesgos-y-problemas-resueltos)
  - [Riesgos mitigados](#riesgos-mitigados)
  - [Problemas críticos resueltos](#problemas-críticos-resueltos)
- [5. Evidencia Técnica y Validación](#5-evidencia-técnica-y-validación)
- [6. Competencias Profesionales Demostradas](#6-competencias-profesionales-demostradas)
  - [Arquitectura y Plataforma](#arquitectura-y-plataforma)
  - [DevOps y Operaciones](#devops-y-operaciones)
  - [Seguridad y Gobernanza](#seguridad-y-gobernanza)
- [7. Roadmap Estratégico y Siguientes Fases](#7-roadmap-estratégico-y-siguientes-fases)
  - [Q1 2026 - Application Rebuilding](#q1-2026---application-rebuilding)
  - [Q2 2026 - Security & Governance](#q2-2026---security--governance)
  - [Q3-Q4 2026 - Service Mesh & Multi-Node](#q3-q4-2026---service-mesh--multi-node)
- [8. Conclusiones y Valor Empresarial](#8-conclusiones-y-valor-empresarial)
- [9. Anexos Técnicos](#9-anexos-técnicos)
  - [Comandos críticos](#comandos-críticos)
  - [YAMLs recomendados](#yamls-recomendados)
- [ANEXO A: Estado Pods](#anexo-a-estado-pods)
- [ANEXO B: Benchmarking Minikube vs K3s](#anexo-b-benchmarking-minikube-vs-k3s)
- [ANEXO C: Security Posture K3s Enterprise](#anexo-c-security-posture-k3s-enterprise)
- [ANEXO D: Capturas de Pantalla](#anexo-d-capturas-de-pantalla)

---

## 1. Resumen Ejecutivo y Métricas de Impacto

La migración de Minikube (entorno simulado) a Kubernetes K3s nativo sobre Ubuntu 24.04 representa un salto cualitativo hacia un entorno enterprise real, eliminando capas de simulación y validando capacidades profesionales avanzadas en arquitectura de infraestructura y DevOps.

**Resultado principal:** stack enterprise completamente operativo (Prometheus, Grafana y ArgoCD) en K3s nativo, con mejoras sustanciales en rendimiento, capacidad y fiabilidad.

### Métricas clave

- Incremento de memoria disponible: **+400%** (9.6 GB vs 2 GB)
- Storage persistente real: **110 GB libres**
- Runtime: **containerd nativo** (sin Docker-in-Docker)
- Incidencias críticas resueltas: **15+**
- Preparación para producción: **multi-nodo y service mesh ready**

## 2. Arquitectura Enterprise y Especificaciones Técnicas

![Arquitectura Enterprise K3s con observabilidad y GitOps integrados](images/diagramas/arquitectura-enterprise-k3s.png)

*Ilustración 1: Arquitectura Enterprise K3s con observabilidad y GitOps integrados*

### 2.1 Plataforma Base

- **SO:** Ubuntu 24.04.3 LTS (Kernel 6.14.0-37)
- **CPU:** Intel Core i5-12450H (4 cores)
- **RAM:** 12 GB asignados (9.6 GB utilizables)
- **Virtualización:** VMware Workstation 17 Pro
- **Storage:** 150 GB totales (110 GB disponibles)

### 2.2 Distribución Kubernetes K3s

- **Versión:** v1.33.6+k3s1
- **Runtime:** containerd 2.1.5-k3s1.33
- **CNI:** Flannel VXLAN
- **Control Plane:** single-node con metrics-server integrado

### 2.3 Stack de Aplicaciones

- **Prometheus:** recolección de métricas y service discovery
- **Grafana:** dashboards y visualización en tiempo real
- **ArgoCD:** GitOps y despliegue continuo

## 3. Comparativa Técnica Minikube vs K3s

| Aspecto | Minikube (Simulado) | K3s (Enterprise) |
|---------|-------------------|------------------|
| Memoria | 2 GB | 9.6 GB |
| Runtime | Docker-in-Docker | containerd nativo |
| Networking | Bridge virtual | Flannel VXLAN |
| Storage | Volúmenes emulados | Filesystem real |
| Escalabilidad | Limitada | Multi-node ready |

**Conclusión:** K3s elimina overhead, reduce latencia y ofrece un entorno alineado con producción real.

## 4. Análisis de Riesgos y Problemas Resueltos

### Riesgos mitigados

- Pérdida de configuración → Fresh start strategy
- Incompatibilidades CNI → análisis exhaustivo de networking
- RBAC insuficiente → ServiceAccounts y RoleBindings dedicados

### Problemas críticos resueltos

- **Fallo ArgoCD:** secret argocd-redis inexistente + RBAC incorrecto
- **Port-forward fallido:** desalineación entre targetPort y containerPort
- **ServiceAccount default sin permisos** → creación de cuenta dedicada

**Lecciones aprendidas:**
- K3s exige alineación exacta de puertos
- Instalaciones oficiales complejas requieren validación manual
- RBAC enterprise no debe apoyarse en cuentas por defecto

## 5. Evidencia Técnica y Validación

**Accesos confirmados:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- ArgoCD: http://localhost:8080

**Validación:**
- Port-forward concurrente y estable
- Stack operativo simultáneamente
- Troubleshooting completamente documentado

## 6. Competencias Profesionales Demostradas

### Arquitectura y Plataforma

- Migración completa de plataforma
- Diseño de arquitectura cloud-native
- Optimización de recursos y rendimiento

### DevOps y Operaciones

- Troubleshooting sistemático multi-capa
- Análisis de causa raíz
- Documentación técnica exhaustiva

### Seguridad y Gobernanza

- Implementación RBAC granular
- Gestión de secretos
- Estándares enterprise y auditabilidad

## 7. Roadmap Estratégico y Siguientes Fases

### Q1 2026 - Application Rebuilding

- Reconstrucción AIOps Agent
- HPA (2–10 pods)
- PodDisruptionBudgets

### Q2 2026 - Security & Governance

- SealedSecrets
- OPA/Gatekeeper
- Falco Runtime Security

### Q3-Q4 2026 - Service Mesh & Multi-Node

- Istio + mTLS
- Chaos Engineering
- Cluster multi-nodo y HA

## 8. Conclusiones y Valor Empresarial

La migración a K3s enterprise valida un perfil senior en arquitectura de infraestructura, con impacto directo en reducción de costes, aumento de fiabilidad y escalabilidad futura.

El sistema está documentado, y resulta reproducible y alineado con estándares enterprise reales.

**Valor profesional:**
- Infraestructura lista para producción
- Evidencia técnica y visual completa
- Roadmap claro hacia evolución avanzada

## 9. Anexos Técnicos

### Comandos críticos

```bash
# Instalación K3s
curl -sfL https://get.k3s.io | sh -
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
kubectl get nodes

# ArgoCD fixes
kubectl create secret generic argocd-redis --from-literal=auth=''
kubectl apply -f argocd-rbac.yaml
kubectl rollout restart deployment/argocd-server -n argocd

# Port-forward
kubectl port-forward svc/prometheus -n monitoring 9090:9090 &
kubectl port-forward svc/grafana -n monitoring 3000:3000 &
kubectl port-forward svc/argocd-server -n argocd 8080:80 &
```

### YAMLs recomendados

- argocd-server.yaml
- grafana-deployment.yaml
- prometheus-config.yaml
- sealedsecret-example.yaml
- networkpolicy.yaml

---

# ANEXOS

## ANEXO A: Estado Pods

### Verificar pods en monitoring
```bash
kubectl get pods -n monitoring
```

### Verificar pods en ArgoCD
```bash
kubectl get pods -n argocd
```

## ANEXO B: Benchmarking Minikube vs K3s

### Tabla 1: Comparativa de Recursos Base

| Métrica | Minikube (WSL2) | K3s (VM Ubuntu 24) | Mejora |
|---------|-----------------|---------------------|--------|
| **RAM Disponible** | 2 GB | 9.6 GB | +400% |
| **CPU Cores** | 2 cores virtualizados | 4 cores nativos | +100% |
| **Storage** | 20 GB limitado | 110 GB disponibles | +450% |
| **Runtime** | Docker-in-Docker | containerd nativo | Sin overhead |
| **Networking** | Bridge simulado | CNI Flannel VXLAN | Nativo |

### Tabla 2: Tiempos de Despliegue y Performance

| Componente | Minikube | K3s | Reducción |
|------------|----------|-----|-----------|
| **Inicio Cluster** | 45-60 segundos | 15-20 segundos | -67% |
| **Deploy Prometheus** | 2-3 minutos | 45-60 segundos | -60% |
| **Deploy Grafana** | 1-2 minutos | 30-45 segundos | -50% |
| **Deploy ArgoCD** | 3-5 minutos | 1-2 minutos | -60% |

## ANEXO C: Security Posture K3s Enterprise

### 1. RBAC IMPLEMENTADO

#### ServiceAccount ArgoCD Enterprise
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
```

#### Role Específico con Least Privilege
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argocd-server
  namespace: argocd
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
```

### 2. NETWORK POLICIES IMPLEMENTADAS

#### NetworkPolicy Base - Deny All
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: argocd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## ANEXO D: Capturas de Pantalla

### Troubleshooting ArgoCD - RBAC y Secrets
![Troubleshooting completo ArgoCD](images/capturas/troubleshooting-argocd-rbac.png)

*Ilustración 2: Troubleshooting completo ArgoCD - RBAC y secrets*

### Estado de Pods durante Recovery
![Estado pods ArgoCD durante recovery](images/capturas/pods-recovery-estado.png)

*Ilustración 3: Estado pods ArgoCD durante recovery*

### ArgoCD UI Operativa
![ArgoCD UI operativa](images/capturas/argocd-ui-operativa.png)

*Ilustración 4: ArgoCD UI operativa - "ArgoCD K3s Enterprise Ready"*

### Grafana Dashboard Accesible
![Grafana Dashboard](images/capturas/grafana-dashboard.png)

*Ilustración 5: Grafana Dashboard - "Welcome to Grafana"*

### Prometheus Query Interface Operativa
![Prometheus interface](images/capturas/prometheus-query-interface.png)

*Ilustración 6: Prometheus Query interface operativa*

---

**MIGRACIÓN K3S ENTERPRISE COMPLETADA CON ÉXITO**
