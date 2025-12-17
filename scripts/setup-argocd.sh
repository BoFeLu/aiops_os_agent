#!/bin/bash

# AIOps OS Agent - ArgoCD Setup Script
# Fase 3: CI/CD Implementation
# Alberto (BoFeLu) - DevOps Engineer

set -euo pipefail

# Variables de configuración
NAMESPACE_ARGOCD="argocd"
ARGOCD_VERSION="stable"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/argocd-setup-$(date +%Y%m%d_%H%M%S).log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

# Función para verificar prerequisitos
check_prerequisites() {
    log_step "Verificando prerequisitos..."
    
    # Verificar kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl no está instalado"
        exit 1
    fi
    
    # Verificar conexión al cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "No se puede conectar al cluster Kubernetes"
        exit 1
    fi
    
    # Verificar Minikube status
    if ! minikube status &> /dev/null; then
        log_error "Minikube no está ejecutándose"
        exit 1
    fi
    
    log_info "Prerequisitos verificados correctamente"
}

# Función para crear namespace ArgoCD
create_argocd_namespace() {
    log_step "Creando namespace ArgoCD..."
    
    kubectl create namespace "$NAMESPACE_ARGOCD" --dry-run=client -o yaml | kubectl apply -f -
    
    # Aplicar labels de seguridad
    kubectl label namespace "$NAMESPACE_ARGOCD" \
        pod-security.kubernetes.io/enforce=baseline \
        pod-security.kubernetes.io/audit=baseline \
        pod-security.kubernetes.io/warn=baseline \
        --overwrite
    
    log_info "Namespace ArgoCD creado: $NAMESPACE_ARGOCD"
}

# Función para instalar ArgoCD
install_argocd() {
    log_step "Instalando ArgoCD..."
    
    # Descargar e instalar manifests de ArgoCD
    kubectl apply -n "$NAMESPACE_ARGOCD" -f "https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml"
    
    log_info "Manifests de ArgoCD aplicados"
    
    # Esperar a que los pods estén ready
    log_step "Esperando a que ArgoCD esté listo..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n "$NAMESPACE_ARGOCD" --timeout=600s
    
    log_info "ArgoCD instalado correctamente"
}

# Función para configurar acceso ArgoCD
configure_argocd_access() {
    log_step "Configurando acceso a ArgoCD..."
    
    # Cambiar servicio a NodePort para acceso local
    kubectl patch svc argocd-server -n "$NAMESPACE_ARGOCD" -p '{"spec": {"type": "NodePort"}}'
    
    # Obtener la contraseña inicial del admin
    local admin_password
    admin_password=$(kubectl -n "$NAMESPACE_ARGOCD" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    # Obtener el puerto del servicio
    local nodeport
    nodeport=$(kubectl get svc argocd-server -n "$NAMESPACE_ARGOCD" -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
    
    # Obtener la IP de Minikube
    local minikube_ip
    minikube_ip=$(minikube ip)
    
    log_info "ArgoCD configurado:"
    echo -e "${GREEN}URL:${NC} https://$minikube_ip:$nodeport"
    echo -e "${GREEN}Usuario:${NC} admin"
    echo -e "${GREEN}Contraseña:${NC} $admin_password"
    
    # Guardar credenciales en archivo
    cat > "$SCRIPT_DIR/argocd-credentials.txt" <<EOF
ArgoCD Access Information
========================
URL: https://$minikube_ip:$nodeport
Username: admin
Password: $admin_password

Port Forward Command (alternativo):
kubectl port-forward svc/argocd-server -n argocd 8080:443

Access URL (port-forward): https://localhost:8080
EOF
    
    log_info "Credenciales guardadas en: $SCRIPT_DIR/argocd-credentials.txt"
}

# Función para aplicar configuraciones adicionales
apply_argocd_configurations() {
    log_step "Aplicando configuraciones adicionales de ArgoCD..."
    
    # Aplicar RBAC y NetworkPolicies
    if [[ -f "$SCRIPT_DIR/../k8s/argocd/argocd-install.yaml" ]]; then
        kubectl apply -f "$SCRIPT_DIR/../k8s/argocd/argocd-install.yaml"
        log_info "Configuraciones adicionales aplicadas"
    else
        log_warn "Archivo de configuraciones adicionales no encontrado"
    fi
}

# Función para crear aplicaciones ArgoCD
create_argocd_applications() {
    log_step "Creando aplicaciones ArgoCD..."
    
    # Esperar a que ArgoCD API esté disponible
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=server -n "$NAMESPACE_ARGOCD" --timeout=300s
    
    # Aplicar definiciones de aplicaciones
    if [[ -f "$SCRIPT_DIR/../k8s/applications/argocd-applications.yaml" ]]; then
        # Esperar un poco más para que ArgoCD esté completamente listo
        sleep 30
        kubectl apply -f "$SCRIPT_DIR/../k8s/applications/argocd-applications.yaml"
        log_info "Aplicaciones ArgoCD creadas"
    else
        log_warn "Archivo de aplicaciones ArgoCD no encontrado"
    fi
}

# Función para verificar instalación
verify_installation() {
    log_step "Verificando instalación..."
    
    # Verificar pods de ArgoCD
    local argocd_pods
    argocd_pods=$(kubectl get pods -n "$NAMESPACE_ARGOCD" --no-headers | wc -l)
    
    if [[ $argocd_pods -gt 0 ]]; then
        log_info "ArgoCD pods verificados: $argocd_pods pods ejecutándose"
        kubectl get pods -n "$NAMESPACE_ARGOCD"
    else
        log_error "No se encontraron pods de ArgoCD"
        return 1
    fi
    
    # Verificar servicios
    kubectl get svc -n "$NAMESPACE_ARGOCD"
    
    log_info "Verificación completada exitosamente"
}

# Función para mostrar información post-instalación
show_post_install_info() {
    log_step "Información post-instalación"
    
    echo -e "\n${GREEN}=== ArgoCD Instalación Completada ===${NC}"
    echo -e "${BLUE}Fase 3 CI/CD Implementation - AIOps OS Agent${NC}"
    echo -e "${BLUE}Alberto (BoFeLu) - DevOps Engineer${NC}\n"
    
    echo -e "${YELLOW}Próximos pasos:${NC}"
    echo -e "1. Acceder a ArgoCD UI usando las credenciales guardadas"
    echo -e "2. Configurar repositorio Git en ArgoCD"
    echo -e "3. Crear aplicaciones para staging y production"
    echo -e "4. Configurar GitHub Actions secrets"
    echo -e "5. Realizar primer deploy automático"
    
    echo -e "\n${YELLOW}Comandos útiles:${NC}"
    echo -e "# Port forward ArgoCD:"
    echo -e "kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo -e "\n# Ver aplicaciones ArgoCD:"
    echo -e "kubectl get applications -n argocd"
    echo -e "\n# Ver logs de ArgoCD server:"
    echo -e "kubectl logs -f deployment/argocd-server -n argocd"
    
    echo -e "\n${GREEN}Log completo guardado en: $LOG_FILE${NC}"
}

# Función principal
main() {
    log_info "Iniciando instalación ArgoCD - AIOps OS Agent Fase 3"
    
    check_prerequisites
    create_argocd_namespace
    install_argocd
    configure_argocd_access
    apply_argocd_configurations
    create_argocd_applications
    verify_installation
    show_post_install_info
    
    log_info "Instalación ArgoCD completada exitosamente"
}

# Manejo de errores
trap 'log_error "Error en línea $LINENO. Exit code: $?"' ERR

# Ejecutar función principal
main "$@"
