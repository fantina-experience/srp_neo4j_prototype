# Department Requirements - SRP Graph Data Dependency

How the 4 main SRP Build disciplines use the graph.

---

## 💰 Sales Engine (CPQ & Contract Lifecycle)

### What They Need
Professional data for **guided selling** and **quote building**

### Graph Reads
```
Agent {
  name, email, phone, years_of_experience
  company_name, vertical
  confidence_score, credibility_score
  sales_readiness, win_probability
  avg_rating, review_count, trust_level
  movement_status, pp_movement_flag
}

Verticals (list of specializations)
Tier_Hier (company tier/priority)
Reviews (social proof + ratings)
```

### Key Queries
1. **Professional Profile** - Complete agent details for quote context
2. **Specialists by Vertical** - Find experts in customer's industry
3. **Cross-Vertical Experts** - Multi-specialty professionals for bundles
4. **Movement Signals** - Track changes for contract renewals

### Sample Query
```cypher
MATCH (a:Agent)
WHERE a.sales_readiness = 'high'
RETURN a.name, a.company_name, a.avg_rating, 
       a.win_probability, a.years_of_experience
ORDER BY a.win_probability DESC
LIMIT 50
```

### API Endpoints Used
```
GET /api/credibility-leaders        → High-trust professionals
GET /api/vertical-intelligence      → Multi-specialty experts
GET /api/movement-intelligence      → Recent changes
GET /api/wow-top-performers         → Excellence rankings
```

### Business Impact
- ✅ AI quote guidance ("this professional specializes in X")
- ✅ Risk mitigation (confidence/credibility scores)
- ✅ Cross-sell opportunities (verticals + movement signals)
- ✅ Smart pricing (win probability influences discount levels)

---

## 🔍 Search Engine (Online Search & Ranking)

### What They Need
Ranking scores and **explainability data** for search results

### Graph Reads
```
Agent {
  search_rank (pre-computed score)
  confidence_score
  credibility_score
  influence_score
  avg_rating, review_count
}

Location (for geo-filtering)
Vertical (for vertical filtering)
Reviews (for rating display + ⭐)
Network (SIMILAR_TO for related results)
```

### Key Queries
1. **Agents by Location** - Find professionals in city/state
2. **Agents by Vertical** - Filter by specialization
3. **Quality Leaders** - Top-ranked professionals
4. **Peer Networks** - Related professionals for discovery

### Sample Query
```cypher
MATCH (a:Agent)-[:OPERATES_FROM]->(l:Tier_Location),
      (a)-[:IN_VERTICAL]->(v:Vertical)
WHERE l.city = 'Austin' AND v.vertical = 'Real Estate'
RETURN a.name, a.search_rank, a.avg_rating, a.review_count
ORDER BY a.search_rank DESC
LIMIT 100
```

### API Endpoints Used
```
GET /api/location-concentration     → City analysis
GET /api/vertical-intelligence      → Vertical rankings
GET /api/credibility-leaders        → Trust scores
GET /api/review-sentiment           → Ratings display
```

### Business Impact
- ✅ Rank explainability ("You rank #3 because of X, Y, Z")
- ✅ Faceted discovery (city, vertical, rating filters)
- ✅ Related results (SIMILAR_TO network)
- ✅ Quality assurance (confidence scores)

---

## 📢 Marketing Engine (Content & Targeting)

### What They Need
Professional attributes for **graph-driven personalization**

### Graph Reads
```
Agent {
  location (city, state)
  vertical
  company_name
  experience_level (years_of_experience)
  ratings, reviews
}

Location (demographic context)
Vertical (market segment)
Movement signals (engagement triggers)
Peer networks (audience expansion)
```

### Key Queries
1. **Market Concentration** - Where professionals cluster
2. **Growth Opportunities** - Emerging talent & markets
3. **Audience Segments** - Group by vertical+location
4. **Trending Professionals** - Rising stars for testimonials

### Sample Query
```cypher
MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical),
      (a)-[:OPERATES_FROM]->(l:Tier_Location)
WHERE a.trend = 'rising_star' OR a.pp_movement_flag = true
RETURN l.city, v.vertical, COUNT(a) as opportunity_count,
       AVG(a.win_probability) as market_potential
ORDER BY opportunity_count DESC
```

### API Endpoints Used
```
GET /api/wow-market-concentration   → Market heat mapping
GET /api/wow-growth-opportunities   → Emerging segments
GET /api/review-sentiment           → High-rated testimonials
GET /api/tier-hierarchy             → Tier-based segmentation
```

### Business Impact
- ✅ **Graph-personalized landing pages** - Content by location/vertical
- ✅ **Targeted campaigns** - Reach rising stars in hot markets
- ✅ **Content distribution** - Vertical-specific messaging
- ✅ **Attribution tracking** - Which campaigns moved ratings/movement

---

## 📊 Operations (Monitoring & Release Management)

### What They Need
**System health** and **deployment tracking**

### Graph Reads
```
All Nodes - for data freshness
All Relationships - for graph integrity
Agent.updated_at - last profile update
Movement signals - data velocity

ETL Pipeline state:
  - Load timestamps
  - Error counts
  - Record counts per load
```

### Key Queries
1. **Overall Metrics** - Agent count, rating distribution, trends
2. **Data Quality Audit** - Completeness, freshness, integrity
3. **Relationship Analytics** - Edge counts, network density
4. **Pipeline Health** - ETL freshness and status

### Sample Query
```cypher
MATCH (a:Agent)
RETURN {
  total_agents: COUNT(a),
  high_confidence: SIZE([x IN COLLECT(a) WHERE x.confidence_score > 80]),
  avg_rating: ROUND(AVG(a.avg_rating), 2),
  reviews: COUNT(DISTINCT a.id),
  data_coverage: ROUND(100.0 * COUNT(*) / 100, 1)
} as health_check
```

### API Endpoints Used
```
GET /api/metrics                    → Overall statistics
GET /api/health                     → System health check
GET /api/tier-hierarchy             → Structure verification
GET /api/relationship-discovery     → Network integrity
```

### Business Impact
- ✅ **Release coordination** - Track what deployed when
- ✅ **Rollback capability** - Version control for graph data
- ✅ **SLA compliance** - Data freshness monitoring
- ✅ **Incident response** - Quick diagnosis of data issues

---

## 🔄 Data Flow Between Disciplines

```
┌─────────────────────────────────────────────────────┐
│                    Neo4j Graph                      │
│  (408 nodes, 658 edges, 8 enhancements)            │
└─────────────────────────────────────────────────────┘
           ↑                    ↑                ↑
           │                    │                │
      ETL Pipeline         (Read from)     (Monitor)
      (Updates graph)           │                │
                                │                │
         ┌──────────────────────┼────────────────┴──────────────────┐
         │                      │                                   │
         ▼                      ▼                                   ▼
    ┌─────────────┐    ┌──────────────────────┐         ┌──────────────┐
    │   Sales     │    │  Search + Marketing  │         │ Operations   │
    │   Engine    │    │       Engine         │         │  & Monitoring│
    │             │    │                      │         │              │
    │ Reads:      │    │ Reads:               │         │ Reads:       │
    │ -Profiles   │    │ -Rankings            │         │ -Freshness   │
    │ -Ratings    │    │ -Quality scores      │         │ -Integrity   │
    │ -Movement   │    │ -Location            │         │ -Velocity    │
    │ -Verticals  │    │ -Verticals           │         │ -Counts      │
    │             │    │ -Networks            │         │              │
    │ Uses:       │    │                      │         │ Uses:        │
    │ -Quote      │    │ Uses:                │         │ -Monitoring  │
    │  builder    │    │ -Search ranking      │         │ -Alerts      │
    │ -Contract   │    │ -Facets              │         │ -Rollbacks   │
    │  guidance   │    │ -Personalization     │         │ -Reporting   │
    └─────────────┘    └──────────────────────┘         └──────────────┘
```

---

## 🎯 Query Ownership

| Query Type | Primary User | Secondary Users |
|-----------|--------------|-----------------|
| Agent Profile | Sales | Search, Marketing, Ops |
| Location-based | Search, Marketing | Operations |
| Vertical-based | Sales, Marketing | Search |
| Movement Signals | Sales | Ops (monitoring) |
| Ratings/Reviews | Sales | Marketing, Search |
| Network/Peer | Search | Marketing |
| Market Trends | Marketing | Sales |
| System Health | Operations | All (for SLA tracking) |

---

## 📊 Data Governance

### Who Writes to the Graph
- **ETL (Abdul)** - Updates all agent/review data
- **Data/Graph team** - Manages schema, enhancements
- **No one else** - Disciplines read-only

### Who Reads from the Graph
- **Sales Engine** - 5 core queries, 2 WOW queries
- **Search Engine** - 4 core queries
- **Marketing Engine** - 3 core queries, 2 WOW queries
- **Operations** - 2 core queries, monitoring endpoints

### Read Contract
```
Stable fields (won't change):
  - Agent.id, name, email, phone
  - Agent.vertical, location
  - Agent.confidence_score, credibility_score

Enhancement fields (may be added):
  - Pre-computed scores (sales_readiness, search_rank, etc.)
  - Temporal properties (trend, movement_status)
  - Network insights (influence_score)

Deprecated fields (removed):
  - Reviewer as separate node
  - Company as separate node
  - Any field prefixed with "temp_" or "debug_"
```

---

## 🚀 Integration Checklist

- [ ] **Sales** - CPQ system integrated with /api/credibility-leaders
- [ ] **Search** - Search ranking using Agent.search_rank
- [ ] **Marketing** - Campaign builder reading market concentrations
- [ ] **Operations** - Monitoring dashboard checking /api/health
- [ ] **All teams** - Using shared vocabulary (vertical, location, tier)

---

## 📞 Support

- **Architecture questions** → See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Query issues** → See [../QUERY_CATALOG.md](../QUERY_CATALOG.md)
- **Setup problems** → See [../QUICK_START.md](../QUICK_START.md)

---

**Version 1.0** | Built September 2026 | Production Ready ✅
