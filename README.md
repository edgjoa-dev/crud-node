<p align="center">
    <img src="https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExdTRha3Y3cTlnZnR2NTJ2OThvbms3YW1lZjN1OWw3c3RjcmR5OTlpMyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/bJ4TVNYNUympPgcpem/giphy.gif" alt="Node.js GIF" width="400">
</p>

# Proyecto CRUD con Node.js, Docker Compose, Prisma ORM, PostgreSQL y CI/CD

<p align="center">
    <a href="https://www.docker.com/">
        <img src="https://img.shields.io/badge/Docker-2496ED.svg?&style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
    </a>
    <a href="https://nodejs.org/">
        <img src="https://img.shields.io/badge/Node.js-339933.svg?&style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js">
    </a>
    <a href="https://expressjs.com/">
        <img src="https://img.shields.io/badge/Express-000000.svg?&style=for-the-badge&logo=express&logoColor=white" alt="Express">
    </a>
    <a href="https://www.postgresql.org/">
        <img src="https://img.shields.io/badge/PostgreSQL-336791.svg?&style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
    </a>
    <a href="https://www.prisma.io/">
        <img src="https://img.shields.io/badge/Prisma-2D3748.svg?&style=for-the-badge&logo=prisma&logoColor=white" alt="Prisma">
    </a>
    <a href="https://jestjs.io/">
        <img src="https://img.shields.io/badge/Jest-C21325.svg?&style=for-the-badge&logo=jest&logoColor=white" alt="Jest">
    </a>
    <a href="https://docs.docker.com/compose/">
        <img src="https://img.shields.io/badge/Docker_Compose-2496ED.svg?&style=for-the-badge&logo=docker&logoColor=white" alt="Docker Compose">
    </a>
</p>


Este proyecto muestra cómo crear una aplicación CRUD utilizando Node.js, Docker, Prisma ORM, PostgreSQL, y CI/CD. Se configura para diferentes entornos de desarrollo y permite gestionar una base de datos usando TablePlus.

## Índice
1. [Requisitos previos](#requisitos-previos)
2. [Paso 1: Configuración inicial del proyecto](#paso-1-configuración-inicial-del-proyecto)
3. [Paso 2: Configuración de Docker Compose](#paso-2-configuración-de-docker-compose)
4. [Paso 3: Configuración de Prisma ORM](#paso-3-configuración-de-prisma-orm)
5. [Paso 4: Creación del CRUD en Node.js](#paso-4-creación-del-crud-en-nodejs)
6. [Paso 5: Configuración de Dockerfile para diferentes stages](#paso-5-configuración-de-dockerfile-para-diferentes-stages)
7. [Paso 6: Configuración de CI/CD](#paso-6-configuración-de-cicd)
8. [Paso 7: Verificación de la base de datos en TablePlus](#paso-7-verificación-de-la-base-de-datos-en-tableplus)
9.[Paso 8: testing con Jest](#paso-8-testing-con-jest)
10. [Información adicional:](#información-adicional)

---

## Requisitos previos
- **Node.js** (>= v18)
- **Docker** y **Docker Compose**
- **Prisma CLI** (instalado como dependencia en el proyecto)
- **TablePlus** (para visualizar la base de datos)
- **GitHub** (u otra plataforma para CI/CD)
- **Postman** (para realizar peticiones al backend)
---
## Paso 1: Configuración inicial del proyecto

1. Crea una carpeta para tu proyecto y navega dentro:
    ```bash
    mkdir nodejs-docker-prisma-crud
    cd nodejs-docker-prisma-crud
    ```

2. Inicializa un proyecto de Node.js:
    ```
    npm init
    ```

3. Instala las dependencias:
    ```
    npm install express prisma @prisma/client body-parser
    npm install --save-dev nodemon jest
    ```

  > **Dependencias:**
   - `express`: Framework para crear APIs.
   - `prisma` y `@prisma/client`: ORM y cliente para manejar la base de datos.
   - `body-parser`: Middleware para parsear JSON.
   - `nodemon`: Herramienta para reiniciar el servidor automáticamente.
   - `jest`: Librería para realizar testing de nuestra aplicación.

---
## Paso 2: Configuración de Docker Compose

Crea un archivo `docker-compose.yml` en la raíz del proyecto:

- NOTA: Si tienes algún error en consola intenta primero construir la imagen de la aplicación. ir a [Paso 5: Configuración de Dockerfile para diferentes stages](#paso-5-configuración-de-dockerfile-para-diferentes-stages).

```yaml
version: '3.8'

services:
  database:
    image: postgres:13
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: "postgresql://postgres:postgres@database:5432/mydb"
    ports:
      - "3000:3000"
    depends_on:
      - database
    volumes:
      - .:/app
      - /app/node_modules

volumes:
  postgres_data:
```

---
# Paso 3: Configuración de Prisma ORM

Instala Prisma CLI:

```
npx prisma init
```
Esto creará una carpeta prisma con un archivo schema.prisma.

>  Configura schema.prisma para conectar Prisma a PostgreSQL:

```
prisma
Copiar código
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id    Int     @id @default(autoincrement())
  name  String
  email String  @unique
}
```

## Crea la base de datos y genera el cliente de Prisma:
 > Para crear la base de datos y generar el cliente de Prisma, ejecuta los comandos en la terminal.

```
docker-compose up -d
```
```
npx prisma migrate dev --name init
```
```
npx prisma generate
```

---
# Paso 4: Creación del CRUD en Node.js
> Crea un archivo index.js con los endpoints para las operaciones CRUD:
 ```
const express = require('express');
const { PrismaClient } = require('@prisma/client');
const bodyParser = require('body-parser');

const app = express();
const prisma = new PrismaClient();

app.use(bodyParser.json());

// Endpoints CRUD
app.post('/users', async (req, res) => {
  const { name, email } = req.body;
  const user = await prisma.user.create({ data: { name, email } });
  res.json(user);
});

app.get('/users', async (req, res) => {
  const users = await prisma.user.findMany();
  res.json(users);
});

app.put('/users/:id', async (req, res) => {
  const { id } = req.params;
  const { name, email } = req.body;
  const user = await prisma.user.update({
    where: { id: parseInt(id) },
    data: { name, email },
  });
  res.json(user);
});

app.delete('/users/:id', async (req, res) => {
  const { id } = req.params;
  await prisma.user.delete({ where: { id: parseInt(id) } });
  res.json({ message: 'User deleted' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```
---
# Modifica package.json para usar nodemon:
```
"scripts": {
    "test": "jest",
    "start": "node index.js",
    "dev": "nodemon index.js"
}
```
---
# Paso 5: Configuración de Dockerfile para diferentes stages

> Crea un archivo Dockerfile en la raíz del proyecto:

```
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

```
---
# Paso 6: Configuración de CI/CD
> Para configurar un pipeline de CI/CD en GitHub Actions:

1. Crea un repositorio en GitHub con el nombre "nodejs-docker-prisma-crud".

2. Abre el repositorio en GitHub y selecciona la opción "Actions" en la parte superior derecha.

3. Crea un archivo `.github/workflows/ci.yml` en la raíz del repositorio con el siguiente contenido:

- Crea .github/workflows/ci.yml:

```
name: CI/CD Pipeline

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '20'
      - run: npm install
      - run: npm run build

  test:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - uses: actions/checkout@v2
      - run: npm install
      - run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: test

    steps:
      - name: Deploy to production
        run: echo "Deployment step"
```

Esto crea tres jobs:
- `build`: Compila el proyecto y instala las dependencias.
- `test`: Ejecuta los tests del proyecto.
- `deploy`: Ejecuta un paso de despliegue en tu ambiente de producción.

Para habilitar la ejecución de CI/CD, selecciona la opción "Enable GitHub Actions" en la parte superior derecha del repositorio.


---
# Paso 7: Verificación de la base de datos en TablePlus
> Conecta a PostgreSQL en TablePlus con la siguiente configuración:
```
Host: localhost
User: postgres
Password: postgres
Database: mydb
```
# Paso 8: testing con Jest

Crea un archivo `jest.config.js` en la raíz del proyecto con el siguiente contenido:

 ```javascript
// jest.config.js
module.exports = {
  // Especifica el entorno de prueba
  testEnvironment: "node",

  // Carpeta donde Jest buscará archivos de prueba
  roots: ["<rootDir>/src"],

  // Patrón para identificar archivos de prueba (puedes ajustarlo según prefieras)
  testMatch: ["**/?(*.)+(spec|test).js"],

  // Limpia automáticamente los mocks entre pruebas
  clearMocks: true,

  // Define el directorio donde Jest guardará los resultados de cobertura
  coverageDirectory: "coverage",

  // Especifica qué archivos incluir en la cobertura (opcional)
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/**/*.test.js" // Excluye archivos de prueba del reporte de cobertura
  ],

  // Opcional: Configura transformadores, si usas Babel o alguna otra herramienta
  transform: {},
};

```

---
# Información adicional:

- NOTA: Asegúrate de que tu PostgreSQL está corriendo en el container de Docker y que esté en ejecución. Además de que el usuario y contraseña coincidan con las configuraciones de la base de datos en `schema.prisma` y la cadena de conexión:
DATABASE_URL=postgresql://USER:PASSWORD@localhost:5432/nombre_base_de_datos
---

Notas:
- Utiliza Docker Compose para gestionar y ejecutar las contenedores de Docker.
Variables de Entorno
Crea un archivo .env en la raíz del proyecto:

 ```
 DATABASE_URL=postgresql://postgres:postgres@localhost:5432/mydb
 ```

- Los comandos de ejcución de Docker son:
  ```
  docker build -t nombre_deseado_iamgen:latest .
  ```
  ```
  docker-compose up -d
  ```
  ```
  npx prisma migrate dev --name init
  ```
  ```
  npx prisma generate
  ```

- Asegúrate de correr el comando de node para levantar la aplicación
  ```
  npm run dev
  ```
- Comando de ejecución de test
  ```
  npm test
  ```
