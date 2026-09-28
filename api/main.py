#!/usr/bin/env python3
"""
SRP ETL Dashboard API
Serves real data from Neo4j instance for dashboard visualization
"""

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from neo4j import GraphDatabase
from typing import List, Dict, Any
import os

# Neo4j Connection
NEO4J_URI = "neo4j://127.0.0.1:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "ETL_fantina_2026"

driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

app = FastAPI(title="SRP ETL Dashboard API", version="1.0")

print("✅ Connected to Neo4j:", NEO4J_URI)

# ============================================================================
# QUERY 1: MOVEMENT INTELLIGENCE
# Agents with recent changes or flags
# ============================================================================

@app.get("/api/movement-intelligence")
async def movement_intelligence():
    """Find agents with movement flags or recent updates"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:REPRESENTS]->(t:Tier_Hier)
            WHERE a.pp_movement_flag = true OR a.movement_status = 'recently_changed'
            RETURN {
                agent_name: a.name,
                company: a.company_name,
                vertical: a.vertical,
                city: a.city,
                state: a.state,
                tier: t.tier_name,
                movement_flag: a.pp_movement_flag,
                movement_status: a.movement_status,
                last_updated: a.updated_at,
                confidence: a.confidence_score
            } as data
            LIMIT 50
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 2: RELATIONSHIP DISCOVERY
# Agents in same vertical + location
# ============================================================================

@app.get("/api/relationship-discovery")
async def relationship_discovery():
    """Find peer agents in same vertical and location"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a1:Agent)-[rel:SIMILAR_TO {match_type: 'same_market'}]->(a2:Agent)
            OPTIONAL MATCH (a1)-[:IN_VERTICAL]->(v:Vertical)
            OPTIONAL MATCH (a1)-[:OPERATES_FROM]->(l:Tier_Location)
            RETURN {
                agent1: a1.name,
                company1: a1.company_name,
                agent2: a2.name,
                company2: a2.company_name,
                vertical: COALESCE(v.vertical, 'Unknown'),
                city: COALESCE(l.city, 'Unknown'),
                state: COALESCE(l.state, 'Unknown'),
                similarity_confidence: rel.confidence,
                match_type: rel.match_type
            } as data
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 3: VERTICAL INTELLIGENCE
# Agents operating in multiple verticals
# ============================================================================

@app.get("/api/vertical-intelligence")
async def vertical_intelligence():
    """Find cross-vertical professionals (cross-sell opportunities)"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical)
            WITH a, COUNT(DISTINCT v.vertical) AS vertical_count,
                 COLLECT(DISTINCT v.vertical) AS verticals
            WHERE vertical_count > 1
            RETURN {
                agent_id: a.id,
                name: a.name,
                company: a.company_name,
                email: a.email1,
                phone: a.phone,
                vertical_count: vertical_count,
                verticals: verticals,
                years_experience: a.years_of_experience,
                confidence: a.confidence_score,
                influence: a.influence_score
            } as data
            ORDER BY vertical_count DESC
            LIMIT 50
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 4: REVIEW SENTIMENT NETWORK
# High-rated agents by location
# ============================================================================

@app.get("/api/review-sentiment")
async def review_sentiment():
    """Agents with high ratings and their locations"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)
            WHERE a.avg_rating >= 4.0 AND a.review_count > 2
            OPTIONAL MATCH (a)-[:OPERATES_FROM]->(l:Tier_Location)
            RETURN {
                agent: a.name,
                city: l.city,
                state: l.state,
                avg_rating: a.avg_rating,
                review_count: a.review_count,
                company: a.company_name,
                trust_level: a.trust_level,
                confidence: a.confidence_score
            } as data
            ORDER BY a.avg_rating DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 5: LOCATION CONCENTRATION
# Cities with most agents per vertical
# ============================================================================

@app.get("/api/location-concentration")
async def location_concentration():
    """Find cities with most agents per vertical"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:OPERATES_FROM]->(l:Tier_Location),
                  (a:Agent)-[:IN_VERTICAL]->(v:Vertical)
            RETURN {
                city: l.city,
                state: l.state,
                vertical: v.vertical,
                agent_count: COUNT(DISTINCT a.id),
                sample_agents: COLLECT(DISTINCT a.name)[0..5]
            } as data
            ORDER BY data.agent_count DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 6: TIER HIERARCHY INTELLIGENCE
# Agents by tier level with metrics
# ============================================================================

@app.get("/api/tier-hierarchy")
async def tier_hierarchy():
    """Show agents by tier level with aggregate metrics"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:REPRESENTS]->(t:Tier_Hier)
            WITH t,
                 COUNT(DISTINCT a.id) AS agent_count,
                 AVG(a.confidence_score) AS avg_confidence,
                 COLLECT(DISTINCT a.city)[0..5] AS sample_cities
            RETURN {
                tier: COALESCE(t.tier_name, 'Unknown'),
                priority: COALESCE(t.priority, 0),
                agent_count: agent_count,
                avg_confidence: ROUND(avg_confidence, 2),
                sample_cities: sample_cities
            } as data
            ORDER BY agent_count DESC
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 7: TRUST & CREDIBILITY LEADERS
# High-confidence agents by location
# ============================================================================

@app.get("/api/credibility-leaders")
async def credibility_leaders():
    """Agents with verified high confidence scores"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)
            WHERE a.trust_level = 'high_confidence'
              AND a.confidence_score > 80
            OPTIONAL MATCH (a)-[:OPERATES_FROM]->(l:Tier_Location)
            OPTIONAL MATCH (a)-[:IN_VERTICAL]->(v:Vertical)
            RETURN {
                agent: a.name,
                company: a.company_name,
                vertical: v.vertical,
                city: l.city,
                state: l.state,
                confidence_score: a.confidence_score,
                credibility_score: a.credibility_score,
                trust_level: a.trust_level,
                trend: a.trend
            } as data
            ORDER BY a.confidence_score DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# QUERY 8: RISING STARS & MENTORS
# Trending agents who should mentor or be mentored
# ============================================================================

@app.get("/api/rising-stars")
async def rising_stars():
    """Identify rising stars and established leaders"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)
            WHERE a.trend IN ['rising_star', 'established_leader']
            OPTIONAL MATCH (a)-[:REPRESENTS]->(t:Tier_Hier)
            OPTIONAL MATCH (a)-[:OPERATES_FROM]->(l:Tier_Location)
            RETURN {
                agent: a.name,
                company: a.company_name,
                trend: a.trend,
                tier: t.tier_name,
                city: l.city,
                state: l.state,
                sales_readiness: a.sales_readiness,
                win_probability: a.win_probability,
                influence: a.influence_score,
                next_action: a.next_action
            } as data
            ORDER BY a.influence_score DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# WOW QUERY 1: TOP PERFORMERS BY VERTICAL
# Excellence rankings - who dominates each market
# ============================================================================

@app.get("/api/wow-top-performers")
async def wow_top_performers():
    """Top performers ranked by vertical with star ratings"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical)
            WITH v, a
            ORDER BY a.influence_score DESC
            WITH v, COLLECT({
                agent: a.name,
                confidence: a.confidence_score,
                rating: a.avg_rating,
                reviews: a.review_count,
                trend: a.trend,
                influence: a.influence_score
            })[0..5] as top_agents
            RETURN {
                vertical: v.vertical,
                top_performers: top_agents,
                market_strength: SIZE(top_agents)
            } as data
            ORDER BY SIZE(top_agents) DESC
        """)
        return [record['data'] for record in result]

# ============================================================================
# WOW QUERY 2: MARKET CONCENTRATION
# Where the demand and opportunity is
# ============================================================================

@app.get("/api/wow-market-concentration")
async def wow_market_concentration():
    """Market concentration: density analysis by location & vertical"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical),
                  (a)-[:OPERATES_FROM]->(l:Tier_Location)
            WITH l.city as city, l.state as state, v.vertical as vertical, COUNT(a) as agent_count
            WHERE agent_count > 1
            RETURN {
                city: city,
                state: state,
                vertical: vertical,
                agent_count: agent_count,
                market_heat: CASE
                    WHEN agent_count > 10 THEN '🔥 HOT'
                    WHEN agent_count > 5 THEN '⚡ WARM'
                    ELSE '💡 EMERGING'
                END
            } as data
            ORDER BY agent_count DESC
            LIMIT 40
        """)
        return [record['data'] for record in result]

# ============================================================================
# WOW QUERY 3: QUALITY LEADERS NETWORK
# Agents working with high-rated peers
# ============================================================================

@app.get("/api/wow-quality-network")
async def wow_quality_network():
    """Quality leaders: agents with high-rated peer networks"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a1:Agent)-[sim:SIMILAR_TO]->(a2:Agent)
            WHERE a1.avg_rating >= 4.0 AND a2.avg_rating >= 4.0
            WITH a1, COUNT(a2) as peer_count, AVG(a2.avg_rating) as peer_avg_rating
            WHERE peer_count > 2
            WITH a1, peer_count, ROUND(peer_avg_rating, 2) as peer_avg_rating,
                 peer_count * peer_avg_rating as network_strength
            RETURN {
                agent: a1.name,
                rating: a1.avg_rating,
                reviews: a1.review_count,
                quality_peers: peer_count,
                peer_avg_rating: peer_avg_rating,
                network_strength: ROUND(network_strength, 2)
            } as data
            ORDER BY network_strength DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# WOW QUERY 4: GROWTH OPPORTUNITIES
# Emerging segments with high potential
# ============================================================================

@app.get("/api/wow-growth-opportunities")
async def wow_growth_opportunities():
    """Growth opportunities: emerging verticals and locations with rising talent"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)-[:IN_VERTICAL]->(v:Vertical),
                  (a)-[:OPERATES_FROM]->(l:Tier_Location)
            WHERE a.trend = 'rising_star' OR a.pp_movement_flag = true
            WITH v.vertical as vertical, l.city as city, l.state as state,
                 COUNT(a) as opportunity_count,
                 AVG(a.win_probability) as avg_win_prob,
                 COUNT(DISTINCT a.trend) as trend_diversity
            WHERE opportunity_count > 0
            RETURN {
                vertical: vertical,
                city: city,
                state: state,
                rising_talent_count: opportunity_count,
                avg_win_probability: ROUND(avg_win_prob, 2),
                opportunity_score: opportunity_count * avg_win_prob,
                signal: CASE
                    WHEN opportunity_count > 5 AND avg_win_prob > 0.6 THEN '🚀 HIGH PRIORITY'
                    WHEN opportunity_count > 3 THEN '📈 DEVELOP'
                    ELSE '👀 WATCH'
                END
            } as data
            ORDER BY opportunity_count DESC
            LIMIT 30
        """)
        return [record['data'] for record in result]

# ============================================================================
# DASHBOARD METRICS
# Overall statistics for the dashboard
# ============================================================================

@app.get("/api/metrics")
async def get_metrics():
    """Get overall dashboard metrics"""
    with driver.session() as session:
        result = session.run("""
            MATCH (a:Agent)
            RETURN {
                total_agents: COUNT(a),
                high_confidence: SIZE([x IN COLLECT(a) WHERE x.trust_level = 'high_confidence']),
                medium_confidence: SIZE([x IN COLLECT(a) WHERE x.trust_level = 'medium_confidence']),
                low_confidence: SIZE([x IN COLLECT(a) WHERE x.trust_level = 'low_confidence']),
                avg_confidence_score: ROUND(AVG(a.confidence_score), 2),
                rising_stars: SIZE([x IN COLLECT(a) WHERE x.trend = 'rising_star']),
                established_leaders: SIZE([x IN COLLECT(a) WHERE x.trend = 'established_leader']),
                needs_support: SIZE([x IN COLLECT(a) WHERE x.trend = 'needs_support']),
                avg_reviews: ROUND(AVG(a.review_count), 2),
                avg_rating: ROUND(AVG(a.avg_rating), 2)
            } as metrics
        """)
        return result.single()['metrics']

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.get("/api/health")
async def health():
    """Health check endpoint"""
    try:
        with driver.session() as session:
            session.run("RETURN 1")
        return {
            "status": "healthy",
            "database": "neo4j",
            "uri": NEO4J_URI
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# SERVE DASHBOARD HTML
# ============================================================================

@app.get("/")
async def root():
    """Serve dashboard"""
    dashboard_path = os.path.join(os.path.dirname(__file__), "dashboard.html")
    if os.path.exists(dashboard_path):
        return FileResponse(dashboard_path)
    return {"message": "Dashboard not found. API is running."}

@app.get("/departments")
@app.get("/departments.html")
async def departments():
    """Serve departments dashboard"""
    departments_path = os.path.join(os.path.dirname(__file__), "departments.html")
    if os.path.exists(departments_path):
        return FileResponse(departments_path)
    return {"message": "Departments dashboard not found."}

if __name__ == "__main__":
    import uvicorn
    print("\n" + "="*80)
    print("🚀 SRP ETL Dashboard API - 12 Intelligence Queries")
    print("="*80)
    print("\n✅ API running at: http://localhost:8000")
    print("📊 Dashboard at: http://localhost:8000/")
    print("\n📡 CORE INTELLIGENCE QUERIES (8):")
    print("  1️⃣  /api/movement-intelligence        → Agent movement & flags")
    print("  2️⃣  /api/relationship-discovery       → Peer networks")
    print("  3️⃣  /api/vertical-intelligence        → Cross-vertical experts")
    print("  4️⃣  /api/review-sentiment             → High-rated agents ⭐")
    print("  5️⃣  /api/location-concentration       → City analysis")
    print("  6️⃣  /api/tier-hierarchy               → Tier structure")
    print("  7️⃣  /api/credibility-leaders          → Trust leaders")
    print("  8️⃣  /api/rising-stars                 → Trending agents")
    print("\n💡 WOW QUERIES (4):")
    print("  9️⃣  /api/wow-top-performers           → Excellence by vertical 🏆")
    print("  🔟 /api/wow-market-concentration     → Market heat & density 🔥")
    print("  1️⃣1️⃣ /api/wow-quality-network         → Quality peer networks 💎")
    print("  1️⃣2️⃣ /api/wow-growth-opportunities    → Emerging opportunities 🚀")
    print("\n⚙️  UTILITY ENDPOINTS:")
    print("  GET /api/metrics                      → Overall statistics")
    print("  GET /api/health                       → Health check")
    print("\n" + "="*80 + "\n")

    uvicorn.run(app, host="0.0.0.0", port=8000)
