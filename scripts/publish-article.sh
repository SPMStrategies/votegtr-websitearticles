#!/bin/bash

# Publish Article Script
# Usage: ./scripts/publish-article.sh drafts/article-name.md

set -e

# WordPress Configuration
WP_URL="https://votegtr.com"
WP_USER="sean@spmstrategies.com"
WP_PASS="UhVn E9aZ pCoy vvlY 55lb QnWe"
WP_AUTHOR_ID="12"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if file argument provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No article file specified${NC}"
    echo "Usage: ./scripts/publish-article.sh drafts/article-name.md"
    exit 1
fi

ARTICLE_FILE="$1"

# Check if file exists
if [ ! -f "$ARTICLE_FILE" ]; then
    echo -e "${RED}Error: File not found: $ARTICLE_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Publishing Article to WordPress${NC}"
echo "-------------------------------------------"
echo -e "Article: $ARTICLE_FILE"
echo ""

# Read article content
ARTICLE_CONTENT=$(cat "$ARTICLE_FILE")

# Extract frontmatter fields
TITLE=$(echo "$ARTICLE_CONTENT" | grep "^title:" | head -1 | sed 's/title: "\(.*\)"/\1/' | sed "s/title: '\(.*\)'/\1/" | sed 's/title: //' | sed 's/"//g')
SLUG=$(echo "$ARTICLE_CONTENT" | grep "^slug:" | head -1 | sed 's/slug: "\(.*\)"/\1/' | sed "s/slug: '\(.*\)'/\1/" | sed 's/slug: //' | sed 's/"//g')
META_DESC=$(echo "$ARTICLE_CONTENT" | grep "^meta_description:" | head -1 | sed 's/meta_description: "\(.*\)"/\1/' | sed "s/meta_description: '\(.*\)'/\1/" | sed 's/meta_description: //' | sed 's/"//g')
FOCUS_KEYWORD=$(echo "$ARTICLE_CONTENT" | grep "^focus_keyword:" | head -1 | sed 's/focus_keyword: "\(.*\)"/\1/' | sed "s/focus_keyword: '\(.*\)'/\1/" | sed 's/focus_keyword: //' | sed 's/"//g')
SEGMENT=$(echo "$ARTICLE_CONTENT" | grep "^target_segment:" | head -1 | sed 's/target_segment: "\(.*\)"/\1/' | sed "s/target_segment: '\(.*\)'/\1/" | sed 's/target_segment: //' | sed 's/"//g')

echo -e "Title: $TITLE"
echo -e "Slug: $SLUG"
echo -e "Segment: $SEGMENT"
echo ""

# Remove frontmatter
CONTENT_BODY=$(echo "$ARTICLE_CONTENT" | sed '1,/^---$/d' | sed '1,/^---$/d')

# Simple markdown to HTML conversion using pandoc if available, otherwise basic sed
if command -v pandoc &> /dev/null; then
    echo -e "${YELLOW}Converting markdown to HTML using pandoc...${NC}"
    HTML_CONTENT=$(echo "$CONTENT_BODY" | pandoc -f markdown -t html)
else
    echo -e "${YELLOW}Converting markdown to HTML (basic)...${NC}"
    # Basic conversion - headers, paragraphs, bold, italic
    HTML_CONTENT=$(echo "$CONTENT_BODY" | \
        sed 's/^### \(.*\)/<h3>\1<\/h3>/' | \
        sed 's/^## \(.*\)/<h2>\1<\/h2>/' | \
        sed 's/^# \(.*\)/<h1>\1<\/h1>/' | \
        sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' | \
        sed 's/\*\([^*]*\)\*/<em>\1<\/em>/g' | \
        awk 'BEGIN{in_para=0}
             /^<h[1-6]>/ {if(in_para){print "</p>"; in_para=0} print; next}
             /^$/ {if(in_para){print "</p>"; in_para=0} next}
             {if(!in_para){printf "<p>"; in_para=1} print}
             END{if(in_para) print "</p>"}')
fi

# Determine category based on segment
CATEGORY_ID="43"  # Default: Website Tips
case "$SEGMENT" in
    "Consultants") CATEGORY_ID="42" ;;  # Campaign Strategy
    "Candidates") CATEGORY_ID="43" ;;   # Website Tips
    "Party Chairs") CATEGORY_ID="42" ;; # Campaign Strategy
esac

echo -e "${YELLOW}Uploading to WordPress...${NC}"

# Create JSON payload
PAYLOAD=$(jq -n \
    --arg title "$TITLE" \
    --arg content "$HTML_CONTENT" \
    --arg slug "$SLUG" \
    --arg excerpt "$META_DESC" \
    --arg meta_title "$TITLE | VOTEGTR" \
    --arg meta_desc "$META_DESC" \
    --arg keyword "$FOCUS_KEYWORD" \
    --argjson category "$CATEGORY_ID" \
    --argjson author "$WP_AUTHOR_ID" \
    '{
        title: $title,
        content: $content,
        status: "draft",
        slug: $slug,
        categories: [$category],
        author: $author,
        excerpt: $excerpt,
        meta: {
            rank_math_title: $meta_title,
            rank_math_description: $meta_desc,
            rank_math_focus_keyword: $keyword
        }
    }')

# Upload to WordPress
RESPONSE=$(curl -s -X POST "$WP_URL/wp-json/wp/v2/posts" \
    --user "$WP_USER:$WP_PASS" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

# Check for WordPress post ID
WP_POST_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -n "$WP_POST_ID" ] && [ "$WP_POST_ID" != "null" ]; then
    echo -e "${GREEN}✓ Successfully uploaded to WordPress!${NC}"
    echo -e "  WordPress ID: $WP_POST_ID"
    echo -e "  Edit URL: ${YELLOW}$WP_URL/wp-admin/post.php?post=$WP_POST_ID&action=edit${NC}"
    echo -e "  Preview URL: $WP_URL/?p=$WP_POST_ID&preview=true"
    echo ""

    # Move article to ready-to-publish folder
    READY_DIR="ready-to-publish"
    FILENAME=$(basename "$ARTICLE_FILE")

    if [ ! -d "$READY_DIR" ]; then
        mkdir -p "$READY_DIR"
    fi

    mv "$ARTICLE_FILE" "$READY_DIR/$FILENAME"
    echo -e "${GREEN}✓ Moved article to $READY_DIR/$FILENAME${NC}"
    echo ""

    # Commit and push to GitHub
    echo -e "${YELLOW}Pushing changes to GitHub...${NC}"
    git add "$READY_DIR/$FILENAME"
    git add "$ARTICLE_FILE" 2>/dev/null || true  # Remove from drafts
    git commit -m "Publish article: $TITLE

Published to WordPress as draft (ID: $WP_POST_ID)
Edit URL: $WP_URL/wp-admin/post.php?post=$WP_POST_ID&action=edit"

    git push

    echo -e "${GREEN}✓ Changes pushed to GitHub${NC}"
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Article published successfully!${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "1. Review in WordPress: ${YELLOW}$WP_URL/wp-admin/post.php?post=$WP_POST_ID&action=edit${NC}"
    echo -e "2. Add images if needed"
    echo -e "3. Click 'Publish' in WordPress when ready"

else
    echo -e "${RED}Error: Failed to upload to WordPress${NC}"
    echo "Response: $RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
    exit 1
fi
