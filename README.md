# Frontend - Despacho | ISY1101 EP2

Aplicación frontend desarrollada con **React + Vite + Tailwind CSS**, dockerizada con Nginx y desplegada en AWS EC2 mediante un pipeline CI/CD con GitHub Actions.

---

## Tecnologías

- React 18 + Vite
- Tailwind CSS
- Nginx 1.25 (servidor de producción)
- Docker (multi-stage build)
- GitHub Actions (CI/CD)
- AWS ECR + EC2

---

## Estructura del repositorio

```
frontend/
├── src/                        # Código fuente React
│   ├── componentes/            # Componentes reutilizables
│   ├── Routes/                 # Configuración de rutas
│   └── assets/                 # Imágenes y recursos estáticos
├── public/                     # Archivos públicos
├── Dockerfile                  # Multi-stage build (Node → Nginx)
├── nginx.conf                  # Configuración del servidor Nginx
├── docker-compose.yml          # Stack del servicio frontend
├── .env.example                # Variables de entorno de ejemplo
└── .github/
    └── workflows/
        └── cicd-frontend.yml   # Pipeline CI/CD
```

---

## Ejecución local con Docker

### 1. Clonar el repositorio
```bash
git clone <URL_REPO>
cd frontend
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con las IPs del backend
```

### 3. Levantar con Docker Compose
```bash
docker-compose up -d --build
```

### 4. Acceder
```
http://localhost:80
```

---

## Pipeline CI/CD

El pipeline se activa automáticamente al hacer **push en la rama `deploy`**.

**Pasos:**
1. `Checkout` del código
2. Configuración de credenciales AWS (via GitHub Secrets)
3. Login en Amazon ECR
4. `docker build` y `docker push` de la imagen a ECR con tag `:latest` y `:<sha>`
5. Deploy automático en la instancia EC2 frontend via AWS SSM

---

## GitHub Secrets requeridos

| Secret | Descripción |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sesión AWS Academy |
| `AWS_REGION` | Región AWS (ej: `us-east-1`) |
| `ECR_REGISTRY` | URL del registro ECR |
| `ECR_REPO_FRONTEND` | Nombre del repositorio ECR del frontend |
| `EC2_FRONTEND_INSTANCE_ID` | ID de la instancia EC2 pública |
| `VITE_API_DESPACHOS` | URL del backend despachos |
| `VITE_API_VENTAS` | URL del backend ventas |

---

## Decisiones técnicas

### Dockerfile multi-stage
Se usa **multi-stage build** para separar la fase de compilación (Node.js) de la fase de producción (Nginx). Esto reduce el tamaño final de la imagen eliminando herramientas de desarrollo.

### Usuario no root
El contenedor Nginx se ejecuta con un usuario sin privilegios (`appuser`) para reducir la superficie de ataque.

### Nginx como servidor de producción
Nginx sirve los archivos estáticos compilados por Vite, maneja correctamente las rutas SPA (`try_files`) y agrega cabeceras de seguridad.

---

## Commits explicativos

Los commits del repositorio siguen el formato:
- `feat:` para nuevas funcionalidades
- `fix:` para correcciones
- `docker:` para cambios en la configuración Docker
- `ci:` para cambios en el pipeline
