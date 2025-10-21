#!/bin/bash

# Email Notification Script for VOTEGTR Article Review
# Sends an email notification when a new article is ready for review

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/automation.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Sending article review notification${NC}"

# Read recipient email from config (or use environment variable)
RECIPIENT_EMAIL="${NOTIFICATION_EMAIL:-sean@spmstrategies.com}"

# Article metadata (should be set by generate-daily-article.sh)
ARTICLE_TITLE="${ARTICLE_TITLE:-New Article}"
ARTICLE_SLUG="${ARTICLE_SLUG:-article}"
ARTICLE_PATH="${ARTICLE_PATH:-drafts/article.md}"
ARTICLE_SEGMENT="${ARTICLE_SEGMENT:-General}"
ARTICLE_KEYWORD="${ARTICLE_KEYWORD:-keyword}"
ARTICLE_WORDCOUNT="${ARTICLE_WORDCOUNT:-2500}"

# GitHub repo info
GITHUB_REPO="${GITHUB_REPOSITORY:-SPMStrategies/votegtr-websitearticles}"
GITHUB_BRANCH="${GITHUB_REF_NAME:-main}"
GITHUB_FILE_URL="https://github.com/$GITHUB_REPO/blob/$GITHUB_BRANCH/$ARTICLE_PATH"

# Email subject and body
EMAIL_SUBJECT="📝 New VOTEGTR Article Ready for Review: $ARTICLE_TITLE"

EMAIL_BODY="<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #0066cc; color: white; padding: 20px; border-radius: 5px; }
        .content { background-color: #f4f4f4; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .metadata { background-color: white; padding: 15px; border-left: 4px solid #0066cc; }
        .metadata-item { margin: 8px 0; }
        .metadata-label { font-weight: bold; color: #0066cc; }
        .button { display: inline-block; padding: 12px 24px; background-color: #0066cc; color: white; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
        .footer { color: #666; font-size: 12px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; }
    </style>
</head>
<body>
    <div class=\"container\">
        <div class=\"header\">
            <h2>✅ New Article Generated</h2>
        </div>

        <div class=\"content\">
            <h3>$ARTICLE_TITLE</h3>

            <div class=\"metadata\">
                <div class=\"metadata-item\">
                    <span class=\"metadata-label\">Segment:</span> $ARTICLE_SEGMENT
                </div>
                <div class=\"metadata-item\">
                    <span class=\"metadata-label\">Target Keyword:</span> $ARTICLE_KEYWORD
                </div>
                <div class=\"metadata-item\">
                    <span class=\"metadata-label\">Word Count:</span> ~$ARTICLE_WORDCOUNT words
                </div>
                <div class=\"metadata-item\">
                    <span class=\"metadata-label\">File:</span> $ARTICLE_PATH
                </div>
                <div class=\"metadata-item\">
                    <span class=\"metadata-label\">Generated:</span> $(date '+%B %d, %Y at %I:%M %p %Z')
                </div>
            </div>

            <div style=\"margin-top: 20px;\">
                <a href=\"$GITHUB_FILE_URL\" class=\"button\">📄 View on GitHub</a>
            </div>
        </div>

        <div style=\"margin: 20px 0; padding: 15px; background-color: #fff3cd; border-left: 4px solid #ffc107; border-radius: 5px;\">
            <strong>Next Steps:</strong>
            <ol style=\"margin: 10px 0;\">
                <li>Review the article on GitHub</li>
                <li>Reply with \"Approved\" or provide revision feedback</li>
                <li>After approval, article will be uploaded to WordPress as a draft</li>
            </ol>
        </div>

        <div class=\"footer\">
            <p>This is an automated notification from the VOTEGTR Content Generation System.</p>
            <p>Repository: <a href=\"https://github.com/$GITHUB_REPO\">$GITHUB_REPO</a></p>
        </div>
    </div>
</body>
</html>"

# Send email based on available method
# Method 1: Using sendmail (if available locally)
if command -v sendmail &> /dev/null; then
    echo -e "${YELLOW}Sending via sendmail...${NC}"
    (
        echo "To: $RECIPIENT_EMAIL"
        echo "Subject: $EMAIL_SUBJECT"
        echo "Content-Type: text/html; charset=UTF-8"
        echo ""
        echo "$EMAIL_BODY"
    ) | sendmail -t
    echo -e "${GREEN}✓ Email sent via sendmail${NC}"

# Method 2: Using SMTP with curl (requires SMTP credentials)
elif [ -n "$SMTP_SERVER" ] && [ -n "$SMTP_USERNAME" ] && [ -n "$SMTP_PASSWORD" ]; then
    echo -e "${YELLOW}Sending via SMTP...${NC}"

    EMAIL_FILE=$(mktemp)
    cat > "$EMAIL_FILE" <<EMAILEOF
From: VOTEGTR Content System <$SMTP_USERNAME>
To: $RECIPIENT_EMAIL
Subject: $EMAIL_SUBJECT
Content-Type: text/html; charset=UTF-8

$EMAIL_BODY
EMAILEOF

    curl --ssl-reqd \
        --url "smtp://$SMTP_SERVER:${SMTP_PORT:-587}" \
        --user "$SMTP_USERNAME:$SMTP_PASSWORD" \
        --mail-from "$SMTP_USERNAME" \
        --mail-rcpt "$RECIPIENT_EMAIL" \
        --upload-file "$EMAIL_FILE"

    rm -f "$EMAIL_FILE"
    echo -e "${GREEN}✓ Email sent via SMTP${NC}"

# Method 3: GitHub Actions has a mail action we can use
elif [ -n "$GITHUB_ACTIONS" ]; then
    echo -e "${YELLOW}Running in GitHub Actions - email will be sent via workflow action${NC}"
    # The GitHub Actions workflow will handle this using dawidd6/action-send-mail

    # Save email content for the action to use
    echo "$EMAIL_SUBJECT" > /tmp/email_subject.txt
    echo "$EMAIL_BODY" > /tmp/email_body.html
    echo -e "${GREEN}✓ Email content prepared for GitHub Actions${NC}"

else
    echo -e "${RED}Warning: No email sending method available${NC}"
    echo "Please configure one of the following:"
    echo "  - sendmail (local)"
    echo "  - SMTP credentials (SMTP_SERVER, SMTP_USERNAME, SMTP_PASSWORD)"
    echo "  - GitHub Actions workflow with email action"
    echo ""
    echo "Email content:"
    echo "To: $RECIPIENT_EMAIL"
    echo "Subject: $EMAIL_SUBJECT"
    echo ""
    echo "Article Details:"
    echo "  Title: $ARTICLE_TITLE"
    echo "  Segment: $ARTICLE_SEGMENT"
    echo "  Keyword: $ARTICLE_KEYWORD"
    echo "  Word Count: $ARTICLE_WORDCOUNT"
    echo "  Path: $ARTICLE_PATH"
    echo "  GitHub URL: $GITHUB_FILE_URL"
fi

echo -e "${GREEN}Notification process complete${NC}"
