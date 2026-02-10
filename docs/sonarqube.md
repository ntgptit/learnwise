# SonarQube Setup (BE + FE)

## 1. Run SonarQube locally

```bash
docker compose -f infra/sonarqube/docker-compose.yml up -d
```

Install Flutter plugin for SonarQube server (one-time per Sonar instance):

```powershell
powershell -ExecutionPolicy Bypass -File infra/sonarqube/install_flutter_plugin.ps1
```

Open `http://localhost:9000` and create a user token.

## 2. Backend scan (Spring Boot)

From `learn-wire-api-service`:

```bash
./mvnw verify sonar:sonar \
  -Dsonar.projectKey=learnwise-be \
  -Dsonar.projectName=learnwise-backend \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=<YOUR_TOKEN>
```

## 3. Frontend scan (Flutter)

From repository root:

```bash
flutter test --machine --coverage > tests.output
mkdir -p build/reports
flutter analyze --no-fatal-warnings --no-fatal-infos --machine > build/reports/analysis-results.txt
sonar-scanner \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=<YOUR_TOKEN>
```

## 4. GitHub CI integration

Workflow file: `.github/workflows/sonarqube.yml`

Required GitHub repository secrets:
- `SONAR_HOST_URL` (example: `https://sonarqube.your-domain.com`)
- `SONAR_TOKEN`

When both secrets are present, CI runs two independent scans:
- `learnwise-be` from Maven project `learn-wire-api-service`
- `learnwise-fe` from Flutter root using `sonar-project.properties` + generated `tests.output` and `build/reports/analysis-results.txt`
