# Enhancements by Edge: Complete Mapping

---

## Edge 1: REVIEWED_BY (Review → Reviewer)

**Enhancement #2: Relationship Properties**

**Properties Added:**
```
REVIEWED_BY {
  confidence: 'high' | 'medium' | 'low',
  recency: number (months),
  source: string
}
```

**Cypher Code (Lines 373-382):**
```cypher
MATCH (r:Review)-[rel:REVIEWED_BY]->(rev:Reviewer)
SET rel.confidence = CASE 
  WHEN rel.rating >= 4 THEN 'high'
  WHEN rel.rating >= 3 THEN 'medium'
  ELSE 'low'
END,
rel.recency = duration.inMonths(date(r.review_date), date()).months
```

**Example Query:**
```cypher
MATCH (r:Review)-[rel:REVIEWED_BY]->(rev:Reviewer)
RETURN r.id, rev.name, rel.confidence, rel.recency
```

**Example Result:**
```
r.id | rev.name   | rel.confidence | rel.recency
─────────────────────────────────────────────
123  | John Smith | high           | 5
124  | Jane Doe   | medium         | 12
```

---

## Edge 2: REPRESENTS (Agent → Tier_Hier)

**Enhancement #2: Relationship Properties**

**Properties Added:**
```
REPRESENTS {
  priority: number,
  is_primary: true | false
}
```

**Cypher Code (Lines 388-393):**
```cypher
MATCH (a:Agent)-[r:REPRESENTS]->(tier:Tier_Hier)
SET r.priority = COALESCE(tier.priority, 1),
    r.is_primary = CASE WHEN tier.priority = 100 THEN true ELSE false END
```

**Example Query:**
```cypher
MATCH (a:Agent)-[rel:REPRESENTS]->(t:Tier_Hier)
RETURN a.name, t.tier_name, rel.priority, rel.is_primary
```

**Example Result:**
```
a.name          | t.tier_name | rel.priority | rel.is_primary
──────────────────────────────────────────────────────────
Anthony Grech   | Primary     | 100          | true
Grace Zhao      | Secondary   | 50           | false
Ashley Shammami | Primary     | 100          | true
```

---

## Edge 3: OPERATES_FROM (Agent → Tier_Location)

**Enhancement #2: Relationship Properties**

**Properties Added:**
```
OPERATES_FROM {
  title: string,
  phone_office: string,
  email1: string,
  region: string,
  city: string,
  years_of_experience: number
}
```

**Cypher Code (Lines 400-405):**
```cypher
MATCH (a:Agent)-[r:OPERATES_FROM]->(loc:Tier_Location)
SET r.region = COALESCE(loc.state, 'Unknown'),
    r.city = loc.city,
    r.years_of_experience = a.years_of_experience
```

**Note:** `title`, `phone_office`, `email1` are added earlier during relationship creation (lines 243-245)

**Example Query:**
```cypher
MATCH (a:Agent)-[rel:OPERATES_FROM]->(l:Tier_Location)
RETURN a.name, l.city, rel.title, rel.years_of_experience, rel.region
```

**Example Result:**
```
a.name          | l.city  | rel.title              | rel.years_of_experience | rel.region
────────────────────────────────────────────────────────────────────────────────────
Anthony Grech   | Detroit | Senior Loan Officer    | 15                      | MI
Grace Zhao      | Chicago | Loan Processor         | 8                       | IL
Ashley Shammami | Phoenix | Branch Manager         | 12                      | AZ
```

---

## Edge 4: SIMILAR_TO (Agent ↔ Agent, bidirectional)

**Enhancement #4: Network Insights**

**Properties Added:**
```
SIMILAR_TO {
  match_type: 'same_tier' | 'same_market',
  confidence: 0.8 | 0.95
}
```

### Type 4a: SIMILAR_TO (same_tier)

**Cypher Code (Lines 463-469):**
```cypher
MATCH (a1:Agent)-[:REPRESENTS]->(tier:Tier_Hier)<-[:REPRESENTS]-(a2:Agent)
WHERE a1.id < a2.id
MERGE (a1)-[r:SIMILAR_TO]-(a2)
SET r.match_type = 'same_tier',
    r.confidence = 0.8
```

**Example Query:**
```cypher
MATCH (a:Agent {name: 'Anthony Grech'})-[rel:SIMILAR_TO {match_type: 'same_tier'}]->(similar:Agent)
RETURN similar.name, rel.confidence
```

**Example Result:**
```
similar.name   | rel.confidence
──────────────────────────────
Grace Zhao     | 0.8
Adam Masood    | 0.8
```

### Type 4b: SIMILAR_TO (same_market)

**Cypher Code (Lines 477-483):**
```cypher
MATCH (a1:Agent)-[:IN_VERTICAL]->(v:Vertical)<-[:IN_VERTICAL]-(a2:Agent),
      (a1)-[:OPERATES_FROM]->(l:Tier_Location)<-[:OPERATES_FROM]-(a2)
WHERE a1.id < a2.id
MERGE (a1)-[r:SIMILAR_TO]-(a2)
SET r.match_type = 'same_market',
    r.confidence = 0.95
```

**Example Query:**
```cypher
MATCH (a:Agent {name: 'Anthony Grech'})-[rel:SIMILAR_TO {match_type: 'same_market'}]->(similar:Agent)
RETURN similar.name, rel.confidence
```

**Example Result:**
```
similar.name   | rel.confidence
──────────────────────────────
Ashley Shammami| 0.95
```

---

## Edge 5: WORKS_FOR (Agent → Company)

**Enhancement #7: Company Hierarchy**

**Properties Added:**
```
WORKS_FOR {
  (no edge properties, used for aggregation)
}
```

**Cypher Code (Lines 562-567):**
```cypher
MATCH (a:Agent)
WHERE a.company_name IS NOT NULL
MATCH (c:Company {name: a.company_name})
MERGE (a)-[:WORKS_FOR]->(c)
```

**Example Query:**
```cypher
MATCH (a:Agent)-[rel:WORKS_FOR]->(c:Company)
RETURN a.name, c.name, c.market_tier
```

**Example Result:**
```
a.name          | c.name                      | c.market_tier
──────────────────────────────────────────────────────────
Anthony Grech   | CrossCountry Mortgage, LLC  | small_business
Grace Zhao      | CrossCountry Mortgage, LLC  | small_business
Ashley Shammami | Loan Depot                  | small_business
```

---

## Edges WITHOUT Enhancements

These edges exist but have NO properties added:

| Edge | Direction | Status |
|------|---|---|
| HAS_LOCATION | Tier_Hier → Tier_Location | No enhancement |
| IN_VERTICAL | Agent → Vertical | No enhancement |
| REVIEWED_BY | Agent → Review | No enhancement |
| HAS_SUBVERTICAL | Vertical → Subvertical | No enhancement |
| HAS_SOURCE | Vertical → Source_name | No enhancement |
| FROM_SOURCE | Agent → Source_name | No enhancement |

---

## Summary Table: All Edges with Enhancements

| Edge | Type | Enhancement | Properties | Lines | Status |
|------|------|---|---|---|---|
| **REVIEWED_BY** | Review → Reviewer | #2 | confidence, recency, source | 373-382 | ✅ 172 edges |
| **REPRESENTS** | Agent → Tier_Hier | #2 | priority, is_primary | 388-393 | ✅ 100 edges |
| **OPERATES_FROM** | Agent → Location | #2 | title, phone_office, email1, region, city, years_of_experience | 243-245, 400-405 | ✅ 100 edges |
| **SIMILAR_TO** | Agent ↔ Agent | #4 | match_type, confidence | 463-483 | ✅ 134 edges |
| **WORKS_FOR** | Agent → Company | #7 | (aggregation only) | 562-567 | ✅ 100 edges |

---

## File Locations in Loader

**File:** `/Users/fantina/Desktop/srp_prototype/scripts/neo4j_loader.py`

| Enhancement | Edge | Lines | Section |
|---|---|---|---|
| #2 | REVIEWED_BY | 373-382 | Enhancement 2 |
| #2 | REPRESENTS | 388-393 | Enhancement 2 |
| #2 | OPERATES_FROM | 400-405 | Enhancement 2 |
| #4 | SIMILAR_TO | 458-486 | Enhancement 4 |
| #7 | WORKS_FOR | 562-567 | Enhancement 7 |

---

## Quick Reference: Find Enhancement Code

**To find where an enhancement is coded:**

1. **REVIEWED_BY properties** → Line 373-382
2. **REPRESENTS properties** → Line 388-393
3. **OPERATES_FROM properties** → Line 400-405
4. **SIMILAR_TO creation** → Line 458-486
5. **WORKS_FOR creation** → Line 562-567

**All in: `/Users/fantina/Desktop/srp_prototype/scripts/neo4j_loader.py`**
