#!/bin/bash

# Daily Article Generation Script for VOTEGTR
# This script uses Claude API to generate a new article based on the content priority queue

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
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

echo -e "${YELLOW}Reading governance documents...${NC}"

# Read all governance documents
CONTENT_GAP=$(cat "$PROJECT_DIR/content-gap-analysis.md")
SEO_GUIDELINES=$(cat "$PROJECT_DIR/seo-writing-guidelines.md")
BRAND_VOICE=$(cat "$PROJECT_DIR/votegtr-brand-voice-guidelines.md")
SUBJECT_SELECTION=$(cat "$PROJECT_DIR/content-subject-selection-methodology.md")
FACTS_REFERENCE=$(cat "$PROJECT_DIR/votegtr-facts-accuracy-reference.md")
RANK_MATH=$(cat "$PROJECT_DIR/rank-math-scoring-checklist.md")

echo -e "${YELLOW}Calling Claude API to generate article...${NC}"

# Create the API payload
API_PAYLOAD=$(cat <<EOF
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 16000,
  "messages": [
    {
      "role": "user",
      "content": "You are generating a new article for VOTEGTR.com following the established content workflow.\n\nYour task:\n1. Review the content-gap-analysis.md below and identify the next CRITICAL or HIGH priority article from Phase 1 that hasn't been written yet\n2. Generate a complete, SEO-optimized article (2,500+ words) following ALL governance documents\n3. Follow the brand voice guidelines exactly - write like Sean Murphy, the veteran political consultant\n4. Include proper frontmatter with metadata in YAML format\n5. Ensure the article meets ALL SEO requirements from seo-writing-guidelines.md\n6. Use specific examples and demonstrate E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness)\n\n=== CONTENT GAP ANALYSIS ===\n${CONTENT_GAP}\n\n=== SEO WRITING GUIDELINES ===\n${SEO_GUIDELINES}\n\n=== BRAND VOICE GUIDELINES ===\n${BRAND_VOICE}\n\n=== SUBJECT SELECTION METHODOLOGY ===\n${SUBJECT_SELECTION}\n\n=== FACTS ACCURACY REFERENCE ===\n${FACTS_REFERENCE}\n\n=== RANK MATH SCORING CHECKLIST ===\n${RANK_MATH}\n\nGenerate the complete article now in markdown format with frontmatter. Output ONLY the article content, nothing else."
    }
  ]
}
EOF
)

# Call Claude API
RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "$API_PAYLOAD")

# Extract the article content from the response
ARTICLE_CONTENT=$(echo "$RESPONSE" | jq -r '.content[0].text' 2>/dev/null)

# Check if we got a valid response
if [ -z "$ARTICLE_CONTENT" ] || [ "$ARTICLE_CONTENT" = "null" ]; then
    echo -e "${RED}Error: Failed to generate article from Claude API${NC}"
    echo "API Response: $RESPONSE"
    exit 1
fi

# Generate unique filename with timestamp to avoid duplicates
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARTICLE_SLUG="generated-article-$TIMESTAMP"
ARTICLE_PATH="$DRAFTS_DIR/$ARTICLE_SLUG.md"

# Save the article
echo "$ARTICLE_CONTENT" > "$ARTICLE_PATH"

# Extract metadata from frontmatter for notifications
ARTICLE_TITLE=$(echo "$ARTICLE_CONTENT" | grep "^title:" | head -1 | sed 's/title: "\(.*\)"/\1/' | sed "s/title: '\(.*\)'/\1/" | sed 's/title: //')
ARTICLE_SEGMENT=$(echo "$ARTICLE_CONTENT" | grep "^segment:" | head -1 | sed 's/segment: "\(.*\)"/\1/' | sed "s/segment: '\(.*\)'/\1/" | sed 's/segment: //')
ARTICLE_KEYWORD=$(echo "$ARTICLE_CONTENT" | grep "^target_keyword:" | head -1 | sed 's/target_keyword: "\(.*\)"/\1/' | sed "s/target_keyword: '\(.*\)'/\1/" | sed 's/target_keyword: //')
ARTICLE_WORDCOUNT=$(echo "$ARTICLE_CONTENT" | wc -w | tr -d ' ')

# Export variables for notification script and GitHub Actions
export ARTICLE_TITLE="${ARTICLE_TITLE:-Generated Article}"
export ARTICLE_SLUG="$ARTICLE_SLUG"
export ARTICLE_PATH="$ARTICLE_PATH"
export ARTICLE_SEGMENT="${ARTICLE_SEGMENT:-General}"
export ARTICLE_KEYWORD="${ARTICLE_KEYWORD:-campaign website}"
export ARTICLE_WORDCOUNT="$ARTICLE_WORDCOUNT"

# Also write to GITHUB_ENV if running in GitHub Actions
if [ -n "$GITHUB_ENV" ]; then
    echo "ARTICLE_TITLE=$ARTICLE_TITLE" >> "$GITHUB_ENV"
    echo "ARTICLE_SLUG=$ARTICLE_SLUG" >> "$GITHUB_ENV"
    echo "ARTICLE_PATH=$ARTICLE_PATH" >> "$GITHUB_ENV"
    echo "ARTICLE_SEGMENT=$ARTICLE_SEGMENT" >> "$GITHUB_ENV"
    echo "ARTICLE_KEYWORD=$ARTICLE_KEYWORD" >> "$GITHUB_ENV"
    echo "ARTICLE_WORDCOUNT=$ARTICLE_WORDCOUNT" >> "$GITHUB_ENV"
fi

echo -e "${GREEN}✓ Article generated successfully!${NC}"
echo -e "Title: $ARTICLE_TITLE"
echo -e "Segment: $ARTICLE_SEGMENT"
echo -e "Keyword: $ARTICLE_KEYWORD"
echo -e "Word Count: $ARTICLE_WORDCOUNT"
echo -e "Saved to: $ARTICLE_PATH"
