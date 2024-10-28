# Stage 1: Base - Instalación de dependencias
FROM node:20 AS base
WORKDIR /app
COPY package*.json ./
RUN npm install

# Stage 2: Development
FROM base AS development
WORKDIR /app
COPY . .
CMD ["npm", "run", "dev"]

# Stage 3: Testing
FROM base AS testing
WORKDIR /app
COPY . .
CMD ["npm", "test"]

# Stage 4: Production Optimizado
FROM node:20-alpine AS production
WORKDIR /app

# Copiar y solo instalar dependencias de producción
COPY package*.json ./
RUN npm install --production

# Copiar el resto del código desde el stage base
COPY --from=base /app .

# Comando de inicio para producción
CMD ["npm", "start"]
