# Testing Notification System

## ⚠️ Important Notes

- **iOS Simulator has limited notification support** - notifications may not appear reliably
- **Real device testing is highly recommended** for accurate results
- Notifications require **notification permissions** to be granted

## 🧪 Testing Methods

### Method 1: Real Device Testing (Recommended)

1. **Build and run on a physical iOS device**
   - Connect your iPhone/iPad
   - Build and run from Xcode

2. **Grant notification permissions**
   - Complete onboarding or go to Settings > Notifications > ForwardNeckV1
   - Enable "Allow Notifications"

3. **Test Quick Workout Notifications** (Always fire)
   - Wait for scheduled times: 9am, 12pm, 3pm, 6pm, 9pm
   - These should fire regardless of completion status
   - ✅ Expected: Notification appears at each time

4. **Test Full Daily Workout Notifications** (Conditional)
   - **Scenario A - Not Completed:**
     - Don't complete Full Daily Workout
     - Wait for 12pm, 3pm, 6pm, or 9pm
     - ✅ Expected: Notification appears
   
   - **Scenario B - Completed:**
     - Complete Full Daily Workout before 12pm
     - Wait for 12pm, 3pm, 6pm, or 9pm
     - ✅ Expected: No notification appears (cancelled)
   
   - **Scenario C - Completion After Notification:**
     - Wait for 12pm notification
     - Complete Full Daily Workout after 12pm
     - Wait for 3pm, 6pm, or 9pm
     - ✅ Expected: No further notifications (cancelled)

5. **Test App Lifecycle Rescheduling**
   - Complete Full Daily Workout
   - Background the app
   - Wait a few minutes
   - Foreground the app
   - ✅ Expected: Notifications rescheduled (check logs)

### Method 2: Debug Testing with Shorter Intervals

For faster testing, you can temporarily modify notification times:

1. **Temporary Test Times** (modify in `NotificationManager.swift`):
   ```swift
   // Quick Workout - test with 1-minute intervals
   let quickWorkoutTimes = [
       (hour: Calendar.current.component(.hour, from: Date()),
        minute: Calendar.current.component(.minute, from: Date()) + 1,
        identifier: "exercise.quick.test1"),
       // ... add more test times
   ]
   ```

2. **Check Pending Notifications**:
   - Add debug code to see what's scheduled
   - Use Xcode's console logs

### Method 3: Using Xcode Debugging

1. **Check Logs**:
   - Look for log messages like:
     - "Scheduled Quick Workout reminders at..."
     - "Scheduled Full Daily Workout reminder for..."
     - "Cancelled Full Daily Workout notifications"
     - "Full Daily Workout completed today, cancelled remaining notifications"

2. **Breakpoints**:
   - Set breakpoints in:
     - `scheduleQuickWorkoutReminders()`
     - `scheduleFullDailyWorkoutReminders()`
     - `cancelFullDailyWorkoutNotifications()`
     - `rescheduleFullDailyWorkoutNotifications()`

## 🔍 Verification Checklist

### Quick Workout Notifications
- [ ] Notification appears at 9am
- [ ] Notification appears at 12pm
- [ ] Notification appears at 3pm
- [ ] Notification appears at 6pm
- [ ] Notification appears at 9pm
- [ ] Notifications appear even if Quick Workout was completed

### Full Daily Workout Notifications
- [ ] Notification appears at 12pm if not completed
- [ ] Notification appears at 3pm if not completed (and 12pm passed)
- [ ] Notification appears at 6pm if not completed (and 3pm passed)
- [ ] Notification appears at 9pm if not completed (and 6pm passed)
- [ ] No notifications appear if Full Daily Workout is completed
- [ ] Notifications are cancelled immediately after completion
- [ ] Notifications reschedule when app becomes active

### Edge Cases
- [ ] App launch schedules notifications correctly
- [ ] App foreground reschedules notifications correctly
- [ ] Multiple completions don't cause duplicate notifications
- [ ] Notifications persist after app restart

## 🐛 Debugging Tips

1. **Check Notification Center**:
   - Settings > Notifications > ForwardNeckV1
   - Verify permissions are enabled

2. **View Pending Notifications** (add to debug):
   ```swift
   let center = UNUserNotificationCenter.current()
   center.getPendingNotificationRequests { requests in
       print("Pending notifications: \(requests.count)")
       for request in requests {
           print("  - \(request.identifier): \(request.trigger)")
       }
   }
   ```

3. **Check System Time**:
   - Ensure device time is correct
   - Notifications use device's local time

4. **Reset Notifications**:
   - Delete and reinstall app
   - Or: Settings > General > Reset > Reset Location & Privacy

## 📱 Quick Test Script

Add this to a debug view or call from console:

```swift
// Test notification scheduling
Task {
    await NotificationManager.shared.scheduleExerciseReminders()
    print("✅ Notifications scheduled")
}

// Check pending notifications
let center = UNUserNotificationCenter.current()
center.getPendingNotificationRequests { requests in
    print("📬 Pending notifications: \(requests.count)")
    for request in requests {
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            print("  - \(request.identifier): \(trigger.dateComponents.hour ?? 0):\(trigger.dateComponents.minute ?? 0)")
        }
    }
}
```

