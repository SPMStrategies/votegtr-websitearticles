#!/bin/bash

# Daily Article Generation Script for VOTEGTR
# This script uses Claude API to generate a new article based on the content priority queue

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/automation.json"
CALENDAR_FILE="$PROJECT_DIR/content-gap-analysis.md"
DRAFTS_DIR="$PROJECT_DIR/drafts"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting VOTEGTR Daily Article Generation${NC}"
echo "-------------------------------------------"

# Check if Claude API key is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}Error: ANTHROPIC_API_KEY environment variable is not set${NC}"
    echo "Please set your Claude API key as an environment variable or GitHub Secret"
    exit 1
fi

# Read the next article from priority queue
# This will be extracted from content-gap-analysis.md
echo -e "${YELLOW}Selecting next article from priority queue...${NC}"

# For this script, we'll use the Claude API to:
# 1. Read the content-gap-analysis.md to determine next article
# 2. Read all governance documents
# 3. Generate the article
# 4. Save to drafts directory

# Create a temporary prompt file
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" <<'EOF'
You are generating a new article for VOTEGTR.com following the established content workflow.

Your task:
1. Read content-gap-analysis.md and identify the next highest-priority article that hasn't been written yet
2. Read all governance documents to understand requirements:
   - content-subject-selection-methodology.md
   - seo-writing-guidelines.md
   - votegtr-brand-voice-guidelines.md
   - votegtr-facts-accuracy-reference.md
   - rank-math-scoring-checklist.md
3. Generate a complete, SEO-optimized article following all guidelines
4. Output ONLY the article content in markdown format
5. Include proper frontmatter with metadata

Please generate the article now.
EOF

# Note: This is a simplified version. In production, you would:
# 1. Use Claude API to read files and generate content
# 2. Parse the response and save to drafts
# 3. Update the content calendar

echo -e "${YELLOW}Calling Claude API to generate article...${NC}"
echo "This would normally call the Claude API with all governance documents"
echo "For now, this is a template script that needs API integration"

# Placeholder for actual API call
# ARTICLE_CONTENT=$(curl https://api.anthropic.com/v1/messages \
#   -H "x-api-key: $ANTHROPIC_API_KEY" \
#   -H "anthropic-version: 2023-06-01" \
#   -H "content-type: application/json" \
#   -d @api-payload.json)

# For now, create a placeholder
ARTICLE_SLUG="generated-article-$(date +%Y%m%d)"
ARTICLE_PATH="$DRAFTS_DIR/$ARTICLE_SLUG.md"

echo -e "${GREEN}Article generation would be complete${NC}"
echo "Article would be saved to: $ARTICLE_PATH"

# Cleanup
rm -f "$PROMPT_FILE"

# Export variables for notification script
export ARTICLE_TITLE="Generated Article Title"
export ARTICLE_SLUG="$ARTICLE_SLUG"
export ARTICLE_PATH="$ARTICLE_PATH"
export ARTICLE_SEGMENT="TBD"
export ARTICLE_KEYWORD="TBD"
export ARTICLE_WORDCOUNT="2500"

echo -e "${GREEN}✓ Article generation script completed${NC}"
