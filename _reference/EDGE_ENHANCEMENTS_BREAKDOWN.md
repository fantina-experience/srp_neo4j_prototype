# Which Edge Has Which Enhancement?

**Summary: 3 enhancements added properties to edges**

---

## Enhancement 2: Relationship Properties

### REVIEWED_BY Edge (Review -> Reviewer)
**What was added:**
```
REVIEWED_BY {
  confidence: 'high' | 'medium' | 'low',
  recency: number (months),
  source: string
}
```

**Example:**
```
Review #123 -[:REVIEWED_BY {confidence: 'high', recency: 5, source: 'google.com'}]-> John Smith
```

**Query to view:**
```cypher
MATCH (r:Review)-[rel:REVIEWED_BY]->(rev:Reviewer)
RETURN rel.confidence, rel.recency, rel.source
LIMIT 5
```

**Result:**
```
confidence  | recency | source
─────────────────────────────
high        | 5       | google.com
high        | 3       | zillow.com
medium      | 12      | realtor.com
low         | 24      | yelp.com
```

---

### REPRESENTS Edge (Agent -> Tier_Hier)
**What was added:**
```
REPRESENTS {
  strength: number,
  is_primary: true | false
}
```

**Example:**
```
Anthony Grech -[:REPRESENTS {strength: 100, is_primary: true}]-> Primary Tier
```

**Query to view:**
```cypher
MATCH (a:Agent)-[rel:REPRESENTS]->(t:Tier_Hier)
RETURN a.name, t.tier_name, rel.strength, rel.is_primary
LIMIT 5
```

**Result:**
```
name            | tier_name  | strength | is_primary
───────────────────────────────────────────────────
Anthony Grech   | Primary    | 100      | true
Grace Zhao      | Secondary  | 50       | false
Ashley Shammami | Primary    | 100      | true
```

---

### OPERATES_FROM Edge (Agent -> Tier_Location)
**What was added:**
```
OPERATES_FROM {
  title: string (agent's job title),
  phone_office: string,
  email1: string,
  region: string (state),
  city: string
}
```

**Example:**
```
Anthony Grech -[:OPERATES_FROM {
  title: 'Senior Loan Officer',
  phone_office: '+1-313-555-0100',
  email1: 'anthony@ccrm.com',
  region: 'MI',
  city: 'Detroit'
}]-> Detroit, MI Location
```

**Query to view:**
```cypher
MATCH (a:Agent)-[rel:OPERATES_FROM]->(l:Tier_Location)
RETURN a.name, l.city, l.state, rel.title, rel.region
LIMIT 5
```

**Result:**
```
name            | city    | state | title                  | region
──────────────────────────────────────────────────────────────────
Anthony Grech   | Detroit | MI    | Senior Loan Officer    | MI
Grace Zhao      | Chicago | IL    | Loan Processor         | IL
Ashley Shammami | Phoenix | AZ    | Branch Manager         | AZ
```

---

## Enhancement 4: Network Insights

### SIMILAR_TO Edge (Agent -> Agent, bidirectional)
**What was added:**
```
SIMILAR_TO {
  match_type: 'same_tier' | 'same_market',
  confidence: 0.8 | 0.95
}
```

**Example:**
```
Anthony Grech -[:SIMILAR_TO {match_type: 'same_tier', confidence: 0.8}]- Grace Zhao
Anthony Grech -[:SIMILAR_TO {match_type: 'same_market', confidence: 0.95}]- Ashley Shammami
```

**Query to view:**
```cypher
MATCH (a:Agent {name: 'Anthony Grech'})-[rel:SIMILAR_TO]->(similar:Agent)
RETURN similar.name, rel.match_type, rel.confidence
ORDER BY rel.confidence DESC
```

**Result:**
```
name            | match_type  | confidence
─────────────────────────────────────────
Ashley Shammami | same_market | 0.95
Grace Zhao      | same_tier   | 0.8
Adam Masood     | same_tier   | 0.8
```

**What it means:**
- `same_market`: Same vertical + same location (very similar, confidence 0.95)
- `same_tier`: Same tier company (similar tier, confidence 0.8)

---

## Enhancement 7: Company Hierarchy

### WORKS_FOR Edge (Agent -> Company)
**What was added:**
```
WORKS_FOR {
  (no edge properties, but used to link agents to company nodes)
}
```

**Example:**
```
Anthony Grech -[:WORKS_FOR]-> CrossCountry Mortgage, LLC
Grace Zhao -[:WORKS_FOR]-> CrossCountry Mortgage, LLC
Ashley Shammami -[:WORKS_FOR]-> Loan Depot
```

**Query to view:**
```cypher
MATCH (a:Agent)-[rel:WORKS_FOR]->(c:Company)
RETURN a.name, c.name, c.market_tier, c.agent_count
ORDER BY c.agent_count DESC
```

**Result:**
```
name            | company                    | market_tier  | agent_count
──────────────────────────────────────────────────────────────────────
Anthony Grech   | CrossCountry Mortgage LLC  | small_business| 1
Grace Zhao      | CrossCountry Mortgage LLC  | small_business| 1
Ashley Shammami | Loan Depot                 | small_business| 1
```

---

## All Edges with Enhancements

| Edge | Direction | Enhancement | Properties |
|------|---|---|---|
| **REVIEWED_BY** | Review → Reviewer | #2 | confidence, recency, source |
| **REPRESENTS** | Agent → Tier_Hier | #2 | strength, is_primary |
| **OPERATES_FROM** | Agent → Tier_Location | #2 | title, phone_office, email1, region, city |
| **SIMILAR_TO** | Agent ↔ Agent | #4 | match_type, confidence |
| **WORKS_FOR** | Agent → Company | #7 | (linking only) |

---

## Edges WITHOUT Enhancements

These edges exist but have no new properties:

| Edge | Direction |
|------|---|
| HAS_LOCATION | Tier_Hier → Tier_Location |
| IN_VERTICAL | Agent → Vertical |
| REVIEWED_BY | Agent → Review |
| HAS_SUBVERTICAL | Vertical → Subvertical |
| HAS_SOURCE | Vertical → Source_name |
| FROM_SOURCE | Agent → Source_name |

---

## How to Query All Edges with Enhancements

```cypher
// Show all REVIEWED_BY edges with properties
MATCH (r:Review)-[rel:REVIEWED_BY]->(rev:Reviewer)
RETURN r.id, rel.confidence, rel.recency, rel.source
LIMIT 10

// Show all REPRESENTS edges with properties
MATCH (a:Agent)-[rel:REPRESENTS]->(t:Tier_Hier)
RETURN a.name, rel.strength, rel.is_primary
LIMIT 10

// Show all OPERATES_FROM edges with properties
MATCH (a:Agent)-[rel:OPERATES_FROM]->(l:Tier_Location)
RETURN a.name, rel.title, rel.region, rel.city
LIMIT 10

// Show all SIMILAR_TO edges
MATCH (a:Agent)-[rel:SIMILAR_TO]->(similar:Agent)
RETURN a.name, similar.name, rel.match_type, rel.confidence
LIMIT 10

// Show all WORKS_FOR edges
MATCH (a:Agent)-[rel:WORKS_FOR]->(c:Company)
RETURN a.name, c.name, c.market_tier
LIMIT 10
```

---

## Summary

**3 main enhancements to edges:**

1. **Enhancement 2** (Relationship Properties):
   - REVIEWED_BY: confidence, recency, source
   - REPRESENTS: strength, is_primary
   - OPERATES_FROM: title, phone_office, email1, region, city

2. **Enhancement 4** (Network Insights):
   - SIMILAR_TO: match_type, confidence (pre-built agent similarity)

3. **Enhancement 7** (Company Hierarchy):
   - WORKS_FOR: links agents to company nodes (for aggregation)

**All other enhancements added properties to NODES, not edges.**
