# SRP Build Prototype - Neo4j Graph Intelligence Platform

**Status:** Production-Ready Prototype  
**Version:** 1.0  
**Built:** September 2026

---

## 🎯 What This Is

A **unified data graph** powering 12 disciplines in the SRP Build platform. Consolidates agent/professional data into a single source of truth that Sales, Marketing, Search, and Operations teams read from — enabling:

- ✅ **AI-Guided Selling** - CPQ systems get professional context for quote building
- ✅ **Graph-Driven Targeting** - Marketing personalizes content by location & vertical
- ✅ **Rank Explainability** - Search shows why professionals rank where they do
- ✅ **Operational Intelligence** - Ops monitors data freshness and ETL pipelines

---

## 📊 What You Get

### The Graph
- **408 Nodes** - Agents, Reviews, Tiers, Locations, Verticals, Sources
- **658 Relationships** - REVIEWED_BY, IN_VERTICAL, OPERATES_FROM, REPRESENTS, etc.
- **100 Professionals** - Complete profiles with 172 reviews, ratings, movement signals
- **8 Smart Enhancements** - Pre-computed scores, aggregates, trends, hierarchies

### Intelligence Layer
- **12 Queries** - 8 core + 4 "WOW" queries serving all disciplines
- **REST API** - FastAPI backend with live Neo4j reads
- **Beautiful Dashboard** - Real-time visualization + department-specific views
- **⭐ Star Ratings** - Visual relationship properties (5-star display on reviews)

### Production Ready
- **Idempotent ETL** - Safe to rerun without creating duplicates
- **No Reviewer Nodes** - Denormalized into Review properties
- **No Company Nodes** - Location-focused (OPERATES_FROM relationships)
- **Clean Structure** - 21 MERGE statements, zero CREATE statements

---

## 🚀 Quick Start

### 1. Start Neo4j
```bash
# Open Neo4j Desktop and start your instance on port 7687
# Set password to: ETL_fantina_2026
```

### 2. Load Data
```bash
cd /Users/fantina/Desktop/srp_prototype/scripts
python3 neo4j_loader.py
```

### 3. Run Dashboard
```bash
cd /Users/fantina/Desktop/srp_prototype/api
bash run_dashboard.sh
```

### 4. View
- **Main Dashboard:** http://localhost:8000/
- **Department Views:** http://localhost:8000/departments
- **Neo4j Browser:** http://localhost:7474

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| [QUICK_START.md](QUICK_START.md) | 3-step setup guide |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Graph design & enhancements |
| [QUERY_CATALOG.md](QUERY_CATALOG.md) | All 12 queries by discipline |
| [DEPARTMENTS.md](docs/DEPARTMENTS.md) | What each team needs |

---

## 🎯 For Each Discipline

### 💰 Sales Engine (CPQ & Contracting)
Reads: Professional profiles, verticals, ratings, trends  
Enables: AI quote narratives, contract guidance, specialist recommendations

### 🔍 Search Engine (Online Search & Ranking)
Reads: Ranking scores, credibility, search metrics  
Enables: Query results, rank explainability, faceted discovery

### 📢 Marketing Engine (Content & Targeting)
Reads: Location, vertical, professional attributes  
Enables: Graph-personalized landing pages, content targeting, attribution

### 📊 Operations (Monitoring & Release)
Reads: Data freshness, quality metrics, pipeline state  
Enables: System health dashboard, rollback capabilities, deployment tracking

---

## 🔌 API Endpoints (12 Total)

### Core Intelligence (8)
```
GET /api/movement-intelligence       → Agent movement & flags
GET /api/relationship-discovery      → Peer networks
GET /api/vertical-intelligence       → Cross-vertical professionals
GET /api/review-sentiment            → High-rated professionals ⭐
GET /api/location-concentration      → City/vertical density
GET /api/tier-hierarchy              → Organizational structure
GET /api/credibility-leaders         → Trust leaders
GET /api/rising-stars                → Trending professionals
```

### WOW Queries (4)
```
GET /api/wow-top-performers          → Excellence by vertical
GET /api/wow-market-concentration    → Market heat & density
GET /api/wow-quality-network         → Quality peer networks
GET /api/wow-growth-opportunities    → Emerging opportunities
```

---

## 🔧 System Requirements

- **Python:** 3.8+
- **Neo4j:** 5.x
- **Memory:** 4GB minimum
- **Dependencies:** See `api/requirements.txt`

---

**Ready for SRP Build Intake Presentation** ✅
