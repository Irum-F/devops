# Flask Docker MySQL with AWS ECR

A production-ready containerized Flask web application with MySQL database, deployed to AWS ECR (Elastic Container Registry) in Mumbai (ap-south-1).

## Project Overview

This project demonstrates:
- Flask web application with MySQL integration
- Docker containerization with custom networking
- Docker Compose orchestration
- AWS ECR image registry in Mumbai region
- Environment-based configuration (no hardcoded secrets)
- IAM user permissions for ECR access

## What Was Built

**Architecture:**
- Flask app (Python 3.8-slim)
- MySQL 5.7 database
- Custom Docker network (`my-app-network`) for inter-container communication
- AWS ECR for image storage

**Key Features:**
- Dockerfile for Flask app
- docker-compose.yml for local orchestration
- Environment variables for configuration
- `.env` and `.env.example` for secrets management
- Comprehensive GitHub-ready setup

## Project Structure

```
├── app.py                # Flask application
├── Dockerfile            # Docker image configuration
├── docker-compose.yml    # Local orchestration
├── .env                  # Secrets (not committed)
├── .env.example          # Template for .env
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## Setup Instructions

### Local Development

1. **Clone and setup:**
```bash
git clone https://github.com/Irum-F/docker.git
cd hello_flask
cp .env.example .env
```

2. **Edit `.env` with your values:**

```
DB_HOST=mysql-container
DB_USER=root
DB_PASSWORD=your-secure-password
DB_NAME=mysql
```

3. **Run with docker-compose:**
```bash
docker-compose up -d
```

4. **Verify:**
```bash
curl http://localhost:5002
```

### AWS ECR Deployment

1. **Configure AWS credentials:**
```bash
aws configure
# Enter Access Key ID, Secret Access Key, region: ap-south-1, format: json
```

2. **Log in to ECR:**
```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 048568674137.dkr.ecr.ap-south-1.amazonaws.com
```

3. **Push to ECR:**
```bash
docker build -t hello-flask .
docker tag hello-flask:latest 048568674137.dkr.ecr.ap-south-1.amazonaws.com/flask-mysql:latest
docker push 048568674137.dkr.ecr.ap-south-1.amazonaws.com/flask-mysql:latest
```

4. **Run from ECR:**
```bash
docker network create my-app-network
docker run -d --network my-app-network --name mysql-container -e MYSQL_ROOT_PASSWORD=your-password mysql:5.7
docker run -d -p 5002:5002 -e DB_HOST=mysql-container -e DB_USER=root -e DB_PASSWORD=your-password -e DB_NAME=mysql --network my-app-network 048568674137.dkr.ecr.ap-south-1.amazonaws.com/flask-mysql:latest
```

## Errors Faced & Solutions

### 1. Venv Installation Error (PEP 668)
**Solution:** Used `python3 -m venv` to create isolated virtual environment

### 2. Zsh vs Bash Compatibility
**Solution:** Installed AWS CLI via pipx: `pipx install awscli`

### 3. .env File Committed to Git
**Solution:** `git rm --cached .env` to untrack, changed MySQL password

### 4. Docker Permission Denied
**Solution:** `sudo usermod -aG docker $USER` then logged out/back in

### 5. Dockerfile Not Found
**Solution:** Verified working directory, navigated to project root

### 6. Flask App Crashing (MySQL Connection Failed)
**Solution:** Updated `app.py` to use `os.getenv()` for DB config, passed `-e DB_HOST=mysql-container` at runtime

### 7. AWS Credentials Not Configured
**Solution:** Created IAM user with ECR policy, ran `aws configure`


## Security Considerations

✅ **Secure:**
- Passwords never hardcoded in code
- Secrets passed via environment variables at runtime
- `.env` excluded from Git via `.gitignore`
- IAM user with minimal ECR permissions only

⚠️ **Production Improvements:**
- Use AWS Secrets Manager instead of environment variables
- Implement TLS/SSL for database connections
- Set up proper database user permissions (not root)
- Add health checks to containers
- Implement logging and monitoring
- Use container orchestration (ECS, EKS) instead of manual Docker
- Set resource limits on containers

## What I Learned

- Docker containerization and networking
- Docker Compose for multi-container applications
- AWS ECR for container image storage
- AWS IAM for access control
- Environment variable management for secrets
- Git workflow (untracking committed files)
- Debugging Docker and network connectivity issues
- AWS CLI authentication and image pushes

## Next Steps

1. Implement docker-compose support for AWS Fargate
2. Add CI/CD pipeline (GitHub Actions)
3. Set up RDS for managed MySQL
4. Implement container health checks
5. Add application logging and monitoring
6. Deploy to AWS ECS or EKS


## Troubleshooting

**Container won't start?**
```bash
docker logs <container-id>
```

**Can't connect to MySQL?**
- Verify both containers on same network: `docker network inspect my-app-network`
- Check MySQL is fully initialized: `docker logs mysql-container`

**ECR push failed?**
- Verify credentials: `aws sts get-caller-identity`
- Check region: `aws configure get region`

## Happy deployment!