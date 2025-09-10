# Requirements Document – Tech Neck Fix App (MVVM)

## 0. App UI Design
## Dashboard (Home Screen)

- Greeting text: "Hello, [UserName] 👋"
- Below greeting → Tabs:
  - **Overview** (default)
  - **Exercises**

### Overview Tab
- Replace "Priority Task Progress" with:
  - **Daily Streak Progress**
  - Show text: "You’ve checked your posture X/Y times today"
  - Progress bar showing percentage of daily reminders completed

- Replace "Total Task" card with:
  - **Posture Check-Ins**
  - Number = total posture check-ins completed this week

- Replace "Completed" card with:
  - **Exercises Done**
  - Number = total exercises completed this week

- Replace "Total Projects" card with:
  - **Longest Streak**
  - Number = longest streak of consecutive days

### Exercises Tab
- List of exercises with icons
- Tap → opens Exercise Detail screen



---

## Exercise Detail Screen
- Title of exercise
- Short text instructions
- Illustration (cartoon posture guide)
- Timer/pro

## 1. App Overview  
This app helps people fix “tech neck” (forward head posture) in a fun way.  
It reminds users to check their posture, gives them quick stretch exercises, tracks progress, and rewards them with streaks, points, and levels.  
It’s made for anyone who spends too much time looking at phones or computers.

---

## 2. Main Goals  
1. Remind users to check posture every day.  
2. Let users log when they fix posture.  
3. Show easy exercises with guides.  
4. Track streaks, progress, and goals.  
5. Make it fun with rewards and levels.

---

## 3. User Stories  

- **US-001**: As a user, I want posture reminders so I don’t forget.  
- **US-002**: As a user, I want to log posture checks so I feel accountable.  
- **US-003**: As a user, I want short posture exercises so I can stretch quickly.  
- **US-004**: As a user, I want to see streaks and stats so I stay motivated.  
- **US-005**: As a user, I want XP and levels so it feels fun and rewarding.  
- **US-006**: As a user, I want to set my own goals so the app fits my lifestyle.  
- **US-007**: As a user, I want graphs so I can see my improvement.  

---

## 4. Features  

- **F-001: Daily Reminders**  
  - Push notifications at default times (morning, lunch, evening).  
  - User can set custom times.  
  - If notifications fail → show alert in app.  

- **F-002: Posture Check-In**  
  - Button “I fixed my posture.”  
  - Adds to streak counter.  
  - If no internet → still works offline.  

- **F-003: Exercises**  
  - Simple stretches (1–3 min).  
  - Show with animation, picture, or video.  
  - If exercise video fails → show text guide instead.  

- **F-004: Streaks & Progress**  
  - Daily streak counter.  
  - Stats: checks done, exercises done, longest streak.  
  - If data missing → show “0” instead of crash.  

- **F-005: Gamification**  
  - Earn XP/coins for posture checks + exercises.  
  - Unlock levels or new tips.  
  - If bug → keep user’s XP safe in storage.  

- **F-006: Custom Goals**  
  - User can choose goals like “2 posture checks per day.”  
  - Track progress against goal.  
  - If goal not set → use defaults.  

- **F-007: Charts & Analytics**  
  - Weekly bar chart: posture checks vs. misses.  
  - Line graph: streaks over time.  
  - If no data → show empty chart with hint text.  

---

## 5. Screens  

- **S-001: Home Screen**  
  - Shows today’s reminders, check-in button, streak, XP.  
  - Entry point after opening app.  

- **S-002: Reminder Settings Screen**  
  - Choose reminder times.  
  - Reached from “Settings” button on Home.  

- **S-003: Exercise Screen**  
  - List of stretches.  
  - Tap exercise → open guide.  
  - Reached from Home or daily reminder.  

- **S-004: Progress Screen**  
  - Shows streak count, stats, goals, graphs.  
  - Reached from Home bottom menu/tab.  

- **S-005: Goals Screen**  
  - User picks custom goals.  
  - Reached from Progress screen.  

- **S-006: Rewards/Levels Screen**  
  - Shows XP, coins, unlocked posture tips.  
  - Reached from Home or Progress screen.  

- **S-007: Settings Screen**  
  - Change reminder times, reset data, toggle dark mode.  
  - Reached from Home menu.  

---

## 6. Data  

- **D-001**: List of reminders with times.  
- **D-002**: Posture check-ins (date, time).  
- **D-003**: Exercises completed (which one, when).  
- **D-004**: Daily streak count.  
- **D-005**: XP points, coins, and level.  
- **D-006**: Custom goals set by user.  
- **D-007**: Stats and charts data (weekly/monthly).  

---

## 7. Extra Details  

- Needs **notifications** permission for reminders.  
- Stores all data **on the device** (no internet needed).  
- Optional: backup to iCloud later.  
- Works in **light mode** and **dark mode**.  
- Should run offline for all core features.  

---

## 8. Build Steps  

- **B-001**: Build **S-001 Home Screen** with **F-002 Posture Check-In** + **D-002 Check-ins**.  
- **B-002**: Add **F-001 Daily Reminders** and connect to **S-002 Reminder Settings**. Store in **D-001 Reminders**.  
- **B-003**: Create **S-003 Exercise Screen** with **F-003 Exercises**. Save completions to **D-003 Exercises**.  
- **B-004**: Add **F-004 Streaks & Progress** on **S-004 Progress Screen**, storing in **D-004**.  
- **B-005**: Add **F-005 Gamification** and show results on **S-006 Rewards Screen**, save in **D-005**.  
- **B-006**: Build **F-006 Custom Goals** inside **S-005 Goals Screen**, use **D-006 Goals**.  
- **B-007**: Add **F-007 Charts & Analytics** to **S-004 Progress Screen**, based on **D-007 Stats**.  
- **B-008**: Connect all screens with a bottom tab bar (Home, Exercises, Progress, Rewards).  
- **B-009**: Finish **S-007 Settings Screen** with options for reminders, reset, dark mode.  
- **B-010**: Test offline use, notifications, streak saving, and dark mode.  
