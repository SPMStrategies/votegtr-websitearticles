# VOTEGTR Daily Article Generation - Automation Setup

**Last Updated**: October 20, 2025

---

## Overview

This document explains how to set up the automated daily article generation system for VOTEGTR.com. The system uses GitHub Actions to generate one article per day using Claude AI, following all governance documents and SEO guidelines.

**What it does:**
- ✅ Generates 1 article per day at 9 AM EST
- ✅ Follows all governance documents and SEO guidelines
- ✅ Maintains segment distribution balance (Candidates, Consultants, Party Chairs, Current Customers)
- ✅ Commits article to GitHub automatically
- ✅ Sends email notification when article is ready for review

---

## Prerequisites

Before setting up automation, you need:

1. **GitHub Repository** (✅ Already created: `SPMStrategies/votegtr-websitearticles`)
2. **Anthropic API Key** (for Claude AI)
3. **SMTP Email Credentials** (for sending notifications)

---

## Setup Instructions

### Step 1: Get Your Anthropic API Key

1. Go to [console.anthropic.com](https://console.anthropic.com/)
2. Sign in or create an account
3. Navigate to **API Keys**
4. Click **Create Key**
5. Copy the API key (starts with `sk-ant-`)
6. Save it securely - you'll need it in Step 3

**Note:** Keep your API key secret. Never commit it to the repository.

---

### Step 2: Configure Email Settings

You need SMTP credentials to send email notifications. Choose one of these options:

#### Option A: Gmail (Easiest for Personal Use)

1. Go to your [Google Account Settings](https://myaccount.google.com/)
2. Navigate to **Security** → **2-Step Verification**
3. Scroll down to **App passwords**
4. Generate an app password for "Mail"
5. Save these credentials:
   - **SMTP Server**: `smtp.gmail.com`
   - **SMTP Port**: `587`
   - **Username**: Your Gmail address (e.g., `sean@spmstrategies.com`)
   - **Password**: The 16-character app password (not your regular password)

#### Option B: SendGrid (Recommended for Business)

1. Sign up at [sendgrid.com](https://sendgrid.com/) (free tier: 100 emails/day)
2. Create an API key
3. Save these credentials:
   - **SMTP Server**: `smtp.sendgrid.net`
   - **SMTP Port**: `587`
   - **Username**: `apikey` (literally the word "apikey")
   - **Password**: Your SendGrid API key

#### Option C: AWS SES (For High Volume)

1. Set up [AWS SES](https://aws.amazon.com/ses/)
2. Verify your sender email address
3. Get SMTP credentials from SES console
4. Save these credentials:
   - **SMTP Server**: Your SES SMTP endpoint (e.g., `email-smtp.us-east-1.amazonaws.com`)
   - **SMTP Port**: `587`
   - **Username**: Your SES SMTP username
   - **Password**: Your SES SMTP password

---

### Step 3: Add Secrets to GitHub

GitHub Actions uses **Secrets** to securely store sensitive information like API keys.

1. Go to your GitHub repository: https://github.com/SPMStrategies/votegtr-websitearticles
2. Click **Settings** (top right)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

Add the following secrets one by one:

| Secret Name | Value | Example |
|-------------|-------|---------|
| `ANTHROPIC_API_KEY` | Your Claude API key | `sk-ant-api03-xxx...` |
| `SMTP_SERVER` | Your SMTP server address | `smtp.gmail.com` |
| `SMTP_PORT` | SMTP port (usually 587) | `587` |
| `SMTP_USERNAME` | Your email/SMTP username | `sean@spmstrategies.com` |
| `SMTP_PASSWORD` | Your SMTP password/app password | `abcd efgh ijkl mnop` |
| `NOTIFICATION_EMAIL` | Email to receive notifications | `sean@spmstrategies.com` |

**Important:**
- Secret names are case-sensitive
- Values are encrypted and never visible after saving
- You can update them anytime

---

### Step 4: Enable GitHub Actions

1. In your repository, click the **Actions** tab
2. If prompted, click **I understand my workflows, go ahead and enable them**
3. You should see the workflow: **Daily Article Generation**

---

### Step 5: Test the Workflow (Manual Trigger)

Before waiting for the scheduled run, test it manually:

1. Go to **Actions** tab in your repository
2. Click **Daily Article Generation** in the left sidebar
3. Click **Run workflow** button (top right)
4. Select branch: `main`
5. Click **Run workflow**

**What happens:**
- GitHub Actions will run the workflow
- A placeholder article will be generated (until Claude API integration is complete)
- Article will be committed to `/drafts/`
- You'll receive an email notification

**Expected email:**
```
Subject: 📝 New VOTEGTR Article Ready for Review: [Article Title]

Content includes:
- Article metadata (segment, keyword, word count)
- Link to view article on GitHub
- Next steps for review/approval
```

---

### Step 6: Verify Everything Works

After the test run completes:

1. **Check GitHub Actions**:
   - Go to **Actions** tab
   - Click on the latest workflow run
   - All steps should show green checkmarks ✅

2. **Check Email**:
   - You should receive an email notification
   - Email should have article details and GitHub link

3. **Check Repository**:
   - Navigate to `/drafts/` folder
   - You should see a new placeholder article file
   - File should be committed by "VOTEGTR Content Bot"

If everything works, you're done! ✅

---

## How It Works Daily

### Automated Schedule

The workflow runs automatically every day at **9:00 AM EST** (configurable).

**Daily Process:**
1. **9:00 AM EST**: GitHub Actions triggers workflow
2. **Step 1**: Claude API reads governance documents and content gap analysis
3. **Step 2**: Claude generates next priority article (2,500+ words, SEO-optimized)
4. **Step 3**: Article is saved to `/drafts/` folder
5. **Step 4**: Article is committed and pushed to GitHub
6. **Step 5**: Email notification sent to you

**Your Review Process:**
1. **9:05 AM**: Receive email notification
2. **Morning**: Review article on GitHub
3. **Reply**: "Approved" or provide revision feedback
4. **Next Step**: Article uploaded to WordPress as draft (manual or automated)

---

## Configuration

### Changing the Schedule

To change when articles are generated:

1. Edit `.github/workflows/daily-article-generation.yml`
2. Find this line:
   ```yaml
   - cron: '0 14 * * *'
   ```
3. Update the cron expression:
   - `0 14 * * *` = 9 AM EST (2 PM UTC during DST)
   - `0 13 * * *` = 8 AM EST
   - `0 15 * * *` = 10 AM EST
   - Use [crontab.guru](https://crontab.guru/) to generate custom schedules

4. Commit and push changes

### Adjusting Article Frequency

To generate articles less/more frequently:

**Option 1: Weekly instead of Daily**
```yaml
# Every Monday at 9 AM EST
- cron: '0 14 * * 1'
```

**Option 2: Multiple times per week**
```yaml
# Monday, Wednesday, Friday at 9 AM EST
- cron: '0 14 * * 1,3,5'
```

**Option 3: Multiple per day**
```yaml
# 9 AM and 2 PM EST daily
- cron: '0 14,19 * * *'
```

### Segment Distribution Settings

The system automatically balances content across segments based on `config/automation.json`:

```json
{
  "target_distribution": {
    "candidates": 0.45,      // 45% of articles
    "consultants": 0.28,     // 28% of articles
    "party_chairs": 0.17,    // 17% of articles
    "current_customers": 0.10 // 10% of articles
  }
}
```

**To adjust:**
1. Edit `config/automation.json`
2. Change percentages (must total 1.0)
3. Commit and push

---

## Troubleshooting

### Issue 1: No Email Received

**Possible causes:**
- SMTP credentials incorrect
- Email in spam folder
- SMTP server blocking GitHub IPs

**Solutions:**
1. Check spam folder first
2. Verify SMTP secrets in GitHub Settings → Secrets
3. Check GitHub Actions logs for email errors
4. Try a different SMTP provider (SendGrid recommended)

---

### Issue 2: Workflow Fails

**Check:**
1. Go to **Actions** tab
2. Click on the failed workflow run
3. Expand failed step to see error message

**Common errors:**
- `ANTHROPIC_API_KEY not found`: Secret not set correctly
- `Authentication failed`: SMTP credentials wrong
- `Permission denied`: GitHub token needs write access

**Solutions:**
- Verify all secrets are set correctly
- Check secret names match exactly (case-sensitive)
- Ensure repository has Actions enabled

---

### Issue 3: Article Not Generated

**If workflow runs but no article appears:**

1. Check GitHub Actions logs for errors
2. Verify `ANTHROPIC_API_KEY` is valid
3. Check Claude API quota/limits
4. Look for error messages in workflow output

---

### Issue 4: Duplicate Articles

**If same article generated repeatedly:**

This shouldn't happen, but if it does:
1. Check `content-calendar.md` is being updated
2. Verify article tracking is working
3. Manually mark articles as "generated" in calendar

---

## Pausing/Resuming Automation

### To Pause Daily Generation

**Option 1: Disable Workflow**
1. Go to **Actions** tab
2. Click **Daily Article Generation**
3. Click **⋮** (three dots) → **Disable workflow**

**Option 2: Delete Schedule** (temporary)
1. Edit `.github/workflows/daily-article-generation.yml`
2. Comment out the schedule:
   ```yaml
   # schedule:
   #   - cron: '0 14 * * *'
   ```
3. Commit and push

### To Resume

- **Option 1**: Re-enable workflow in Actions tab
- **Option 2**: Uncomment the schedule and push

---

## Manual Triggering

You can always trigger article generation manually:

1. Go to **Actions** tab
2. Click **Daily Article Generation**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

**Use cases:**
- Testing after configuration changes
- Generating extra articles
- Catching up after pausing automation

---

## Cost Estimates

### Claude API Costs

Based on Claude Sonnet pricing:
- **Per article**: ~$0.15 - $0.30 (2,500 word article + governance docs context)
- **Per month** (1/day): ~$4.50 - $9.00
- **Per month** (2/day): ~$9.00 - $18.00

**To reduce costs:**
- Use Claude Haiku instead (faster, cheaper, but lower quality)
- Generate fewer articles per week
- Use smaller context (fewer governance docs)

### Email Costs

- **Gmail**: Free (with App Password)
- **SendGrid**: Free tier (100 emails/day = plenty)
- **AWS SES**: $0.10 per 1,000 emails (essentially free)

**Total Monthly Cost: ~$5-10/month**

---

## Monitoring and Maintenance

### Weekly Checks

1. **Review Content Calendar**: Ensure articles are being tracked
2. **Check Segment Balance**: Verify distribution matches targets
3. **Monitor Workflow Runs**: Ensure no failures
4. **Review Generated Articles**: Quality check drafts before approval

### Monthly Review

1. **API Usage**: Check Claude API costs
2. **Email Deliverability**: Ensure notifications arriving
3. **Workflow Performance**: Check for errors or slowdowns
4. **Update Governance Docs**: Refresh guidelines as needed

---

## Security Best Practices

### API Keys and Secrets

✅ **DO:**
- Store all credentials as GitHub Secrets
- Rotate API keys quarterly
- Use app-specific passwords (not account passwords)
- Enable 2FA on all accounts

❌ **DON'T:**
- Commit API keys to repository
- Share secrets in email or Slack
- Use personal passwords for SMTP
- Leave default/test credentials in production

### Access Control

- **GitHub Repository**: Keep private or limit collaborator access
- **API Keys**: Restrict to minimum necessary permissions
- **Email**: Use dedicated sender address (not personal email)

---

## Future Enhancements

**Planned improvements:**

1. **Full Claude API Integration**
   - Currently uses placeholder generation
   - Will integrate actual Claude API calls
   - Full governance document context

2. **Automatic WordPress Upload**
   - Auto-upload approved articles to WordPress
   - Reduce manual steps

3. **Performance Tracking**
   - Track article views, conversions
   - Feed data back into content planning

4. **Smart Scheduling**
   - Adjust generation based on approval rate
   - Pause if backlog builds up

---

## Getting Help

**If you encounter issues:**

1. **Check GitHub Actions Logs**: Most errors show up here
2. **Review this documentation**: Common issues covered in Troubleshooting
3. **Check GitHub Secrets**: Verify all secrets are set correctly
4. **Test Email Separately**: Use SMTP test tool to verify credentials

**Common Resources:**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [Cron Expression Generator](https://crontab.guru/)

---

## Quick Reference

### File Structure

```
/VOTEGTR-WebsiteArticles/
├── .github/
│   └── workflows/
│       └── daily-article-generation.yml   # GitHub Actions workflow
├── config/
│   └── automation.json                     # Configuration settings
├── scripts/
│   ├── generate-daily-article.sh           # Article generation script
│   └── send-notification.sh                # Email notification script
├── drafts/                                 # Generated articles appear here
├── ready-to-publish/                       # Approved articles
├── published/                              # Published articles archive
└── AUTOMATION-SETUP.md                     # This file
```

### Required GitHub Secrets

| Secret | Purpose | Example |
|--------|---------|---------|
| `ANTHROPIC_API_KEY` | Claude API access | `sk-ant-api03-...` |
| `SMTP_SERVER` | Email server | `smtp.gmail.com` |
| `SMTP_PORT` | Email port | `587` |
| `SMTP_USERNAME` | Email username | `your@email.com` |
| `SMTP_PASSWORD` | Email password | `app-password-here` |
| `NOTIFICATION_EMAIL` | Your email | `sean@spmstrategies.com` |

### Workflow Commands

| Command | Purpose |
|---------|---------|
| Manual trigger | Actions → Daily Article Generation → Run workflow |
| Disable workflow | Actions → Daily Article Generation → ⋮ → Disable |
| View logs | Actions → Click workflow run → Expand steps |
| Re-run failed | Actions → Click failed run → Re-run jobs |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-20 | Initial automation setup |

---

**Status**: ✅ Setup Complete

Ready to generate articles daily!
