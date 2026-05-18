# ============================================================
# STAGE 1 - BUILD
# Compila la aplicación React con Vite
# ============================================================
FROM node:20-alpine AS builder

# Directorio de trabajo
WORKDIR /app

# Copiamos solo los archivos de dependencias primero (cache de capas)
COPY package*.json ./

# Instalamos dependencias
RUN npm ci

# Copiamos el resto del código fuente
COPY . .

# Construimos la app para producción
RUN npm run build

# ============================================================
# STAGE 2 - PRODUCTION
# Sirve los archivos estáticos con Nginx (imagen mínima)
# ============================================================
FROM nginx:1.25-alpine AS production

# Creamos usuario no root para Nginx
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiamos los archivos compilados desde el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiamos configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ajustamos permisos para usuario no root
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

# Usamos usuario no root
USER appuser

# Puerto de la aplicación
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
