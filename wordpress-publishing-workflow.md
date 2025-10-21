# WordPress Publishing Workflow

## Overview

This document outlines the automated workflow for publishing VOTEGTR content to WordPress. The AI creates articles, you approve them, and they're automatically uploaded as WordPress drafts for final human review before publishing.

**Last Updated**: October 20, 2025

---

## Workflow Summary

```
1. AI drafts article → /drafts/
2. You review & approve
3. AI moves to /ready-to-publish/
4. AI uploads to WordPress as DRAFT
5. Human assistant reviews in WordPress
6. Human publishes when ready
7. AI archives to /published/
```

---

## Detailed Workflow

### Phase 1: Content Creation (AI)

**AI Actions:**
1. Select topic from approved content calendar
2. Reference vault repository for segment messaging
3. Draft article following SEO guidelines
4. Save to `/drafts/[article-slug].md`
5. Notify you: "New article ready for review: [Title]"

**File Location**: `/drafts/article-name.md`

**Notification Format:**
```
📝 New Article Ready for Review

Title: How to Accept Campaign Donations Online
Segment: Candidates
Target Keyword: campaign donations online
Word Count: 2,150
Status: Awaiting your review in /drafts/

Review at: /Users/Sean/VOTEGTR-WebsiteArticles/drafts/accept-campaign-donations-online.md
```

---

### Phase 2: Your Review & Approval

**Your Actions:**
1. Open draft file in `/drafts/`
2. Review content for:
   - Messaging alignment with vault
   - Accuracy of VOTEGTR features/pricing
   - Segment appropriateness
   - CTA effectiveness
   - Overall quality

**Decision Options:**

**Option A: Approve**
- Tell AI: "Approved" or "Approve [article name]"
- AI proceeds to Phase 3

**Option B: Request Revisions**
- Tell AI specific changes needed
- AI revises and saves updated draft
- Review again

**Option C: Reject**
- Tell AI: "Reject [article name]"
- AI archives to `/rejected/` (if needed)
- Topic goes back to calendar for reconsideration

---

### Phase 3: WordPress Upload (AI - Automated)

**AI Actions:**
1. Move approved article from `/drafts/` to `/ready-to-publish/`
2. Convert markdown to WordPress HTML
3. Upload to WordPress via REST API with:

**Note for articles 2,500+ words:** AI will convert the full markdown to HTML and save to a temp file, then use WordPress REST API to update the post content in a separate call after initial post creation. This ensures full article content is uploaded automatically regardless of length.

**Standard upload includes:**
   - **Status**: Draft (not published)
   - **Title**: SEO-optimized title
   - **Content**: Full HTML formatted article
   - **Meta Title**: SEO title tag (Rank Math)
   - **Meta Description**: SEO description (Rank Math)
   - **Focus Keyword**: Primary keyword (Rank Math)
   - **URL Slug**: SEO-friendly slug
   - **Category**: Assigned based on topic
   - **Author**: Sean Murphy (ID: 12)
   - **Excerpt**: Auto-generated or custom

4. Return WordPress draft information:
   - Draft ID
   - Edit URL (for human assistant)
   - Preview URL
   - Category assigned

**Example Output:**
```
✅ Article Uploaded to WordPress

Title: How to Accept Campaign Donations Online
WordPress ID: 2156
Status: Draft
Category: Fundraising
Edit URL: https://votegtr.com/wp-admin/post.php?post=2156&action=edit
Preview URL: https://votegtr.com/?p=2156&preview=true

Ready for human review and publishing.
```

---

### Phase 4: Human Review in WordPress

**Human Assistant Actions:**

1. **Access Draft**:
   - Click Edit URL or go to WordPress → Posts → Drafts
   - Open the draft article

2. **Review Checklist**:
   - [ ] Content displays correctly (no formatting issues)
   - [ ] Internal links work properly
   - [ ] Headings hierarchy looks good
   - [ ] Meta title and description populated (Rank Math)
   - [ ] Focus keyword set (Rank Math)
   - [ ] Category correct
   - [ ] Excerpt appropriate
   - [ ] URL slug clean and keyword-rich

3. **Add Images** (Optional for now):
   - [ ] Featured image (if available)
   - [ ] Inline images (if created)
   - [ ] Alt text on all images
   - [ ] Proper image sizing

4. **Final Adjustments**:
   - Make any minor formatting tweaks
   - Adjust spacing if needed
   - Verify mobile preview looks good

5. **Publish Decision**:
   - **Publish Now**: Click "Publish" button
   - **Schedule**: Set future publish date/time
   - **More Revisions Needed**: Leave as draft, request AI changes

---

### Phase 5: Post-Publishing (AI)

**After Human Publishes:**

**AI Actions:**
1. Move article from `/ready-to-publish/` to `/published/`
2. Rename file to include publish date: `2025-10-20-accept-campaign-donations-online.md`
3. Update content calendar with:
   - Publish date
   - Live URL
   - WordPress post ID
   - Performance tracking initiated

4. Add frontmatter to published file:
```markdown
---
title: How to Accept Campaign Donations Online
published_date: 2025-10-20
wordpress_id: 2156
live_url: https://votegtr.com/accept-campaign-donations-online
category: Fundraising
segment: Candidates
target_keyword: campaign donations online
---
```

**Optional: Social Media Promotion**
- Create social media post drafts (if that workflow is established)
- Queue for social promotion

---

## WordPress API Configuration

### API Credentials (Secure)

**WordPress Site**: `https://votegtr.com`
**Username**: `sean@spmstrategies.com`
**Application Password**: `UhVn E9aZ pCoy vvlY 55lb QnWe`
**User ID**: 12
**Display Name**: Sean Murphy

**Security Notes**:
- Application password can be revoked anytime in WordPress → Users → Profile
- Limited to permissions of user account (not server access)
- Only used for creating/updating posts

### Available Categories

| ID | Category Name | Best For |
|----|---------------|----------|
| 42 | Campaign Strategy | Strategy guides, planning content |
| 44 | Fundraising | Donation setup, fundraising optimization |
| 45 | Website Strategy | Website planning, platform decisions |
| 43 | Website Tips | How-to guides, tutorials |
| 46 | Digital Marketing | Marketing tactics, outreach |
| 47 | Quick Wins | Short, actionable tips |

**Default Category**: Will be selected based on article topic and segment

---

## Category Assignment Logic

**AI will assign categories based on article topic:**

**Fundraising (44)**:
- Donation setup guides
- Fundraising optimization
- ActBlue/WinRed content
- FEC compliance for donations

**Campaign Strategy (42)**:
- Campaign planning content
- Strategy guides
- Timing and calendar content
- Consultant strategy articles

**Website Strategy (45)**:
- Platform comparisons
- Website planning guides
- "Getting started" content
- Long-form comprehensive guides

**Website Tips (43)**:
- How-to tutorials
- Feature guides
- Optimization tips
- Technical FAQs

**Digital Marketing (46)**:
- Social media integration
- SEO for campaigns
- Email marketing
- Digital outreach

**Quick Wins (47)**:
- Short tactical posts
- Quick tips
- Bite-sized advice

---

## Technical Implementation

### Creating a Draft Post (API Call)

```bash
curl -X POST --user "sean@spmstrategies.com:UhVn E9aZ pCoy vvlY 55lb QnWe" \
  https://votegtr.com/wp-json/wp/v2/posts \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Article Title Here",
    "content": "<p>HTML content here...</p>",
    "status": "draft",
    "slug": "article-url-slug",
    "categories": [44],
    "excerpt": "Brief article summary...",
    "meta": {
      "rank_math_title": "SEO Title | VOTEGTR",
      "rank_math_description": "SEO meta description here.",
      "rank_math_focus_keyword": "primary keyword"
    }
  }'
```

### Rank Math SEO Integration

**Important**: Rank Math requires its own API endpoint to properly set metadata.

**Method 1: Rank Math API (Recommended for Focus Keyword)**
```bash
curl -X POST 'https://votegtr.com/wp-json/rankmath/v1/updateMeta' \
  --user 'sean@spmstrategies.com:UhVn E9aZ pCoy vvlY 55lb QnWe' \
  -H 'Content-Type: application/json' \
  -d '{
    "objectID": POST_ID,
    "objectType": "post",
    "meta": {
      "rank_math_focus_keyword": "target keyword here"
    }
  }'
```

**Method 2: Standard WordPress Meta (for Title & Description)**
Set via standard `meta` field in post creation:
- `rank_math_title`: Meta title (50-60 chars)
- `rank_math_description`: Meta description (120-160 chars)

---

## Content Calendar Integration

### Content Calendar Tracking

Each article entry in `content-calendar.md` will track:

```markdown
| Title | Segment | Keyword | Status | WP ID | Draft URL | Live URL | Published |
|-------|---------|---------|--------|-------|-----------|----------|-----------|
| How to Accept Donations | Candidates | campaign donations | Draft in WP | 2156 | [Edit](https://votegtr.com/wp-admin/post.php?post=2156&action=edit) | - | - |
| Managing Client Websites | Consultants | political consultant tools | Approved | - | - | - | - |
```

**Status Values**:
- `Planned` - On content calendar, not yet drafted
- `Drafting` - AI actively writing
- `Review` - In /drafts/ awaiting your approval
- `Approved` - In /ready-to-publish/ awaiting WordPress upload
- `Draft in WP` - Uploaded to WordPress as draft
- `Published` - Live on VOTEGTR.com

---

## Quality Control Checklist

### Before WordPress Upload (AI)

- [ ] Article meets minimum word count (1,200+)
- [ ] All SEO elements present (title, meta, keywords)
- [ ] Internal links included (3-5)
- [ ] External links to authoritative sources (2-4)
- [ ] Headers properly structured (H1 → H2 → H3)
- [ ] Clear CTA at end
- [ ] Vault alignment verified
- [ ] No broken links

### Before Publishing (Human)

- [ ] Content accurate and on-brand
- [ ] Formatting clean on mobile and desktop
- [ ] Meta title and description optimized
- [ ] Category appropriate
- [ ] URL slug clean
- [ ] Excerpt compelling
- [ ] Images added (if available)
- [ ] All links functional
- [ ] Rank Math SEO score acceptable (if shown)

---

## Troubleshooting

### Issue: API Authentication Fails

**Solution**:
- Verify application password hasn't been revoked
- Check username is `sean@spmstrategies.com`
- Regenerate application password if needed

### Issue: Post Won't Save as Draft

**Solution**:
- Check user permissions (should be admin)
- Verify WordPress REST API is enabled
- Check for plugin conflicts (disable temporarily)

### Issue: Rank Math Metadata Not Saving

**Solution**:
- Verify Rank Math plugin is active
- Check meta field names match Rank Math's schema
- May need to set via Rank Math UI instead of API

### Issue: Category Not Assigned

**Solution**:
- Verify category ID is correct (use categories endpoint)
- Ensure user has permission to assign categories
- Check category exists and isn't deleted

### Issue: Internal Links Broken

**Solution**:
- Verify target pages exist before linking
- Use full URLs or proper WordPress relative paths
- Test all links in preview before publishing

---

## Workflow Optimization Tips

### Batching Content

**Weekly Batch Process**:
- Monday: Review and approve 3-4 drafts from previous week
- Tuesday: AI uploads approved articles to WordPress
- Wednesday: Human assistant reviews WordPress drafts, adds images
- Thursday-Friday: Publish 2-3 articles (spread throughout week)

**Benefits**:
- Consistent publishing schedule
- Efficient use of human review time
- Always have 3-5 articles in pipeline

### Publishing Schedule

**Recommended**:
- Publish 2-3 articles per week
- Best days: Tuesday, Wednesday, Thursday (peak engagement)
- Avoid: Monday (busy), Friday (low engagement), weekends

**Time of Day**:
- Optimal: 9-11 AM EST (morning browsing)
- Alternative: 2-4 PM EST (afternoon break)

---

## Future Enhancements

### Potential Workflow Improvements

**Image Integration**:
- Once image workflow established, AI can include image placeholders with specs
- Human adds images before or after WordPress upload
- Eventually automate with AI image generation

**Social Media Integration**:
- Auto-create social media post drafts when article published
- Queue for promotion across LinkedIn, X, Facebook

**Performance Tracking**:
- Automatically log article performance data
- Monthly reporting on top-performing content
- Feed insights back into content planning

**Automated Scheduling**:
- AI could propose publish dates based on calendar
- Human approves schedule
- WordPress auto-publishes at scheduled time

---

## Directory Structure

```
/VOTEGTR-WebsiteArticles/
├── /drafts/                                    # AI creates articles here
│   ├── accept-campaign-donations-online.md
│   ├── managing-multiple-client-websites.md
│   └── bulk-pricing-county-parties.md
│
├── /ready-to-publish/                          # After your approval, before WP upload
│   └── consultant-time-saving-tools.md
│
├── /published/                                 # After WordPress publishing
│   ├── 2025-10-15-how-votegtr-works.md
│   ├── 2025-10-18-mobile-responsive-websites.md
│   └── 2025-10-20-accept-campaign-donations-online.md
│
├── content-calendar.md                         # Master tracking document
├── content-gap-analysis.md                     # Gap analysis
├── content-subject-selection-methodology.md    # Topic selection guide
├── seo-writing-guidelines.md                   # SEO standards
└── wordpress-publishing-workflow.md            # This document
```

---

## Communication Templates

### AI → Human: Draft Ready

```
📝 New Article Ready for Review

Title: [Article Title]
Segment: [Candidates/Consultants/Party Chairs/Current Customers]
Target Keyword: [primary keyword]
Word Count: [count]
File: /drafts/[filename].md

Please review and approve or request revisions.
```

### AI → Human: Uploaded to WordPress

```
✅ Article Uploaded to WordPress

Title: [Article Title]
WordPress ID: [####]
Status: Draft
Category: [Category Name]

Edit: https://votegtr.com/wp-admin/post.php?post=####&action=edit
Preview: https://votegtr.com/?p=####&preview=true

Ready for your review and publishing.
```

### Human → AI: Approval

```
Approved: [Article Title]
```

### Human → AI: Revisions Needed

```
Revisions needed for [Article Title]:
- [Specific change 1]
- [Specific change 2]
- [etc.]
```

### Human → AI: Published Confirmation

```
Published: [Article Title]
Live URL: https://votegtr.com/[slug]
Published Date: [YYYY-MM-DD]
```

---

## Performance Metrics

### Tracking (Future Phase)

**Article-Level Metrics** (to track eventually):
- Publish date and time
- Page views (first 7 days, first 30 days)
- Average time on page
- Bounce rate
- Conversions (demo requests, trial signups)
- Organic search ranking for target keyword
- Social shares

**Workflow Metrics**:
- Articles drafted per month
- Approval rate (accepted vs. revisions needed)
- Time from draft to publish
- Publishing consistency (articles/week)

---

## Version Control

**Document Version**: 1.0
**Last Updated**: October 20, 2025
**API Test Status**: ✅ Verified working (Test post ID: 2155)
**Owner**: VOTEGTR Content Strategy

---

## Related Documentation

- `seo-writing-guidelines.md` - SEO standards for content
- `content-subject-selection-methodology.md` - How topics are chosen
- `content-gap-analysis.md` - Content gaps to fill
- `content-calendar.md` - Editorial calendar and tracking
- `votegtr-vault` repository - Messaging source of truth
