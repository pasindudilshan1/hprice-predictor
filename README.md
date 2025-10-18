## 🧪 Project Spec – Simulate a Production-Grade ML System with Docker Compose

## 🎯 Project Goal

As an MLOps or AI/ML Engineer on the **AI Platform Engineering team**, your mission is to simulate a real-world ML application environment by automating its deployment using **Docker Compose**.

You will create a local dev/test setup that combines:

* ML model training and tracking (with MLflow)

* Model serving (with FastAPI)

* User interaction (with Streamlit)

This kind of environment is used by real teams to **test integration, debug workflows, and enable reproducibility** — before handing it off to production infrastructure like Kubernetes.

---

## ⚙️ What We’re Automating

In a non-Compose setup, you’d be spinning up each component manually using long `docker run` commands. Here's what that looks like:

### 🔹 MLflow Tracking Server

```
docker run -d --name mlflow -p 5555:5000 \
  ghcr.io/mlflow/mlflow:latest \
  mlflow server --host 0.0.0.0 \
```

### 🔹 FastAPI Inference Server

```
docker build -t fastapi-app .
docker run -d --name fastapi -p 8000:8000 
```

### 🔹 Streamlit Frontend

```
docker build -t streamlit-app ./streamlit_app
docker run -d --name streamlit -p 8501:8501 \
  --env API_URL=http://fastapi:8000 \
  --link fastapi streamlit-app
```

Running and linking these services manually is tedious, error-prone, and non-reproducible.

---

## 🐳 What You’ll Do Instead

You’ll use **Docker Compose** to automate all of the above by writing a single `docker-compose.yml` file. This will:

* Build and launch all three services

* Set up internal networking so services can find each other by name (e.g., `http://fastapi:8000`)

* Automatically manage service dependencies

* Enable consistent and reproducible environments across your team

---

## 🧱 Stack Overview

|  Service |  Build Context/Image |  Port |  Depends On |
|---|---|---|---|
|  `mlflow` |  `ghcr.io/mlflow/mlflow:latest` |  5555 |  - |  
|  `fastapi` |  `.` (uses root `Dockerfile`) |  8000 |  mlflow |  
|  `streamlit` |  `./streamlit_app` (Dockerfile) |  8501 |  fastapi |  
---

## 📂 Project Structure

```
house-price-predictor/
├── run_pipeline.sh                # Generates model artifacts
├── Dockerfile                     # FastAPI app
├── streamlit_app/
│   ├── Dockerfile                 # Streamlit app
│   └── app.py
└── docker-compose.yml             # You will create this
```

---

## 🔄 Workflow

### Step 1: Generate Model Artifacts

Run the provided training script:

```
./run_pipeline.sh
```

This will:

* Clean raw data

* Engineer features

* Train a model and preprocessor

* Log the run to MLflow (if it's running)

* Save model files under `models/`

---

### Step 2: Create Docker Compose File

Write a `docker-compose.yml` that:

* Builds the FastAPI and Streamlit images from the existing Dockerfiles

* Uses the public MLflow image

* Maps the appropriate ports

* Connects the services using internal DNS (`fastapi`, `mlflow`)

* Passes `API_URL=http://fastapi:8000` as an environment variable to the Streamlit app

---

### Step 3: Run All Services with Docker Compose

**Important**: Before running docker compose, you must first generate the model artifacts by running the training pipeline:

```bash
./run_pipeline.sh
```

This will create the required model files in `models/trained/` directory.

Once you have the model artifacts, you can start all services with a single command:

```bash
docker compose up --build
```

This will:
* Build the FastAPI and Streamlit images
* Pull the MLflow image
* Start all three services in the correct order (mlflow → fastapi → streamlit)
* Create a shared network for inter-service communication

To run services in detached mode (background):

```bash
docker compose up --build -d
```

To stop all services:

```bash
docker compose down
```

To view logs:

```bash
docker compose logs -f
```

---

### ✅ Validation Checklist

|  Milestone |  Status |
|---|---|
|  `run_pipeline.sh` runs successfully and generates artifacts |  [ ] |  
|  `docker-compose.yml` created with all three services |  [x] |
|  MLflow UI accessible at [http://localhost:5555](http://localhost:5555/) |  [ ] |  
|  FastAPI docs available at [http://localhost:8000/docs](http://localhost:8000/docs) |  [ ] |  
|  Streamlit UI loads at [http://localhost:8501](http://localhost:8501/) |  [ ] |  
|  Streamlit connects to FastAPI and returns predictions |  [ ] |
|  All services run together via `docker compose up` |  [ ] |  
---

## 🚀 Why This Matters

Using Docker Compose this way lets you:

* Create consistent dev/test environments

* Share portable ML apps with teammates

* Validate service integration before scaling to Kubernetes

* Work more like a real AI/ML Platform Engineering team

You’re not just containerizing — you’re simulating production architecture in a controlled, local setup.

