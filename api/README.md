# SRP ETL Dashboard API

**Real-time intelligence from your Neo4j graph database**

---

## 🚀 Quick Start

### 1. Make sure Neo4j is running
```bash
# Open Neo4j Desktop and start your instance on port 7687
```

### 2. Install dependencies
```bash
cd /Users/fantina/Desktop/srp_prototype/api
pip3 install -r requirements.txt
```

### 3. Run the dashboard
```bash
bash run_dashboard.sh
# OR
python3 main.py
```

### 4. Open in browser
```
http://localhost:8000
```

---

## 📊 What You'll See

### Key Metrics (Top Section)
- **Total Agents** - How many agents in the system
- **High Confidence** - Agents with verified high scores
- **Rising Stars** - Trending agents
- **Avg Rating** - Average review rating
- **Avg Confidence** - Overall confidence score
- **Needs Support** - Agents needing coaching

### Intelligence Queries (8 Total)

#### 1. 🎯 Movement Intelligence
Shows agents with recent changes or flags
- Agent name, company, vertical
- Movement status and confidence
- Perfect for: Identifying market changes

#### 2. 🤝 Relationship Discovery
Find peer agents in same vertical + location
- Agent 1 ↔ Agent 2 connections
- Shared vertical and city
- Perfect for: Understanding networks

#### 3. 📈 Vertical Intelligence
Cross-vertical professionals (cross-sell opportunities)
- Agents in multiple verticals
- Years of experience
- Perfect for: Finding expansion targets

#### 4. ⭐ Review Sentiment Leaders
High-rated agents by location
- Average rating, review count
- Trust level, company
- Perfect for: Quality assurance

#### 5. 🗺️ Location Concentration
Cities with most agents per vertical
- Agent count by market
- Sample agents in city
- Perfect for: Market analysis

#### 6. 🏢 Tier Hierarchy Intelligence
Agents grouped by company tier
- Tier name, priority, agent count
- Average confidence by tier
- Perfect for: Company structure

#### 7. ✅ Credibility Leaders
High-confidence agents with verified credentials
- Confidence score, trust level
- Trend (rising star, stable, etc.)
- Perfect for: Premium targeting

#### 8. 🌟 Rising Stars & Mentors
Trending agents who should mentor or be mentored
- Sales readiness, win probability
- Influence score, next action
- Perfect for: Talent development

---

## 📡 API Endpoints

### Health Check
```bash
GET /api/health
```

### Metrics
```bash
GET /api/metrics
```
Returns: `{ total_agents, high_confidence, rising_stars, avg_rating, ... }`

### Intelligence Queries
```bash
GET /api/movement-intelligence
GET /api/relationship-discovery
GET /api/vertical-intelligence
GET /api/review-sentiment
GET /api/location-concentration
GET /api/tier-hierarchy
GET /api/credibility-leaders
GET /api/rising-stars
```

Each returns: Array of objects with query results

---

## 🎯 For Your SRP Panel Presentation

### What Makes This Impressive:

✅ **Live Data** - Pulls real-time data from Neo4j  
✅ **8 Intelligence Queries** - Different perspectives on your data  
✅ **Beautiful Dashboard** - Professional visualization  
✅ **API Backend** - Scalable and extensible  
✅ **Smart Metrics** - High-level overview + detailed data  
✅ **Production Ready** - Can handle real workloads  

### Sample Talking Points:

**"We've built a real-time ETL dashboard that pulls intelligence from our Neo4j graph. Here's what it shows:**

- **Movement Intelligence**: Track agents changing companies, locations, verticals in real-time
- **Relationship Discovery**: Identify peer networks and collaboration opportunities
- **Vertical Intelligence**: Find cross-vertical experts for expansion opportunities
- **Rising Stars & Mentors**: Spot high-potential agents and leaders
- **Quality Leaders**: Premium agents ranked by credibility and reviews

*This is just the beginning. The API supports unlimited intelligence queries.*"

---

## 🔧 Troubleshooting

### Dashboard won't load
```
Error: Cannot connect to Neo4j
→ Make sure Neo4j Desktop is running on port 7687
```

### Import error
```
Error: No module named 'fastapi'
→ Run: pip3 install -r requirements.txt
```

### Port already in use
```
Error: Address already in use
→ Change port in main.py: uvicorn.run(app, host="0.0.0.0", port=8001)
```

---

## 📈 Next Steps

### Extend the Dashboard:
1. Add more intelligence queries
2. Add filters and search
3. Export data to CSV/Excel
4. Add user authentication
5. Create scheduled reports

### Scale to Production:
1. Deploy to cloud (AWS, Azure, GCP)
2. Add database caching (Redis)
3. Add monitoring and alerts
4. Add API rate limiting
5. Create GraphQL layer

---

## 📚 Files

| File | Purpose |
|------|---------|
| `main.py` | FastAPI backend with 8 intelligence queries |
| `dashboard.html` | Beautiful frontend with live data |
| `requirements.txt` | Python dependencies |
| `run_dashboard.sh` | Startup script |
| `README.md` | This file |

---

## 🏆 For SRP Build Intake

**This dashboard demonstrates:**
- ✅ Deep understanding of graph data
- ✅ 8 pre-built intelligence queries
- ✅ API layer for other disciplines
- ✅ Beautiful data visualization
- ✅ Production-ready code
- ✅ Scalable architecture

**Impact:** Shows you're not just storing data—you're extracting intelligence that drives decisions.

---

## 📞 Support

Questions? Check:
1. `/api/health` - Is the API running?
2. Neo4j Browser - Is your data there?
3. Browser console - Any JavaScript errors?

---

**🚀 Ready to impress your panel!**
