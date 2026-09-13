# isec6000-app

This repository contains the forked AWS sample Node.js Express application used for the ISEC6000 Secure DevOps assessment.

The application exposes a simple endpoint:

```text
GET /
```

Expected response:

```text
Hello World!
```

## Run locally

```bash
npm ci
npm start
```

Open `http://localhost:8080`.

## Run tests

```bash
npm test
```

## Build and run the Docker image

```bash
docker build -t isec6000-app:local .
docker run --rm -p 8083:8080 isec6000-app:local
```

Open `http://localhost:8083`.

## CI/CD pipeline

The Jenkinsfile automates:

1. Dependency installation
2. Unit testing
3. High/Critical dependency scanning
4. Docker image creation
5. Docker Hub publication

The pipeline uses a Node 16 build agent and tags published images with the Jenkins build number.
