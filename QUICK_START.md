# Quick Start Guide - SRP Prototype

Get the Neo4j graph running in **3 steps** (10 minutes)

---

## Step 1: Start Neo4j

### Option A: Neo4j Desktop (Recommended)
```bash
# 1. Open Neo4j Desktop
# 2. Create a new project called "SRP"
# 3. Create a database:
#    - Edition: Community
#    - Version: 5.x or latest
#    - Port: 7687
# 4. Set password: ETL_fantina_2026
# 5. Click "Start"
```

Wait for status to show "Running" ✅

### Option B: Neo4j Docker
```bash
docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/ETL_fantina_2026 \
  neo4j:5-enterprise
```

---

## Step 2: Load Data

```bash
cd /Users/fantina/Desktop/srp_prototype/scripts
python3 neo4j_loader.py
```

**Expected Output:**
```
✓ Connected to Neo4j: neo4j://127.0.0.1:7687
📦 Loading 100 Agent nodes...
✓ Loaded 100 Agent nodes
📦 Loading 51 Tier_Hier nodes...
✓ Loaded Tier Hierarchy
...
[more loading messages]
...
🎯 Enhancement 8: Computing temporal properties...
✓ Added temporal properties

Loading complete! ✅
```

Check Neo4j Browser: http://localhost:7474
- Query: `MATCH (n) RETURN COUNT(n)` 
- Should return: **408** (nodes)

---

## Step 3: Run Dashboard

```bash
cd /Users/fantina/Desktop/srp_prototype/api
bash run_dashboard.sh
```

**Expected Output:**
```
✅ Neo4j is running and accessible
📦 Installing dependencies...
===================================================
✨ Starting Dashboard API...
===================================================

📊 Dashboard will be available at: http://localhost:8000

📡 API Endpoints:
   GET /api/metrics                    → Overall metrics
   GET /api/movement-intelligence      → Movement flags
   ...
```

---

## View the Results

### 📊 Main Dashboard
```
http://localhost:8000/
```
Shows:
- 10 key metrics
- 8 core intelligence queries
- 4 WOW queries
- Real-time Neo4j data

### 🏢 Department Views
```
http://localhost:8000/departments
```
Shows:
- Sales Engine - CPQ & contracting
- Search Engine - ranking & explainability
- Marketing Engine - targeting & attribution
- Operations - monitoring & release

### 🔍 Neo4j Browser
```
http://localhost:7474
```
View the graph directly:
```cypher
# See the graph structure
MATCH (a:Agent)-[r:REVIEWED_BY]->(rev:Review)
WHERE a.name = 'Anthony Grech'
RETURN a.name, rev.reviewer_name, r.stars LIMIT 10

# See movement signals
MATCH (a:Agent)
WHERE a.pp_movement_flag = true
RETURN a.name, a.vertical, a.movement_status

# See market concentration
MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical),
      (a)-[:OPERATES_FROM]->(l:Tier_Location)
RETURN v.vertical, l.city, COUNT(a) as count
ORDER BY count DESC
LIMIT 20
```

---

## Verify Everything Works

### API Health Check
```bash
curl http://localhost:8000/api/health
```

Response:
```json
{
  "status": "healthy",
  "database": "neo4j",
  "uri": "neo4j://127.0.0.1:7687"
}
```

### Get Metrics
```bash
curl http://localhost:8000/api/metrics
```

Response shows:
- total_agents: 100
- high_confidence: 32
- rising_stars: 15
- avg_rating: ~4.0

---

## Troubleshooting

### "Address already in use"
```bash
# Kill the process on port 8000
lsof -i :8000
kill -9 <PID>

# Then restart
bash run_dashboard.sh
```

### "Cannot connect to Neo4j"
```bash
# Check Neo4j is running
# Check port 7687 is correct (not 7474)
# Check password is: ETL_fantina_2026

# Test connection
python3 << 'EOF'
from neo4j import GraphDatabase
driver = GraphDatabase.driver("neo4j://127.0.0.1:7687", auth=("neo4j", "ETL_fantina_2026"))
session = driver.session()
result = session.run("RETURN 1")
print("✅ Connection successful")
EOF
```

### "Dashboard not loading"
```bash
# Check API is running on port 8000
curl http://localhost:8000/api/health

# Check dashboard files exist
ls -la /Users/fantina/Desktop/srp_prototype/api/*.html
```

---

## Next Steps

1. ✅ Explore the dashboard
2. ✅ Try the 12 API endpoints
3. ✅ View the graph in Neo4j Browser
4. ✅ Read [ARCHITECTURE.md](docs/ARCHITECTURE.md) for technical details
5. ✅ Check [QUERY_CATALOG.md](QUERY_CATALOG.md) for all queries

---

## Key URLs

| Purpose | URL |
|---------|-----|
| Main Dashboard | http://localhost:8000/ |
| Department Views | http://localhost:8000/departments |
| Neo4j Browser | http://localhost:7474 |
| API Health | http://localhost:8000/api/health |
| Metrics | http://localhost:8000/api/metrics |

---

**Done! 🎉 You now have a fully functional SRP prototype with:**
- ✅ 408-node knowledge graph
- ✅ 12 intelligence queries
- ✅ Beautiful real-time dashboard
- ✅ 4 department-specific views
- ✅ Production-ready ETL pipeline

**Ready for presentation!** 🚀
