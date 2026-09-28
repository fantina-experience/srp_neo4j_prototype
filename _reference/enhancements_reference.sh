#!/bin/bash

# ENHANCEMENTS BY EDGE - Quick Reference Guide
# Shows which enhancement is applied to which edge

echo ""
echo "================================================================================"
echo "📊 ENHANCEMENTS BY EDGE - QUICK REFERENCE"
echo "================================================================================"
echo ""

echo "🔗 EDGE 1: REVIEWED_BY (Review → Reviewer)"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #2 Relationship Properties"
echo "Properties: confidence, recency, source"
echo "Code Location: neo4j_loader.py lines 373-382"
echo ""
echo "Query:"
echo '  MATCH (r:Review)-[rel:REVIEWED_BY]->(rev:Reviewer)'
echo '  RETURN r.id, rev.name, rel.confidence, rel.recency LIMIT 5'
echo ""

echo "🔗 EDGE 2: REPRESENTS (Agent → Tier_Hier)"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #2 Relationship Properties"
echo "Properties: priority, is_primary"
echo "Code Location: neo4j_loader.py lines 388-393"
echo ""
echo "Query:"
echo '  MATCH (a:Agent)-[rel:REPRESENTS]->(t:Tier_Hier)'
echo '  RETURN a.name, t.tier_name, rel.priority, rel.is_primary LIMIT 5'
echo ""

echo "🔗 EDGE 3: OPERATES_FROM (Agent → Tier_Location)"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #2 Relationship Properties"
echo "Properties: title, phone_office, email1, region, city, years_of_experience"
echo "Code Location: neo4j_loader.py lines 400-405 (+ 243-245 for initial setup)"
echo ""
echo "Query:"
echo '  MATCH (a:Agent)-[rel:OPERATES_FROM]->(l:Tier_Location)'
echo '  RETURN a.name, l.city, rel.title, rel.years_of_experience, rel.region LIMIT 5'
echo ""

echo "🔗 EDGE 4a: SIMILAR_TO (Agent ↔ Agent) - same_tier"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #4 Network Insights"
echo "Properties: match_type='same_tier', confidence=0.8"
echo "Code Location: neo4j_loader.py lines 463-469"
echo ""
echo "Query:"
echo '  MATCH (a:Agent)-[rel:SIMILAR_TO {match_type: "same_tier"}]->(b:Agent)'
echo '  RETURN a.name, b.name, rel.confidence LIMIT 5'
echo ""

echo "🔗 EDGE 4b: SIMILAR_TO (Agent ↔ Agent) - same_market"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #4 Network Insights"
echo "Properties: match_type='same_market', confidence=0.95"
echo "Code Location: neo4j_loader.py lines 477-483"
echo ""
echo "Query:"
echo '  MATCH (a:Agent)-[rel:SIMILAR_TO {match_type: "same_market"}]->(b:Agent)'
echo '  RETURN a.name, b.name, rel.confidence LIMIT 5'
echo ""

echo "🔗 EDGE 5: WORKS_FOR (Agent → Company)"
echo "─────────────────────────────────────────────────────────────────────────────"
echo "Enhancement: #7 Company Hierarchy"
echo "Properties: (no edge properties, used for aggregation)"
echo "Code Location: neo4j_loader.py lines 562-567"
echo ""
echo "Query:"
echo '  MATCH (a:Agent)-[rel:WORKS_FOR]->(c:Company)'
echo '  RETURN a.name, c.name, c.market_tier LIMIT 5'
echo ""

echo "================================================================================"
echo "📋 EDGES WITHOUT ENHANCEMENTS"
echo "================================================================================"
echo ""
echo "These edges exist but have no enhancement properties:"
echo ""
echo "  • HAS_LOCATION (Tier_Hier → Tier_Location)"
echo "  • IN_VERTICAL (Agent → Vertical)"
echo "  • REVIEWED_BY (Agent → Review)"
echo "  • HAS_SUBVERTICAL (Vertical → Subvertical)"
echo "  • HAS_SOURCE (Vertical → Source_name)"
echo "  • FROM_SOURCE (Agent → Source_name)"
echo ""

echo "================================================================================"
echo "📊 SUMMARY TABLE"
echo "================================================================================"
echo ""
printf "%-20s | %-30s | %-12s | %-6s\n" "Edge" "Enhancement" "Properties" "Count"
printf "%-20s | %-30s | %-12s | %-6s\n" "─────────────────" "──────────────────────────" "──────────" "─────"
printf "%-20s | %-30s | %-12s | %-6s\n" "REVIEWED_BY" "#2 Properties" "confidence" "172"
printf "%-20s | %-30s | %-12s | %-6s\n" "REPRESENTS" "#2 Properties" "priority" "100"
printf "%-20s | %-30s | %-12s | %-6s\n" "OPERATES_FROM" "#2 Properties" "region" "100"
printf "%-20s | %-30s | %-12s | %-6s\n" "SIMILAR_TO" "#4 Network" "match_type" "134"
printf "%-20s | %-30s | %-12s | %-6s\n" "WORKS_FOR" "#7 Company" "linking" "100"
echo ""

echo "================================================================================"
echo "✨ File Location: /Users/fantina/Desktop/srp_prototype/scripts/neo4j_loader.py"
echo "================================================================================"
echo ""
