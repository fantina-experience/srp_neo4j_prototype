// ============================================================
// SRP Prototype - WOW Queries for Neo4j
// ============================================================
// Paste each query into Neo4j Browser to see results

// ============================================================
// QUERY 1: MOVEMENT INTELLIGENCE
// Show agents who have movement flags or recently updated profiles
// ============================================================

MATCH (a:Agent)-[]->(t:Tier)
WHERE a.pp_movement_flag = true OR a.multi_vertical_flag IS NOT NULL
RETURN
  a.name AS "Agent Name",
  a.company_name AS "Company",
  a.vertical AS "Vertical",
  a.city AS "City",
  a.state AS "State",
  t.tier_name AS "Tier",
  a.pp_movement_flag AS "Movement Flag",
  a.updated_at AS "Last Updated"
LIMIT 50;

// ============================================================
// QUERY 2: RELATIONSHIP DISCOVERY
// Find agents in same location/vertical (network intelligence)
// ============================================================

MATCH (a1:Agent)-[:OPERATES_IN]->(v:Vertical)<-[:OPERATES_IN]-(a2:Agent),
      (a1:Agent)-[:LOCATED_AT]->(l:Location)<-[:LOCATED_AT]-(a2:Agent)
WHERE a1.id < a2.id  // Avoid duplicates
RETURN
  a1.name AS "Agent 1",
  a1.company_name AS "Company 1",
  a2.name AS "Agent 2",
  a2.company_name AS "Company 2",
  v.vertical AS "Shared Vertical",
  l.city AS "Shared City",
  l.state AS "Shared State"
LIMIT 30;

// ============================================================
// QUERY 3: VERTICAL INTELLIGENCE
// Find multi-vertical professionals (cross-sell opportunities)
// ============================================================

MATCH (a:Agent)-[:OPERATES_IN]->(v:Vertical)
WITH a, COUNT(DISTINCT v.vertical) AS vertical_count,
     COLLECT(DISTINCT v.vertical) AS verticals
WHERE vertical_count > 1
RETURN
  a.id AS "Agent ID",
  a.name AS "Name",
  a.company_name AS "Company",
  a.email1 AS "Email",
  a.phone AS "Phone",
  vertical_count AS "Vertical Count",
  verticals AS "Verticals",
  a.years_of_experience AS "Years Exp"
ORDER BY vertical_count DESC
LIMIT 50;

// ============================================================
// BONUS QUERY 4: REVIEW SENTIMENT NETWORK
// Agents with high ratings and their location connections
// ============================================================

MATCH (a:Agent)-[:RECEIVED_REVIEW]->(r:Review)
WHERE r.rating > 4
WITH a, AVG(CAST(r.rating AS FLOAT)) AS avg_rating, COUNT(r) AS review_count
WHERE review_count > 2
MATCH (a)-[:LOCATED_AT]->(l:Location)
RETURN
  a.name AS "Agent",
  l.city AS "City",
  l.state AS "State",
  ROUND(avg_rating, 2) AS "Avg Rating",
  review_count AS "Review Count",
  a.company_name AS "Company"
ORDER BY avg_rating DESC
LIMIT 30;

// ============================================================
// BONUS QUERY 5: LOCATION CONCENTRATION
// Find cities with most agents per vertical
// ============================================================

MATCH (a:Agent)-[:LOCATED_AT]->(l:Location),
      (a:Agent)-[:OPERATES_IN]->(v:Vertical)
RETURN
  l.city AS "City",
  l.state AS "State",
  v.vertical AS "Vertical",
  COUNT(DISTINCT a.id) AS "Agent Count",
  COLLECT(DISTINCT a.name)[0..5] AS "Sample Agents"
ORDER BY "Agent Count" DESC
LIMIT 30;

// ============================================================
// BONUS QUERY 6: TIER HIERARCHY INTELLIGENCE
// Show agents by tier level
// ============================================================

MATCH (a:Agent)-[:HAS_TIER]->(t:Tier)
RETURN
  t.tier_name AS "Tier",
  t.priority AS "Priority",
  t.vertical AS "Vertical",
  COUNT(DISTINCT a.id) AS "Agent Count",
  AVG(CAST(a.confidence_score AS FLOAT)) AS "Avg Confidence",
  COLLECT(DISTINCT a.city)[0..5] AS "Sample Cities"
ORDER BY "Agent Count" DESC;

// ============================================================
// BONUS QUERY 7: VERIFICATION STATUS (Credibility)
// Agents with verified credentials across multiple sources
// ============================================================

MATCH (a:Agent)-[:HAS_GBP_PROFILE]->(g:GBPProfile)
WHERE g.is_valid = true
RETURN
  a.name AS "Agent",
  a.company_name AS "Company",
  a.vertical AS "Vertical",
  a.city AS "City",
  a.confidence_score AS "Confidence Score",
  g.gbp_name AS "GBP Name",
  g.final_score AS "GBP Match Score"
ORDER BY g.final_score DESC
LIMIT 30;
