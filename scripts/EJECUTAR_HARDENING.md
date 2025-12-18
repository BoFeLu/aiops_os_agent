# Cómo Ejecutar el Script de Hardening en Windows

## Opción 1: WSL (Windows Subsystem for Linux) - RECOMENDADO

1. **Abrir WSL:**
   ```bash
   wsl
   ```

2. **Navegar al proyecto:**
   ```bash
   cd /mnt/c/Users/Alber2Pruebas/aiops_os_agent
   ```

3. **Dar permisos de ejecución al script:**
   ```bash
   chmod +x scripts/harden_aiops_k8s.sh
   ```

4. **Verificar que Minikube esté corriendo:**
   ```bash
   minikube status
   ```
   Si no está corriendo:
   ```bash
   minikube start
   ```

5. **Ejecutar el script:**
   ```bash
   ./scripts/harden_aiops_k8s.sh
   ```

---

## Opción 2: Git Bash

1. **Abrir Git Bash** (desde el menú Inicio o clic derecho en la carpeta → "Git Bash Here")

2. **Navegar al proyecto:**
   ```bash
   cd /c/Users/Alber2Pruebas/aiops_os_agent
   ```

3. **Dar permisos de ejecución:**
   ```bash
   chmod +x scripts/harden_aiops_k8s.sh
   ```

4. **Ejecutar el script:**
   ```bash
   ./scripts/harden_aiops_k8s.sh
   ```

---

## Opción 3: PowerShell (con bash)

Si tienes bash disponible en PowerShell (por ejemplo, a través de Git for Windows):

```powershell
bash scripts/harden_aiops_k8s.sh
```

---

## Prerequisitos Antes de Ejecutar

El script verificará automáticamente que:

- ✅ Minikube esté corriendo (`minikube status`)
- ✅ El contexto de kubectl esté configurado en `minikube`
- ✅ Los manifestos de seguridad existan en `manifests/aiops-security-manifests.yaml`

### Si Minikube no está corriendo:

```bash
minikube start
```

### Si el contexto no está configurado:

```bash
kubectl config use-context minikube
```

---

## Qué Hace el Script

El script de hardening ejecuta las siguientes tareas:

1. ✅ Verifica prerequisitos (Minikube, kubectl, contexto)
2. ✅ Configura persistencia de Minikube
3. ✅ Habilita metrics-server para observabilidad
4. ✅ Aplica manifiestos de seguridad (RBAC, NetworkPolicies, PVCs)
5. ✅ Verifica configuración RBAC
6. ✅ Verifica NetworkPolicies
7. ✅ Prueba almacenamiento persistente
8. ✅ Ejecuta tests de rendimiento
9. ✅ Genera reporte de verificación (guardado como `aiops-hardening-report-YYYYMMDD-HHMMSS.txt`)
10. ✅ Limpia recursos de prueba

---

## Resultado

Al finalizar, el script generará:

- ✅ Un reporte de verificación en el directorio actual: `aiops-hardening-report-*.txt`
- ✅ Namespace `aiops` configurado con seguridad
- ✅ ServiceAccount, Role y RoleBinding creados
- ✅ NetworkPolicies aplicadas (default-deny-all, allow-dns, allow-aiops-internal)
- ✅ PVC `aiops-data` para almacenamiento persistente

---

## Solución de Problemas

### Error: "Permission denied"
```bash
chmod +x scripts/harden_aiops_k8s.sh
```

### Error: "Minikube is not running"
```bash
minikube start
```

### Error: "kubectl context is not set to minikube"
```bash
kubectl config use-context minikube
```

### Error: "Security manifest file not found"
Verifica que existe el archivo:
```bash
ls manifests/aiops-security-manifests.yaml
```

---

## Nota

El script está diseñado para ejecutarse en entornos Linux/WSL. Si prefieres usar PowerShell nativo, sería necesario convertir el script a PowerShell (.ps1) o usar bash a través de Git Bash/WSL.



