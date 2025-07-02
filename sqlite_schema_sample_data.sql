-- SQLite schema for document authoring system
-- Supports documents, extracted sections, tagging, workspace, and proposal generation

PRAGMA foreign_keys = ON;

-- Users table (optional for multi-user systems)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- Documents table
CREATE TABLE IF NOT EXISTS documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT NOT NULL,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    uploaded_by TEXT,
    status TEXT DEFAULT 'processing',
    source_url TEXT,
    deleted BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

-- Document metadata table
CREATE TABLE IF NOT EXISTS document_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    industry TEXT,
    source_system TEXT,
    document_type TEXT,
    language TEXT,
    summary TEXT,
    author TEXT,
    tags TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id)
);

-- Content sections extracted from documents
CREATE TABLE IF NOT EXISTS content_sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    title TEXT,
    content TEXT,
    page_number INTEGER,
    word_count INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id)
);

-- Tags master table
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, category)
);

-- Section-tags many-to-many relationship
CREATE TABLE IF NOT EXISTS section_tags (
    section_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (section_id, tag_id),
    FOREIGN KEY (section_id) REFERENCES content_sections(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Workspace items
CREATE TABLE IF NOT EXISTS workspace_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INTEGER NOT NULL,
    user_id TEXT,
    custom_notes TEXT,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT 0,
    FOREIGN KEY (section_id) REFERENCES content_sections(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Proposal sections
CREATE TABLE IF NOT EXISTS proposal_sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    name TEXT NOT NULL,
    content TEXT,
    prompt_template TEXT,
    last_generated DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================
-- Sample Data Inserts
-- =============================

INSERT INTO users (id, name) VALUES
  ('user-123', 'Alice Johnson');

INSERT INTO documents (file_name, uploaded_by, status) VALUES
  ('sample_proposal.pdf', 'user-123', 'completed'),
  ('market_analysis.docx', 'user-123', 'completed');

INSERT INTO document_metadata (document_id, industry, source_system, document_type, language, summary, author, tags) VALUES
  (1, 'Financial Services', 'WebScraper', 'Proposal', 'en', 'Proposal summary content', 'Alice Johnson', '"strategy,innovation"'),
  (2, 'Retail', 'SharePoint', 'Market Research', 'en', 'Market trends and growth analysis', 'Research Team', '"ecommerce,trends"');

INSERT INTO content_sections (document_id, title, content, page_number, word_count) VALUES
  (1, 'Executive Summary', 'This is the executive summary of the proposal...', 1, 120),
  (1, 'Service Offerings', 'We offer data analytics and cloud migration...', 2, 220),
  (2, 'Consumer Trends', 'Latest retail trends include...', 1, 180);

INSERT INTO tags (name, category) VALUES
  ('Cloud', 'capability'),
  ('Retail', 'industry'),
  ('Summary', 'section');

INSERT INTO section_tags (section_id, tag_id) VALUES
  (1, 3),
  (2, 1),
  (3, 2);

INSERT INTO workspace_items (section_id, user_id, custom_notes) VALUES
  (1, 'user-123', 'Include this in intro'),
  (2, 'user-123', NULL);

INSERT INTO proposal_sections (user_id, name, content, prompt_template, last_generated) VALUES
  ('user-123', 'About Us', 'Generated content about company...', 'Summarize our core values', CURRENT_TIMESTAMP);
