#!/bin/bash

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "🚀 SRP Prototype Setup"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8+"
    exit 1
fi
echo "✅ Python 3 found: $(python3 --version)"

# Check if Neo4j is accessible
echo ""
echo "🔍 Checking Neo4j connection..."
python3 << 'EOF'
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver("neo4j://127.0.0.1:7687", auth=("neo4j", "ETL_fantina_2026"))
    with driver.session() as session:
        session.run("RETURN 1")
    driver.close()
    print("✅ Neo4j is running and accessible on port 7687")
except Exception as e:
    print(f"❌ Cannot connect to Neo4j: {e}")
    print("   Please start Neo4j Desktop with:")
    print("   - URI: neo4j://127.0.0.1:7687")
    print("   - Password: ETL_fantina_2026")
    exit(1)
EOF

if [ $? -ne 0 ]; then
    exit 1
fi

# Install API dependencies
echo ""
echo "📦 Installing API dependencies..."
cd "$(dirname "$0")/api"
if ! pip install -q -r requirements.txt 2>/dev/null; then
    echo "⚠️  Some dependencies may not be installed"
fi
echo "✅ Dependencies ready"

# Create docs directory if needed
echo ""
echo "📁 Checking directory structure..."
if [ ! -d "$(dirname "$0")/docs" ]; then
    mkdir -p "$(dirname "$0")/docs"
    echo "✅ Created docs/ directory"
else
    echo "✅ docs/ directory exists"
fi

if [ ! -d "$(dirname "$0")/csvs" ]; then
    mkdir -p "$(dirname "$0")/csvs"
    echo "✅ Created csvs/ directory"
else
    echo "✅ csvs/ directory exists"
fi

# Create .env if it doesn't exist
if [ ! -f "$(dirname "$0")/.env" ]; then
    cp "$(dirname "$0")/.env.example" "$(dirname "$0")/.env"
    echo "✅ Created .env file"
else
    echo "✅ .env file exists"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "✨ Setup Complete!"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📚 Next Steps:"
echo ""
echo "1. Load data:"
echo "   cd scripts/"
echo "   python3 neo4j_loader.py"
echo ""
echo "2. Start the dashboard:"
echo "   cd api/"
echo "   bash run_dashboard.sh"
echo ""
echo "3. View:"
echo "   📊 Dashboard: http://localhost:8000/"
echo "   🏢 Departments: http://localhost:8000/departments"
echo "   🔍 Neo4j: http://localhost:7474"
echo ""
echo "📖 Documentation:"
echo "   - README.md (overview)"
echo "   - QUICK_START.md (3-step guide)"
echo "   - docs/ARCHITECTURE.md (technical details)"
echo "   - docs/DEPARTMENTS.md (team needs)"
echo ""
