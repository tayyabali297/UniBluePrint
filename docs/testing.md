# UniBluePrint Schedule Booking — Testing Documentation

## Overview

This document provides test cases, sample payloads, and verification steps for the N8N Schedule Booking workflow.

---

## Webhook Endpoint

```
POST https://your-n8n-instance.com/webhook/schedule-booking
Content-Type: application/json
```

The webhook responds immediately with `200 OK` while processing continues asynchronously.

---

## Test Scenarios

### Test 1: Minimal Student

**Description:** Student with only lectures and minimal commitments.

**Payload:**
```json
{
  "student": {
    "name": "Aoife Murphy",
    "email": "aoife.murphy.test@student.tcd.ie",
    "university": "Trinity",
    "course": "Business & Economics",
    "year": "2nd"
  },
  "schedule": {
    "monday": [
      { "name": "Microeconomics", "start": "09:00", "end": "11:00", "location": "Arts Building", "mandatory": true }
    ],
    "tuesday": [
      { "name": "Accounting 101", "start": "14:00", "end": "16:00", "location": "Business School", "mandatory": true }
    ],
    "wednesday": [
      { "name": "Statistics", "start": "10:00", "end": "12:00", "location": "Hamilton Building", "mandatory": true }
    ],
    "thursday": [],
    "friday": [
      { "name": "Business Law", "start": "11:00", "end": "13:00", "location": "Arts Building", "mandatory": true }
    ]
  },
  "hobbies": [],
  "sports": [],
  "socialEvents": [],
  "collegeEvents": [],
  "commute": {
    "location": "Rathmines",
    "mode": "Bus",
    "toCampus": 25,
    "fromCampus": 30,
    "days": ["Monday", "Tuesday", "Wednesday", "Friday"]
  },
  "deadlines": [],
  "routines": {
    "wakeTime": "08:00",
    "bedTime": "23:00",
    "morningDuration": 45,
    "eveningDuration": 30,
    "personalCare": 20,
    "mealPrep": 45
  },
  "work": { "isWorking": false, "isJobHunting": false },
  "goals": {
    "mainGoals": "Pass all my exams and maintain a social life",
    "strengths": "Good at sticking to a routine",
    "weaknesses": "Procrastination in the evenings",
    "improvements": "Study more consistently",
    "scheduleObjectives": ["Better productivity", "More free time"],
    "additionalContext": ""
  },
  "preferences": {
    "studyHoursWeekly": 10,
    "idealStudyHours": 18,
    "studyStyle": "long_blocks",
    "studyLocation": "library",
    "bestStudyTime": ["afternoon"],
    "breakDuration": 30,
    "downtimeDaily": 2,
    "maxHoursPerDay": 12,
    "freeDays": ["Sunday"],
    "energyLevels": "afternoon",
    "afternoonNap": false
  }
}
```

**Expected outcome:**
- Schedule generated with 4 lecture days, study blocks on Thursday + spare slots
- Sunday completely free
- Email delivered within 60 seconds
- Recommendations mention consistent afternoon study blocks

---

### Test 2: Over-committed Student

**Description:** Student with 50+ hours of weekly commitments — workflow must optimize and warn.

**Payload:**
```json
{
  "student": {
    "name": "Ciarán O'Brien",
    "email": "ciaran.obrien.test@student.ucd.ie",
    "university": "UCD",
    "course": "Computer Science",
    "year": "3rd"
  },
  "schedule": {
    "monday": [
      { "name": "Algorithms", "start": "09:00", "end": "11:00", "location": "Science Building", "mandatory": true },
      { "name": "Software Engineering", "start": "14:00", "end": "16:00", "location": "UCD Computer Lab", "mandatory": true }
    ],
    "tuesday": [
      { "name": "Networks", "start": "10:00", "end": "12:00", "location": "Science Building", "mandatory": true },
      { "name": "Databases", "start": "15:00", "end": "17:00", "location": "Science Building", "mandatory": true }
    ],
    "wednesday": [
      { "name": "AI & Machine Learning", "start": "09:00", "end": "11:00", "location": "UCD", "mandatory": true }
    ],
    "thursday": [
      { "name": "Algorithms Lab", "start": "14:00", "end": "17:00", "location": "Computer Lab", "mandatory": true }
    ],
    "friday": [
      { "name": "Project Meeting", "start": "10:00", "end": "12:00", "location": "Online", "mandatory": true }
    ]
  },
  "hobbies": [
    { "name": "Guitar", "days": ["Monday", "Wednesday", "Friday"], "timeOfDay": "evening", "duration": 60, "frequency": 3, "flexible": true },
    { "name": "Gaming", "days": ["Tuesday", "Thursday"], "timeOfDay": "evening", "duration": 120, "frequency": 2, "flexible": true },
    { "name": "Reading", "days": ["Saturday", "Sunday"], "timeOfDay": "morning", "duration": 60, "frequency": 2, "flexible": true }
  ],
  "sports": [
    { "type": "Football training", "days": ["Tuesday", "Thursday"], "startTime": "19:00", "duration": 90, "location": "UCD Astroturf", "teamCommitment": true },
    { "type": "Football match", "days": ["Saturday"], "startTime": "14:00", "duration": 120, "location": "Various", "teamCommitment": true },
    { "type": "Gym", "days": ["Monday", "Wednesday", "Friday"], "startTime": "07:00", "duration": 60, "location": "UCD Gym", "teamCommitment": false }
  ],
  "socialEvents": [
    { "eventType": "Society meeting", "name": "Coding Society", "days": ["Wednesday"], "timeCommitment": 2, "recurring": true },
    { "eventType": "Social gathering", "name": "Friends dinner", "days": ["Friday"], "timeCommitment": 3, "recurring": true }
  ],
  "collegeEvents": [
    { "name": "Hackathon", "eventType": "Competition", "frequency": "One-time", "date": "2026-04-05", "duration": 24 }
  ],
  "commute": {
    "location": "Clonskeagh",
    "mode": "Walk",
    "toCampus": 10,
    "fromCampus": 10,
    "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  },
  "deadlines": [
    { "name": "Algorithms Assignment", "dueDate": "2026-03-28", "prepTime": 15, "priority": "High" },
    { "name": "SE Group Project", "dueDate": "2026-04-10", "prepTime": 20, "priority": "High" },
    { "name": "Networks Lab Report", "dueDate": "2026-04-02", "prepTime": 8, "priority": "Medium" }
  ],
  "routines": {
    "wakeTime": "07:00",
    "bedTime": "00:00",
    "morningDuration": 30,
    "eveningDuration": 30,
    "personalCare": 20,
    "mealPrep": 30,
    "morningActivities": ["Workout", "Breakfast"],
    "eveningActivities": ["Dinner", "TV/Netflix"]
  },
  "work": { "isWorking": true, "hoursPerWeek": 16, "shiftDays": ["Saturday", "Sunday"], "shiftTimes": "10:00-18:00", "isJobHunting": false },
  "goals": {
    "mainGoals": "Get a summer internship at a tech company, maintain 2:1 grade",
    "strengths": "Technical skills, motivated when interested",
    "weaknesses": "Over-committing, procrastination, poor sleep",
    "improvements": "Better time management, earlier bed time, cut down on gaming",
    "scheduleObjectives": ["Better productivity", "Improved grades", "More time for job applications", "Reduced stress"],
    "additionalContext": "Hackathon on April 5-6 will take full weekend"
  },
  "preferences": {
    "studyHoursWeekly": 15,
    "idealStudyHours": 25,
    "studyStyle": "short_bursts",
    "studyLocation": "home",
    "bestStudyTime": ["morning", "afternoon"],
    "breakDuration": 15,
    "downtimeDaily": 1,
    "maxHoursPerDay": 16,
    "freeDays": [],
    "energyLevels": "morning",
    "afternoonNap": false
  }
}
```

**Expected outcome:**
- Warnings about over-commitment (50+ hours scheduled)
- Recommendations to reduce gaming time for deadline prep
- Study blocks prioritized for morning energy peak
- Hackathon flagged in recommendations
- Metrics show `busiestDay` as Tuesday or Thursday

---

### Test 3: Night Owl Student

**Description:** Student with very late sleep schedule.

**Payload:**
```json
{
  "student": {
    "name": "Siobhán Walsh",
    "email": "siobhan.walsh.test@student.dcu.ie",
    "university": "DCU",
    "course": "Journalism & Media",
    "year": "1st"
  },
  "schedule": {
    "monday": [
      { "name": "Media Studies", "start": "13:00", "end": "15:00", "location": "Henry Grattan Building", "mandatory": true }
    ],
    "tuesday": [
      { "name": "Writing Workshop", "start": "14:00", "end": "16:00", "location": "HG Building", "mandatory": true }
    ],
    "wednesday": [
      { "name": "Digital Media", "start": "12:00", "end": "14:00", "location": "Online", "mandatory": true }
    ],
    "thursday": [
      { "name": "Broadcast Journalism", "start": "15:00", "end": "17:00", "location": "Radio Studio", "mandatory": true }
    ],
    "friday": []
  },
  "hobbies": [
    { "name": "Podcast editing", "days": ["Thursday", "Friday"], "timeOfDay": "evening", "duration": 90, "frequency": 2, "flexible": true },
    { "name": "Social media content", "days": ["Monday", "Wednesday", "Saturday"], "timeOfDay": "evening", "duration": 60, "frequency": 3, "flexible": true }
  ],
  "sports": [],
  "socialEvents": [
    { "eventType": "Social gathering", "name": "Night out with friends", "days": ["Friday"], "timeCommitment": 5, "recurring": true }
  ],
  "collegeEvents": [],
  "commute": {
    "location": "Drumcondra",
    "mode": "Walk",
    "toCampus": 15,
    "fromCampus": 15,
    "days": ["Monday", "Tuesday", "Wednesday", "Thursday"]
  },
  "deadlines": [],
  "routines": {
    "wakeTime": "11:00",
    "bedTime": "02:00",
    "morningDuration": 60,
    "eveningDuration": 30,
    "personalCare": 45,
    "mealPrep": 30
  },
  "work": { "isWorking": true, "hoursPerWeek": 10, "shiftDays": ["Saturday"], "shiftTimes": "16:00-22:00", "isJobHunting": false },
  "goals": {
    "mainGoals": "Build portfolio of published articles, grow social media presence",
    "strengths": "Creative at night, prolific writer",
    "weaknesses": "Cannot function in the morning, impulsive social media use",
    "improvements": "Gradually shift sleep schedule, reduce mindless scrolling",
    "scheduleObjectives": ["Better productivity", "More free time", "Better sleep schedule"],
    "additionalContext": "Night owl, best work done between 10pm and 2am"
  },
  "preferences": {
    "studyHoursWeekly": 8,
    "idealStudyHours": 15,
    "studyStyle": "long_blocks",
    "studyLocation": "home",
    "bestStudyTime": ["evening", "late_night"],
    "breakDuration": 30,
    "downtimeDaily": 3,
    "maxHoursPerDay": 10,
    "freeDays": ["Sunday"],
    "energyLevels": "evening",
    "afternoonNap": false
  }
}
```

**Expected outcome:**
- Schedule starts at 11:00, not before
- Study blocks placed in evening (post-17:00)
- No early morning activities scheduled
- Recommendations suggest gradual schedule shift
- Sunday fully free

---

### Test 4: Athlete Student

**Description:** Student training 15+ hours/week with full course load.

**Payload:**
```json
{
  "student": {
    "name": "Fionn McAllister",
    "email": "fionn.mcallister.test@student.ucc.ie",
    "university": "UCC",
    "course": "Sports Science",
    "year": "3rd"
  },
  "schedule": {
    "monday": [
      { "name": "Sports Psychology", "start": "09:00", "end": "11:00", "location": "WGB", "mandatory": true }
    ],
    "tuesday": [
      { "name": "Biomechanics", "start": "10:00", "end": "12:00", "location": "Sports Science Building", "mandatory": true }
    ],
    "wednesday": [
      { "name": "Nutrition & Performance", "start": "14:00", "end": "16:00", "location": "WGB", "mandatory": true }
    ],
    "thursday": [
      { "name": "Research Methods", "start": "11:00", "end": "13:00", "location": "Online", "mandatory": true }
    ],
    "friday": [
      { "name": "Strength & Conditioning Lab", "start": "09:00", "end": "12:00", "location": "Performance Lab", "mandatory": true }
    ]
  },
  "hobbies": [],
  "sports": [
    { "type": "GAA Training", "days": ["Monday", "Wednesday", "Friday"], "startTime": "18:00", "duration": 120, "location": "UCC GAA Grounds", "teamCommitment": true },
    { "type": "GAA Match", "days": ["Sunday"], "startTime": "14:00", "duration": 180, "location": "Various", "teamCommitment": true },
    { "type": "Gym – Strength", "days": ["Tuesday", "Thursday"], "startTime": "07:00", "duration": 75, "location": "UCC Gym", "teamCommitment": false },
    { "type": "Recovery swim", "days": ["Saturday"], "startTime": "10:00", "duration": 45, "location": "UCC Pool", "teamCommitment": false }
  ],
  "socialEvents": [],
  "collegeEvents": [
    { "name": "Intervarsity GAA", "eventType": "Competition", "frequency": "One-time", "date": "2026-04-18", "duration": 8 }
  ],
  "commute": {
    "location": "On Campus (resident)",
    "mode": "Walk",
    "toCampus": 5,
    "fromCampus": 5,
    "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  },
  "deadlines": [
    { "name": "Biomechanics Report", "dueDate": "2026-04-01", "prepTime": 12, "priority": "High" },
    { "name": "Nutrition Assignment", "dueDate": "2026-04-15", "prepTime": 8, "priority": "Medium" }
  ],
  "routines": {
    "wakeTime": "06:30",
    "bedTime": "22:30",
    "morningDuration": 45,
    "eveningDuration": 45,
    "personalCare": 20,
    "mealPrep": 15,
    "morningActivities": ["Breakfast", "Meditation"],
    "eveningActivities": ["Dinner", "Stretching/Recovery"]
  },
  "work": { "isWorking": false, "isJobHunting": false },
  "goals": {
    "mainGoals": "Win Sigerson Cup, graduate with 2:1, possibly go pro",
    "strengths": "Disciplined, early riser, excellent physical recovery",
    "weaknesses": "Study fatigue after training, struggle with long study sessions",
    "improvements": "Better academic consistency, shorter but more focused study blocks",
    "scheduleObjectives": ["Better productivity", "Improved grades", "Healthier lifestyle", "Reduced stress"],
    "additionalContext": "Recovery is as important as training. Need 8+ hours sleep minimum."
  },
  "preferences": {
    "studyHoursWeekly": 10,
    "idealStudyHours": 20,
    "studyStyle": "short_bursts",
    "studyLocation": "library",
    "bestStudyTime": ["morning", "mid_morning"],
    "breakDuration": 30,
    "downtimeDaily": 1,
    "maxHoursPerDay": 14,
    "freeDays": [],
    "energyLevels": "morning",
    "afternoonNap": true
  }
}
```

**Expected outcome:**
- All GAA training slots (team commitments) locked in
- Study blocks placed in mornings before training
- Afternoon nap/recovery block included
- Sleep hours >= 56 in metrics (8h/night)
- Intervarsity competition flagged

---

### Test 5: Part-time Worker

**Description:** Student working 20 hours/week alongside full course load.

**Payload:**
```json
{
  "student": {
    "name": "Emma Fitzgerald",
    "email": "emma.fitzgerald.test@student.nuig.ie",
    "university": "NUIG",
    "course": "Law",
    "year": "2nd"
  },
  "schedule": {
    "monday": [
      { "name": "Contract Law", "start": "09:00", "end": "11:00", "location": "Law Faculty", "mandatory": true },
      { "name": "Constitutional Law", "start": "14:00", "end": "16:00", "location": "Law Faculty", "mandatory": true }
    ],
    "tuesday": [
      { "name": "Legal Research", "start": "11:00", "end": "13:00", "location": "Hardiman Library", "mandatory": true }
    ],
    "wednesday": [
      { "name": "Criminal Law", "start": "10:00", "end": "12:00", "location": "Law Faculty", "mandatory": true }
    ],
    "thursday": [
      { "name": "EU Law", "start": "14:00", "end": "16:00", "location": "Law Faculty", "mandatory": true }
    ],
    "friday": [
      { "name": "Moot Court Prep", "start": "10:00", "end": "12:00", "location": "Law Faculty", "mandatory": true }
    ]
  },
  "hobbies": [
    { "name": "Yoga", "days": ["Tuesday", "Thursday"], "timeOfDay": "morning", "duration": 45, "frequency": 2, "flexible": true }
  ],
  "sports": [],
  "socialEvents": [
    { "eventType": "Society meeting", "name": "Law Society", "days": ["Wednesday"], "timeCommitment": 2, "recurring": true }
  ],
  "collegeEvents": [
    { "name": "Spring Week Applications", "eventType": "Career fair", "frequency": "Weekly", "dayOfWeek": "Saturday", "duration": 3 }
  ],
  "commute": {
    "location": "Salthill",
    "mode": "Bus",
    "toCampus": 20,
    "fromCampus": 25,
    "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  },
  "deadlines": [
    { "name": "Contract Law Essay", "dueDate": "2026-03-30", "prepTime": 20, "priority": "High" },
    { "name": "Moot Court Submission", "dueDate": "2026-04-12", "prepTime": 10, "priority": "High" }
  ],
  "routines": {
    "wakeTime": "07:30",
    "bedTime": "23:30",
    "morningDuration": 60,
    "eveningDuration": 30,
    "personalCare": 30,
    "mealPrep": 45
  },
  "work": {
    "isWorking": true,
    "hoursPerWeek": 20,
    "shiftDays": ["Thursday", "Friday", "Saturday"],
    "shiftTimes": "17:00-22:00 (Thu/Fri), 10:00-18:00 (Sat)",
    "isJobHunting": true,
    "jobHuntingHours": 4,
    "preferredJobHuntTime": "Weekends",
    "interviews": [
      { "date": "2026-03-20", "time": "14:00" }
    ]
  },
  "goals": {
    "mainGoals": "Get a training contract at a top firm, pass all exams",
    "strengths": "Organised, good under pressure, strong writer",
    "weaknesses": "Exhausted after work shifts, struggle to study on work days",
    "improvements": "Protect study time on work days, improve work-life balance",
    "scheduleObjectives": ["Improved grades", "More time for job applications", "Better work-life balance", "Reduced stress"],
    "additionalContext": "Works Thursday evenings and Saturdays. Interview on March 20th at 14:00. Spring week deadlines are critical."
  },
  "preferences": {
    "studyHoursWeekly": 18,
    "idealStudyHours": 28,
    "studyStyle": "long_blocks",
    "studyLocation": "library",
    "bestStudyTime": ["morning", "afternoon"],
    "breakDuration": 30,
    "downtimeDaily": 2,
    "maxHoursPerDay": 13,
    "freeDays": ["Sunday"],
    "energyLevels": "morning",
    "afternoonNap": false
  }
}
```

**Expected outcome:**
- Work shifts blocked off Thursday/Friday evenings and Saturday
- Interview on March 20 flagged in schedule notes
- Morning study blocks prioritized (pre-commute or post-lecture)
- Sunday kept free
- Warnings about high total weekly commitment

---

## Validation Test: Missing Required Fields

**Payload (should fail gracefully):**
```json
{
  "student": {
    "name": "",
    "email": "incomplete@test.ie"
  },
  "routines": {}
}
```

**Expected outcome:**
- Workflow returns `400` or logs validation error
- Error logged to `workflow_logs` table with `error_type: 'validation'`
- No Claude API call made
- No email sent

---

## How to Run Tests

### Using cURL

```bash
# Test 1: Minimal Student
curl -X POST https://your-n8n-instance.com/webhook/schedule-booking \
  -H "Content-Type: application/json" \
  -d @docs/test-payloads/test-01-minimal.json

# Check response
# Expected: {"success":true,"message":"Schedule generation started...","email":"..."}
```

### Using N8N Test Mode

1. Open the workflow in N8N editor
2. Click the **Webhook Trigger** node
3. Click **Listen For Test Event**
4. Use cURL or Postman to POST a test payload
5. Watch each node execute in real-time

### Using Postman

Import the collection from `docs/postman-collection.json` (if available) or create requests manually:

- **Method:** POST
- **URL:** `https://your-n8n-instance.com/webhook/schedule-booking`
- **Headers:** `Content-Type: application/json`
- **Body:** Raw JSON — paste any payload above

---

## Expected Response Times

| Step | Target |
|------|--------|
| Webhook response (202) | < 1 second |
| Data transformation | < 2 seconds |
| Supabase operations | < 3 seconds |
| Claude API call | < 30 seconds |
| Email delivery | < 60 seconds |
| Total end-to-end | < 90 seconds |

---

## Verifying Results

### Check Supabase Tables

```sql
-- Verify user was created/updated
SELECT * FROM users WHERE email = 'aoife.murphy.test@student.tcd.ie';

-- Verify schedule record
SELECT id, status, created_at FROM schedules
WHERE user_id = (SELECT id FROM users WHERE email = 'aoife.murphy.test@student.tcd.ie')
ORDER BY created_at DESC;

-- View generated schedule
SELECT generated_schedule, recommendations, metrics
FROM schedules
WHERE status = 'delivered'
ORDER BY created_at DESC LIMIT 1;

-- Check for errors
SELECT * FROM workflow_logs WHERE event_type = 'error' ORDER BY created_at DESC;
```

### Verify Email Delivery

Check the recipient inbox. The email should contain:
- Personalized header with student name and university
- Metrics cards (study hours, free time, sleep hours)
- Weekly schedule HTML table with color-coded activity blocks
- Recommendations section with key insights
- No broken HTML or missing data

---

## Load Testing

To verify the workflow handles 100 concurrent submissions:

```bash
# Install artillery: npm install -g artillery
# Create load test config
cat > load-test.yml << 'EOF'
config:
  target: "https://your-n8n-instance.com"
  phases:
    - duration: 60
      arrivalRate: 2
      name: "Warm up"
    - duration: 120
      arrivalRate: 10
      name: "Ramp up"
    - duration: 60
      arrivalRate: 20
      name: "Peak load"
scenarios:
  - flow:
    - post:
        url: "/webhook/schedule-booking"
        json:
          student:
            name: "Load Test User"
            email: "loadtest@test.ie"
            university: "Trinity"
            course: "Test Course"
            year: "1st"
          routines:
            wakeTime: "08:00"
            bedTime: "23:00"
            morningDuration: 45
            eveningDuration: 30
            personalCare: 20
            mealPrep: 30
          goals:
            mainGoals: "Test"
            strengths: "Testing"
            weaknesses: "None"
            improvements: "None"
            scheduleObjectives: []
            additionalContext: ""
          preferences:
            studyHoursWeekly: 15
            idealStudyHours: 20
            studyStyle: "long_blocks"
            studyLocation: "library"
            bestStudyTime: ["morning"]
            breakDuration: 30
            downtimeDaily: 2
            maxHoursPerDay: 12
            freeDays: ["Sunday"]
            energyLevels: "morning"
            afternoonNap: false
EOF
artillery run load-test.yml
```

**Success criteria:** ≥95% of requests complete without error within 120 seconds.
