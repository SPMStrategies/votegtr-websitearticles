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

# Read tracking file to get already-generated topics
TRACKING_FILE="$PROJECT_DIR/generated-articles.json"
if [ -f "$TRACKING_FILE" ]; then
    echo -e "${YELLOW}Checking previously generated articles...${NC}"
    GENERATED_TOPICS=$(jq -r '.articles[] | select(.status == "approved" or .status == "published") | "- \(.topic) (\(.segment), \(.generated_date))"' "$TRACKING_FILE")
    if [ -n "$GENERATED_TOPICS" ]; then
        echo -e "${YELLOW}Found $(echo "$GENERATED_TOPICS" | wc -l | tr -d ' ') already-generated topics to avoid${NC}"
    fi
else
    GENERATED_TOPICS=""
    echo -e "${YELLOW}No tracking file found - this will be the first tracked article${NC}"
fi

echo -e "${YELLOW}Calling Claude API to generate article...${NC}"

# Build the prompt content
if [ -n "$GENERATED_TOPICS" ]; then
    EXCLUSION_LIST="

IMPORTANT: The following articles have already been generated and approved. DO NOT generate articles on these topics:
$GENERATED_TOPICS

Choose a DIFFERENT topic from the content gap analysis."
else
    EXCLUSION_LIST=""
fi

PROMPT="You are generating a new article for VOTEGTR.com following the established content workflow.

Your task:
1. Review the content-gap-analysis.md below and identify the next CRITICAL or HIGH priority article from Phase 1 that hasn't been written yet
2. Generate a complete, SEO-optimized article (2,500+ words) following ALL governance documents
3. Follow the brand voice guidelines exactly - write like Sean Murphy, the veteran political consultant
4. Include proper frontmatter with metadata in YAML format
5. Ensure the article meets ALL SEO requirements from seo-writing-guidelines.md
6. Use specific examples and demonstrate E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness)
$EXCLUSION_LIST

=== CONTENT GAP ANALYSIS ===
$CONTENT_GAP

=== SEO WRITING GUIDELINES ===
$SEO_GUIDELINES

=== BRAND VOICE GUIDELINES ===
$BRAND_VOICE

=== SUBJECT SELECTION METHODOLOGY ===
$SUBJECT_SELECTION

=== FACTS ACCURACY REFERENCE ===
$FACTS_REFERENCE

=== RANK MATH SCORING CHECKLIST ===
$RANK_MATH

Generate the complete article now in markdown format with frontmatter. Output ONLY the article content, nothing else."

# Create the API payload using jq for proper JSON escaping
API_PAYLOAD=$(jq -n \
  --arg prompt "$PROMPT" \
  '{
    model: "claude-sonnet-4-20250514",
    max_tokens: 16000,
    messages: [
      {
        role: "user",
        content: $prompt
      }
    ]
  }')

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

# Update tracking file with new article
echo -e "${YELLOW}Updating article tracking...${NC}"
EXTRACTED_SLUG=$(echo "$ARTICLE_CONTENT" | grep "^slug:" | head -1 | sed 's/slug: "\(.*\)"/\1/' | sed "s/slug: '\(.*\)'/\1/" | sed 's/slug: //')
FUNNEL_STAGE=$(echo "$ARTICLE_CONTENT" | grep "^funnel_stage:" | head -1 | sed 's/funnel_stage: "\(.*\)"/\1/' | sed "s/funnel_stage: '\(.*\)'/\1/" | sed 's/funnel_stage: //')
CURRENT_DATE=$(date +%Y-%m-%d)

# Add new article entry to tracking file
TMP_FILE=$(mktemp)
if [ -f "$TRACKING_FILE" ]; then
    # Update existing file
    jq --arg topic "$ARTICLE_TITLE" \
       --arg slug "$EXTRACTED_SLUG" \
       --arg segment "$ARTICLE_SEGMENT" \
       --arg funnel "$FUNNEL_STAGE" \
       --arg date "$CURRENT_DATE" \
       --arg file "$ARTICLE_PATH" \
       --arg wordcount "$ARTICLE_WORDCOUNT" \
       '.articles += [{
         topic: $topic,
         slug: $slug,
         segment: $segment,
         funnel_stage: $funnel,
         generated_date: $date,
         status: "draft",
         file: $file,
         word_count: ($wordcount | tonumber),
         notes: "Auto-generated - pending review"
       }] |
       .metadata.last_updated = $date |
       .metadata.total_generated = (.articles | length)' \
       "$TRACKING_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$ARTICLE_PATH/../generated-articles.json"
else
    # Create new tracking file
    jq -n --arg topic "$ARTICLE_TITLE" \
       --arg slug "$EXTRACTED_SLUG" \
       --arg segment "$ARTICLE_SEGMENT" \
       --arg funnel "$FUNNEL_STAGE" \
       --arg date "$CURRENT_DATE" \
       --arg file "$ARTICLE_PATH" \
       --arg wordcount "$ARTICLE_WORDCOUNT" \
       '{
         articles: [{
           topic: $topic,
           slug: $slug,
           segment: $segment,
           funnel_stage: $funnel,
           generated_date: $date,
           status: "draft",
           file: $file,
           word_count: ($wordcount | tonumber),
           notes: "Auto-generated - pending review"
         }],
         metadata: {
           last_updated: $date,
           total_generated: 1,
           total_approved: 0,
           total_published: 0
         }
       }' > "$TRACKING_FILE"
fi

echo -e "${GREEN}✓ Tracking file updated${NC}"

echo -e "${GREEN}✓ Article generated successfully!${NC}"
echo -e "Title: $ARTICLE_TITLE"
echo -e "Segment: $ARTICLE_SEGMENT"
echo -e "Keyword: $ARTICLE_KEYWORD"
echo -e "Word Count: $ARTICLE_WORDCOUNT"
echo -e "Saved to: $ARTICLE_PATH"
echo -e ""
echo -e "${YELLOW}Next step: Review the article and update status in generated-articles.json${NC}"
