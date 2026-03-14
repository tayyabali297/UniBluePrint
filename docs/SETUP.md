# UniBluePrint — Schedule Booking Workflow Setup Guide

## Overview

This guide walks you through setting up the complete N8N Schedule Booking workflow from scratch. By the end you'll have a working pipeline that:

1. Receives student data via webhook
2. Stores it in Supabase
3. Calls Claude AI to generate a personalized weekly schedule
4. Emails the schedule to the student
5. Notifies your team on Slack

**Estimated setup time:** 45–60 minutes

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| N8N | Latest stable | Self-hosted or N8N Cloud |
| Node.js | 18+ | Required for N8N self-hosted |
| Docker | 20+ | Recommended for self-hosted |
| Supabase account | — | Free tier works |
| Anthropic account | — | API access required |
| Email provider | — | SendGrid / Resend / Gmail |
| Slack workspace | — | For delivery notifications |

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/tayyabali297/UniBluePrint.git
cd UniBluePrint
```

---

## Step 2: Set Up Environment Variables

```bash
cp .env.example .env
```

Open `.env` and fill in **all** required values. At minimum you need:

- `CLAUDE_API_KEY` — from [console.anthropic.com](https://console.anthropic.com)
- `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` — from your Supabase project settings
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD` — from your email provider
- `FROM_EMAIL` — a verified sender address
- `SLACK_WEBHOOK_URL` — from your Slack app settings

---

## Step 3: Set Up Supabase Database

### 3a. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click **New project**
3. Choose a name (e.g. `unibluprint-prod`) and a strong database password
4. Select region closest to Ireland: **EU West (London)** or **EU Central (Frankfurt)**
5. Wait for provisioning (~2 minutes)

### 3b. Run Database Migration

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **New query**
3. Open `supabase/migrations/001_schedule_booking.sql` from this repo
4. Paste the full contents and click **Run**
5. Verify success: you should see 4 new tables in **Table Editor**:
   - `users`
   - `schedules`
   - `services_purchased`
   - `workflow_logs`

### 3c. Get API Credentials

1. Go to **Settings → API**
2. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **service_role key** → `SUPABASE_SERVICE_ROLE_KEY` (keep this secret!)
   - **anon public key** → `SUPABASE_ANON_KEY`

---

## Step 4: Set Up N8N

### Option A: Docker (Recommended for Production)

```bash
# Create a docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - WEBHOOK_URL=${WEBHOOK_URL}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}
      - FROM_EMAIL=${FROM_EMAIL}
    volumes:
      - n8n_data:/home/node/.n8n
    env_file:
      - .env
volumes:
  n8n_data:
EOF

docker-compose up -d
```

### Option B: N8N Cloud

1. Sign up at [app.n8n.cloud](https://app.n8n.cloud)
2. Create a new workflow instance
3. Go to **Settings → Environment Variables** and add all variables from `.env`

### Option C: Local Development

```bash
npm install -g n8n
export $(cat .env | xargs)
n8n start
```

Access N8N at `http://localhost:5678`

---

## Step 5: Configure N8N Credentials

In the N8N UI, go to **Settings → Credentials** and create:

### 5a. Supabase API Credential

1. Click **Add Credential** → search for **Supabase**
2. Fill in:
   - **Host:** your Supabase URL (from `SUPABASE_URL`)
   - **Service Role Secret:** your service role key
3. Save as `Supabase API`

### 5b. SMTP Credential

1. Click **Add Credential** → search for **SMTP**
2. Fill in your email provider details:
   ```
   Host:     smtp.sendgrid.net    (or your provider)
   Port:     587
   User:     apikey               (SendGrid) or your email (Gmail)
   Password: your SMTP password
   SSL/TLS:  STARTTLS
   ```
3. Save as `SMTP Credentials`

### 5c. HTTP Request Authentication (for Claude API)

The Claude API call uses environment variable `CLAUDE_API_KEY` directly in the header — no separate credential needed.

---

## Step 6: Import the N8N Workflow

1. In N8N, go to **Workflows** → **Import from file**
2. Select `n8n-workflow/schedule-booking-workflow.json`
3. Click **Import**
4. The workflow will appear with all nodes pre-configured

### Link Credentials to Nodes

After import, some nodes will show a credential warning. For each:

1. Click the node
2. In the **Credentials** dropdown, select the credential you created above
3. Save

Nodes requiring credentials:
- `Check User Exists` → Supabase API
- `Update User` → Supabase API
- `Create User` → Supabase API
- `Insert Schedule Data` → Supabase API
- `Save Generated Schedule` → Supabase API
- `Update Service Status` → Supabase API
- `Log Error to Supabase` → Supabase API
- `Send Email` → SMTP Credentials

---

## Step 7: Configure the Webhook URL

1. Click the **Webhook Trigger** node
2. Note the **Production URL** — it will look like:
   ```
   https://your-n8n-instance.com/webhook/schedule-booking
   ```
3. This is the endpoint your form (Typeform/Google Forms) or website will POST to

### Configure Your Form

**Typeform:**
1. Go to your Typeform form settings
2. Add a **Webhook** integration
3. Paste the N8N webhook URL
4. Map each field to the JSON structure expected by the workflow

**Google Forms:**
1. Use Google Apps Script to POST form responses to the webhook
2. Sample script provided below:

```javascript
// Google Apps Script — paste in your form's script editor
function onFormSubmit(e) {
  const responses = e.response.getItemResponses();
  const data = {};

  responses.forEach(r => {
    const title = r.getItem().getTitle();
    const answer = r.getResponse();
    // Map your form question titles to the JSON structure
    if (title === 'Full Name') data.name = answer;
    if (title === 'Email Address') data.email = answer;
    // ... add all mappings
  });

  const payload = {
    student: {
      name: data.name,
      email: data.email,
      university: data.university,
      course: data.course,
      year: data.year
    },
    // ... build full payload
  };

  UrlFetchApp.fetch('https://your-n8n-instance.com/webhook/schedule-booking', {
    method: 'POST',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  });
}
```

---

## Step 8: Activate the Workflow

1. In N8N, open the imported workflow
2. Toggle the **Active** switch (top right) to **ON**
3. The workflow is now listening for incoming webhook requests

---

## Step 9: Test the Workflow

Use the test payloads in `docs/testing.md`:

```bash
# Send the minimal student test payload
curl -X POST https://your-n8n-instance.com/webhook/schedule-booking \
  -H "Content-Type: application/json" \
  -d '{
    "student": {
      "name": "Test Student",
      "email": "test@example.com",
      "university": "Trinity",
      "course": "Computer Science",
      "year": "2nd"
    },
    "routines": {
      "wakeTime": "08:00",
      "bedTime": "23:00",
      "morningDuration": 45,
      "eveningDuration": 30,
      "personalCare": 20,
      "mealPrep": 30
    },
    "goals": {
      "mainGoals": "Pass exams",
      "strengths": "Organised",
      "weaknesses": "Procrastination",
      "improvements": "Study more",
      "scheduleObjectives": ["Better productivity"],
      "additionalContext": ""
    },
    "preferences": {
      "studyHoursWeekly": 15,
      "idealStudyHours": 20,
      "studyStyle": "long_blocks",
      "studyLocation": "library",
      "bestStudyTime": ["morning"],
      "breakDuration": 30,
      "downtimeDaily": 2,
      "maxHoursPerDay": 12,
      "freeDays": ["Sunday"],
      "energyLevels": "morning",
      "afternoonNap": false
    }
  }'
```

**Expected response:**
```json
{
  "success": true,
  "message": "Schedule generation started. You will receive an email shortly.",
  "email": "test@example.com"
}
```

Check `test@example.com` for the generated schedule email within 60–90 seconds.

---

## Step 10: Monitor & Debug

### Execution History

In N8N, go to **Executions** to see all workflow runs. Each run shows:
- Status (success/error)
- Duration
- Each node's input/output data

### Supabase Logs

```sql
-- View recent workflow errors
SELECT * FROM workflow_logs
WHERE event_type = 'error'
ORDER BY created_at DESC
LIMIT 20;

-- Check schedule statuses
SELECT u.email, s.status, s.created_at
FROM schedules s
JOIN users u ON s.user_id = u.id
ORDER BY s.created_at DESC
LIMIT 20;
```

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Claude API returns 401 | Invalid API key | Check `CLAUDE_API_KEY` in .env |
| Supabase insert fails | Missing table | Re-run migration SQL |
| Email not delivered | SMTP config wrong | Verify SMTP credentials and `FROM_EMAIL` |
| Webhook returns 404 | Workflow inactive | Toggle workflow to **Active** |
| JSON parse error | Claude returned non-JSON | Check Claude prompt length — may be hitting token limit |
| Slack notification fails | Webhook URL invalid | Re-create Slack webhook app |

---

## Architecture Diagram

```
[Student Form]
      │
      ▼ POST /webhook/schedule-booking
[Webhook Trigger] ──────────────────────────────► [Respond 200 OK]
      │
      ▼
[Transform Data] ──(error)──► [Handle Validation Error] ──► [Log to Supabase]
      │
      ▼
[Check User Exists (Supabase)]
      │
      ▼
[User Exists?]
   ├─YES──► [Update User]──┐
   └─NO───► [Create User]──┘
                           │
                           ▼
                [Insert Schedule Data]
                           │
                           ▼
                [Build Claude Prompt]
                           │
                           ▼
                [Claude API Call] ──(retry x3)
                           │
                           ▼
                [Parse Claude Response]
                           │
                           ▼
                [Save Generated Schedule]
                           │
                           ▼
                  [Format Email HTML]
                           │
                           ▼
                    [Send Email]
                           │
                           ▼
                [Update Service Status]
                           │
                           ▼
                [Slack Notification]
```

---

## Production Checklist

Before going live:

- [ ] All `.env` values filled in with production credentials
- [ ] Database migration applied to production Supabase project
- [ ] N8N instance secured with basic auth or OAuth
- [ ] `FROM_EMAIL` verified with email provider (avoid spam folder)
- [ ] HTTPS enabled on N8N instance (required for webhooks)
- [ ] Workflow toggled to **Active**
- [ ] Test email delivered successfully
- [ ] Slack notification received
- [ ] Error handling tested with invalid payload
- [ ] Supabase RLS policies reviewed
- [ ] `.env` file is in `.gitignore` (never commit secrets)

---

## File Reference

```
UniBluePrint/
├── .env.example                          # Environment variables template
├── n8n-workflow/
│   └── schedule-booking-workflow.json    # N8N workflow export (import this)
├── supabase/
│   └── migrations/
│       └── 001_schedule_booking.sql      # Database setup SQL
└── docs/
    ├── SETUP.md                          # This file
    └── testing.md                        # Test cases & sample payloads
```

---

## Support

For questions or issues, open a GitHub issue at:
https://github.com/tayyabali297/UniBluePrint/issues
