Context Directive-Directivas de Arquitectura (AIOps OS Agent)
Contexto del Proyecto: Estamos operando un ecosistema de AIOps sobre Minikube v1.32.0 en Windows 11 + WSL2. El proyecto ha pasado por una auditoría técnica profunda que ha detectado desviaciones críticas que debemos corregir de inmediato.

Objetivos de Excelencia (Súmmum):

Seguridad Estricta (PodSecurity Standards): * No aceptes ningún manifiesto de Kubernetes que no incluya un securityContext de nivel Restricted.

Todos los despliegues (incluyendo el Agente, Prometheus y Grafana) deben incluir obligatoriamente: allowPrivilegeEscalation: false, capabilities: { drop: [ALL] } y seccompProfile: { type: 'RuntimeDefault' }.

Persistencia de Datos (Zero-Loss):

Queda terminantemente prohibido el uso de emptyDir para el almacenamiento de métricas o configuraciones.

Cualquier sugerencia de despliegue para el stack de monitorización debe implementar PersistentVolumeClaims (PVC) para garantizar que los datos sobrevivan a los reinicios de los Pods en el entorno WSL2.

Gestión de Ramas y GitOps:

La rama main es ahora la única "Fuente de Verdad" (Source of Truth).

Todas las automatizaciones de ArgoCD deben apuntar a la ruta canónica ./k8s/applications/ que hemos unificado tras la deriva detectada entre master y main.

Entorno de Ejecución:

El usuario de ejecución es exclusivamente aiops_user (no-root).

El API Server opera en el puerto 8443 con Kubernetes v1.32.0 para evitar los errores de connection reset identificados en versiones superiores.

Instrucción para Copilot: En adelante, cualquier refactorización, script de bash o manifiesto YAML que generes debe ser auditado contra estas directivas. Si una sugerencia no cumple con el endurecimiento (hardening) de seguridad o la persistencia requerida, descártala y propón una alternativa de grado Enterprise.