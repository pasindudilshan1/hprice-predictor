# Solution: Docker Networking Issue Fix

## Problem Statement

The application was experiencing the following error:

```
Error connecting to API: HTTPConnectionPool(host='fastapi', port=8000): 
Max retries exceeded with url: /predict 
(Caused by NameResolutionError("<urllib3.connection.HTTPConnection object at 0x7ae998c39430>: 
Failed to resolve 'fastapi' ([Errno -5] No address associated with hostname)"))
```

## Root Cause Analysis

The error occurred because:

1. **Missing Docker Network Configuration**: The Streamlit application was configured to connect to `http://fastapi:8000` via the `API_URL` environment variable
2. **No Service Orchestration**: Without a docker-compose.yml file, containers were not on the same Docker network
3. **DNS Resolution Failure**: Docker's internal DNS requires containers to be on the same network to resolve each other by service name

When running containers individually with `docker run`, they are isolated unless explicitly connected via a shared network. The hostname `fastapi` couldn't be resolved because there was no network where this DNS entry existed.

## Solution

Created a comprehensive Docker Compose configuration that orchestrates all three services (MLflow, FastAPI, Streamlit) with proper networking.

### Files Created/Modified

1. **docker-compose.yml** - Main orchestration file
2. **check-prerequisites.sh** - Helper script to validate prerequisites
3. **README.md** - Updated with usage instructions

### Key Features of the Solution

#### 1. Docker Compose Configuration (docker-compose.yml)

```yaml
services:
  mlflow:
    - Uses official MLflow image
    - Exposes port 5555 (maps internal 5000)
    - Has health check for readiness
    
  fastapi:
    - Builds from root Dockerfile
    - Exposes port 8000
    - Depends on mlflow service health
    - Has health check endpoint
    
  streamlit:
    - Builds from streamlit_app directory
    - Exposes port 8501
    - Sets API_URL=http://fastapi:8000
    - Depends on fastapi service health

networks:
  ml-network:
    - Bridge network for all services
    - Enables Docker's internal DNS
```

#### 2. Service Dependencies

The services are configured with health-check-based dependencies:
- Streamlit waits for FastAPI to be healthy
- FastAPI waits for MLflow to be healthy
- This ensures proper startup order

#### 3. Network Configuration

All services are connected to the `ml-network` bridge network, which:
- Provides automatic DNS resolution between containers
- Allows services to communicate using container names as hostnames
- Isolates the services from other Docker networks

## How This Fixes the Issue

1. **Shared Network**: All containers are placed on the `ml-network` bridge network
2. **DNS Resolution**: Docker's internal DNS automatically creates entries for each service name (`mlflow`, `fastapi`, `streamlit`)
3. **Service Discovery**: When Streamlit tries to connect to `http://fastapi:8000`, Docker's DNS resolves `fastapi` to the FastAPI container's IP address
4. **Proper Startup**: Health checks ensure services start in the correct order and only when dependencies are ready

## Usage

### Prerequisites

1. Generate model artifacts first:
```bash
./run_pipeline.sh
```

2. Verify prerequisites:
```bash
./check-prerequisites.sh
```

### Running the Application

Start all services:
```bash
docker compose up --build
```

Or run in detached mode:
```bash
docker compose up --build -d
```

### Accessing Services

- **Streamlit UI**: http://localhost:8501
- **FastAPI Docs**: http://localhost:8000/docs
- **MLflow UI**: http://localhost:5555

### Stopping Services

```bash
docker compose down
```

## Validation

The solution has been validated to:
- ✅ Create a valid docker-compose.yml configuration
- ✅ Set up proper networking between services
- ✅ Configure correct environment variables
- ✅ Implement health checks and dependencies
- ✅ Provide helpful error messages and documentation
- ✅ Pass code review
- ✅ Pass security scan (CodeQL)

## Benefits

1. **One-Command Setup**: `docker compose up` starts all services
2. **Automatic Networking**: No manual network configuration needed
3. **Service Discovery**: Services can find each other by name
4. **Reproducible**: Same setup works across different environments
5. **Production-like**: Simulates real-world microservices architecture
6. **Easy Debugging**: Built-in logging and health checks

## Technical Details

### Environment Variables
- `API_URL=http://fastapi:8000`: Configured in streamlit service to point to FastAPI

### Port Mappings
- MLflow: `5555:5000` (host:container)
- FastAPI: `8000:8000`
- Streamlit: `8501:8501`

### Health Checks
- MLflow: `curl -f http://localhost:5000/health`
- FastAPI: `curl -f http://localhost:8000/health`
- Both run every 30s with 10s timeout, 3 retries, and 10s start period

## Future Improvements (Optional)

1. Add volume mounts for MLflow tracking data persistence
2. Add environment-specific configurations (dev, staging, prod)
3. Implement container resource limits
4. Add logging configuration
5. Integrate with CI/CD pipelines
