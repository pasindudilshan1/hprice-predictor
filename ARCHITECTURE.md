# Network Architecture

## Before (Problem)

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Streamlit  │      │   FastAPI   │      │   MLflow    │
│  Container  │      │  Container  │      │  Container  │
│  Port 8501  │      │  Port 8000  │      │  Port 5555  │
└──────┬──────┘      └─────────────┘      └─────────────┘
       │
       │ API_URL=http://fastapi:8000
       │
       └──────► ❌ DNS Error: Cannot resolve 'fastapi'
                  (No shared network)
```

## After (Solution)

```
┌─────────────────────────────────────────────────────────┐
│              Docker Bridge Network                       │
│                  (ml-network)                            │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  MLflow     │  │  FastAPI    │  │  Streamlit  │    │
│  │             │  │             │  │             │    │
│  │ Port 5000   │  │ Port 8000   │  │ Port 8501   │    │
│  │ (mlflow)    │  │ (fastapi)   │  │ (streamlit) │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │            │
│         └────────────────┴────────────────┘            │
│              DNS Resolution Enabled                     │
└─────────────────────────────────────────────────────────┘
         │                │                │
         ▼                ▼                ▼
    Port 5555        Port 8000        Port 8501
    (Host)           (Host)           (Host)
```

## Communication Flow

1. **User** → Streamlit (localhost:8501)
2. **Streamlit** → FastAPI (fastapi:8000 via internal DNS)
3. **FastAPI** → MLflow (mlflow:5000 via internal DNS)

## Key Features

- ✅ All services on same network
- ✅ Docker DNS resolves container names
- ✅ Health checks ensure proper startup order
- ✅ Dependencies: Streamlit → FastAPI → MLflow
- ✅ Environment variable: API_URL=http://fastapi:8000
