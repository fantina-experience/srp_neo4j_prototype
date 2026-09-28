// Neo4j Schema for SRP Prototype
// Run these in Neo4j Browser to create constraints and indexes

// Create Constraints (unique identifiers for each node type)
CREATE CONSTRAINT agent_id IF NOT EXISTS FOR (a:Agent) REQUIRE a.id IS UNIQUE;
CREATE CONSTRAINT tier_id IF NOT EXISTS FOR (t:Tier_Hier) REQUIRE t.id IS UNIQUE;
CREATE CONSTRAINT tier_location_id IF NOT EXISTS FOR (tl:Tier_Location) REQUIRE tl.id IS UNIQUE;
CREATE CONSTRAINT vertical_id IF NOT EXISTS FOR (v:Vertical) REQUIRE v.id IS UNIQUE;
CREATE CONSTRAINT reviewer_name IF NOT EXISTS FOR (rev:Reviewer) REQUIRE rev.name IS UNIQUE;

// Create Indexes for faster queries
CREATE INDEX agent_vertical IF NOT EXISTS FOR (a:Agent) ON (a.vertical);
CREATE INDEX agent_name IF NOT EXISTS FOR (a:Agent) ON (a.name);
CREATE INDEX agent_city IF NOT EXISTS FOR (a:Agent) ON (a.city);
CREATE INDEX tier_vertical IF NOT EXISTS FOR (t:Tier_Hier) ON (t.vertical);
CREATE INDEX tier_location_city IF NOT EXISTS FOR (tl:Tier_Location) ON (tl.city);
