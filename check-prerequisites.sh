#!/bin/bash
set -uo pipefail

# ============================================================================
# Prerequisites Checker for Docker Compose Setup
# Description: Validates that all requirements are met before running docker compose
# ============================================================================

echo "🔍 Checking prerequisites for Docker Compose setup..."
echo ""

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed: $(docker --version)"
else
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is available
if docker compose version &> /dev/null; then
    echo "✅ Docker Compose is available: $(docker compose version)"
elif command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose is available: $(docker-compose --version)"
else
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Check if model artifacts exist
echo ""
echo "🔍 Checking for required model artifacts..."

MODEL_MISSING=false

if [ -f "models/trained/house_price_model.pkl" ]; then
    echo "✅ Model file found: models/trained/house_price_model.pkl"
else
    echo "❌ Model file not found: models/trained/house_price_model.pkl"
    echo "   Please run './run_pipeline.sh' to generate model artifacts first."
    MODEL_MISSING=true
fi

if [ -f "models/trained/preprocessor.pkl" ]; then
    echo "✅ Preprocessor file found: models/trained/preprocessor.pkl"
else
    echo "❌ Preprocessor file not found: models/trained/preprocessor.pkl"
    echo "   Please run './run_pipeline.sh' to generate model artifacts first."
    MODEL_MISSING=true
fi

# Check if docker-compose.yml exists
echo ""
if [ -f "docker-compose.yml" ]; then
    echo "✅ docker-compose.yml file found"
else
    echo "❌ docker-compose.yml file not found"
    exit 1
fi

echo ""
if [ "$MODEL_MISSING" = true ]; then
    echo "⚠️  Model artifacts are missing. Run the following command first:"
    echo "   ./run_pipeline.sh"
    echo ""
    exit 1
else
    echo "✅ All prerequisites are met!"
    echo ""
    echo "You can now run:"
    echo "   docker compose up --build"
    echo ""
fi
