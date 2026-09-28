#!/bin/bash

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "🚀 SRP ETL Dashboard - Startup"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python 3.8+"
    exit 1
fi

# Check if Neo4j is running
echo "🔍 Checking Neo4j connection..."
python3 << 'EOF'
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver("neo4j://127.0.0.1:7687", auth=("neo4j", "ETL_fantina_2026"))
    with driver.session() as session:
        session.run("RETURN 1")
    driver.close()
    print("✅ Neo4j is running and accessible")
except Exception as e:
    print(f"❌ Cannot connect to Neo4j: {e}")
    print("   Make sure Neo4j Desktop is running on port 7687")
    exit(1)
EOF

if [ $? -ne 0 ]; then
    exit 1
fi

# Install dependencies if needed
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo ""
    echo "📦 Installing dependencies..."
    pip3 install -r requirements.txt
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "✨ Starting Dashboard API..."
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Dashboard will be available at: http://localhost:8000"
echo ""
echo "📡 API Endpoints:"
echo "   GET /api/metrics                    → Overall metrics"
echo "   GET /api/movement-intelligence      → Movement flags"
echo "   GET /api/relationship-discovery     → Peer networks"
echo "   GET /api/vertical-intelligence      → Cross-vertical experts"
echo "   GET /api/review-sentiment           → High-rated agents"
echo "   GET /api/location-concentration     → City analysis"
echo "   GET /api/tier-hierarchy             → Tier structure"
echo "   GET /api/credibility-leaders        → Trust leaders"
echo "   GET /api/rising-stars               → Trending agents"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

python3 main.py
