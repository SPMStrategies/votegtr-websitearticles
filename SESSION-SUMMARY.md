# VOTEGTR Content Workflow - Session Summary

**Date**: October 20, 2025
**Session Duration**: Full workflow setup + 2 articles created

---

## What We Built Today

### ✅ Complete Content Creation System

**6 Governance Documents Created:**
1. `content-subject-selection-methodology.md` - Framework for choosing article topics
2. `content-gap-analysis.md` - Analysis of current content gaps on VOTEGTR.com
3. `seo-writing-guidelines.md` - 2025 SEO best practices
4. `votegtr-brand-voice-guidelines.md` - Authentic VOTEGTR tone and voice
5. `votegtr-facts-accuracy-reference.md` - Factual corrections (FEC, payment processors, etc.)
6. `rank-math-scoring-checklist.md` - Complete Rank Math 21+ test criteria
7. `wordpress-publishing-workflow.md` - Complete publishing process
8. `content-calendar.md` - Editorial calendar and tracking

**Directory Structure:**
```
/VOTEGTR-WebsiteArticles/
├── /drafts/                    # AI creates articles here
├── /ready-to-publish/          # After approval, before WordPress
├── /published/                 # Archive after publishing
└── [8 governance documents]
```

---

## WordPress API Integration

**Status**: ✅ Fully functional

**Credentials:**
- Site: https://votegtr.com
- User: sean@spmstrategies.com
- Application Password: Configured
- Method: WordPress REST API + Rank Math API

**Capabilities:**
- Create draft posts
- Set SEO metadata (title, description)
- Set Rank Math focus keyword
- Upload full article content (including 3,000+ word articles)
- Assign categories
- Set author

---

## Articles Created

### Article 1: "How to Accept Campaign Donations Online"
- **WordPress ID**: 2156
- **Status**: Published (by human assistant)
- **Segment**: Candidates
- **Target Keyword**: "campaign donations online"
- **Word Count**: ~2,100
- **Category**: Fundraising
- **URL**: https://votegtr.com/accept-campaign-donations-online/
- **Rank Math Score**: 57/100 (needs images, power word in title, TOC)

### Article 2: "The Complete Guide to Managing Multiple Political Client Websites in 5 Simple Steps"
- **WordPress ID**: 2158
- **Status**: Draft (awaiting human review)
- **Segment**: Consultants (opens 0% coverage gap)
- **Target Keyword**: "managing multiple political client websites"
- **Word Count**: ~3,000
- **Category**: Campaign Strategy
- **Edit URL**: https://votegtr.com/wp-admin/post.php?post=2158&action=edit
- **Rank Math Optimization**: Designed for 80+ score
  - Power word: "Complete Guide"
  - Number: "5 Simple Steps"
  - 3,000+ words
  - Focus keyword in title, intro, multiple H2s
  - Includes "Why Consultants Trust VOTEGTR to Stay in Our Lane" section

---

## Key Learnings & Refinements

### Content Accuracy
- School board = local (state rules, not FEC)
- Republican payment processors: WinRed and Anedot (not Stripe)
- VOTEGTR positioning for consultants: Digital execution team, not just software

### Workflow Improvements
1. **Long articles**: Implemented two-step API upload (metadata first, content second)
2. **Rank Math integration**: Use `/wp-json/rankmath/v1/updateMeta` endpoint for focus keyword
3. **Voice requirements**: Consultants need reassurance VOTEGTR stays in their lane

---

## Workflow: Approval to WordPress

**When you say "Approved":**
1. AI moves article from `/drafts/` → `/ready-to-publish/`
2. AI converts markdown to WordPress HTML
3. AI creates WordPress draft post with:
   - Title, meta title, meta description
   - Category assignment
   - Author (Sean Murphy)
   - SEO slug
4. AI uploads full article content (handles any length)
5. AI sets Rank Math focus keyword
6. AI provides edit URL

**Human assistant then:**
1. Reviews draft in WordPress
2. Adds 4+ images with alt text
3. Adds table of contents (for 2,000+ word articles)
4. Reviews formatting
5. Publishes when ready

**AI then:**
1. Moves article to `/published/`
2. Updates content calendar
3. Archives with publish date and URL

---

## Content Gap Priorities (Next Articles)

**Critical Priority:**
1. ✅ Managing Multiple Political Client Websites (DONE - Post 2158)
2. White-Label Campaign Websites for Consultants
3. Advanced VOTEGTR Features You're Not Using (Current Customers)
4. Bulk Website Solutions for County Party Chairs
5. What Happens After You Sign Up with VOTEGTR

**Current Segment Coverage:**
- Candidates: 90% (overrepresented)
- Consultants: 10% (1 article created today)
- Party Chairs: 10% (severely underserved)
- Current Customers: 0% (critical gap)

---

## Rank Math Optimization Checklist

**To achieve 80+ score, every article needs:**

✅ **Title:**
- Power word (Complete, Ultimate, Essential, Guide)
- Number (5 Steps, 7 Ways, 30 Minutes)
- Focus keyword in first 50%
- 50-60 characters

✅ **Content:**
- 2,500+ words (100% length score)
- Focus keyword in first paragraph
- Focus keyword in 2-3 H2/H3 headings
- Short paragraphs (2-4 sentences)
- Table of contents for 2,000+ words

✅ **Media:**
- 4+ images minimum
- At least 1 image alt text contains focus keyword
- All images optimized and compressed

✅ **Links:**
- 3-5 internal links to VOTEGTR pages
- 2-4 external links to authoritative sources
- Descriptive anchor text

✅ **Meta:**
- Focus keyword in meta description
- Meta description 120-160 characters
- URL slug contains keyword, under 75 chars

---

## Files Location

All files saved in: `/Users/Sean/VOTEGTR-WebsiteArticles/`

**Key Documents:**
- `content-gap-analysis.md` - What to write next
- `content-subject-selection-methodology.md` - How to choose topics
- `seo-writing-guidelines.md` - SEO best practices
- `votegtr-brand-voice-guidelines.md` - Tone and voice
- `votegtr-facts-accuracy-reference.md` - Factual accuracy
- `rank-math-scoring-checklist.md` - Score 80+ on Rank Math
- `wordpress-publishing-workflow.md` - Publishing process
- `content-calendar.md` - Editorial tracking

**Articles:**
- `ready-to-publish/managing-multiple-political-client-websites.md` - Article 2 (in WordPress as draft)
- `drafts/how-to-accept-campaign-donations-online.md` - Article 1 (published)

---

## Next Steps

1. Human assistant reviews Post 2158 in WordPress
2. Add images and table of contents
3. Publish when ready
4. Request next article from priority queue
5. Continue filling content gaps (Consultants, Current Customers, Party Chairs)

---

## WordPress Test Posts

- **Test Post ID**: 2155 (can be deleted)
- **Article 1**: 2156 (published)
- **Article 2**: 2158 (draft)

---

## Success Metrics

✅ Complete content workflow documented
✅ WordPress API integration working
✅ Full article upload (any length) working
✅ Rank Math focus keyword integration working
✅ 2 articles created (1 published, 1 in draft)
✅ Consultant segment opened (was 0%)
✅ All governance docs created
✅ Voice and accuracy guidelines established

**System is production-ready!**
