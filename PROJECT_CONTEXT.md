# Mini Time Clock Context

## Product Summary

This project is a small offline time clock app built with Flutter. The first target is Android, but the code should stay ready for iOS by avoiding platform-specific native code when possible.

The app does not track clock-in or clock-out times. It only stores whether the user worked in each half of the current day:

- Before lunch
- After lunch

Each period is saved as a boolean value. The user can edit only the current day until 23:59.

## Main Rules

- The app must work offline with a local database.
- A day can have two saved values: `worked_before_lunch` and `worked_after_lunch`.
- The default state for each period is `false`.
- The main screen shows two large buttons.
- A light gray button means the period is not marked.
- A red button means the period is marked as worked.
- Tapping a button toggles the value and autosaves it.
- Old days are read-only.
- Future days cannot be edited.
- The edit rule is centralized in `WorkDayEditPolicy`.

## Configuration

The app needs a settings screen where the user can define the value of a half day worked.

Example:

```text
Half day value: R$ 80,00
```

This value is used in the monthly report. In code and database records, store it as cents (`half_day_value_cents`) to avoid decimal rounding errors. If both periods are marked in one day, the day total is two times the half day value.

## Local Data Model

Suggested tables:

```text
work_day
  id
  company_id
  date
  worked_before_lunch
  worked_after_lunch
  created_at
  updated_at

settings
  id
  company_id
  half_day_value_cents
  updated_at
```

Settings are scoped by company. Existing databases keep their current settings
under the default company during migration, and new companies start with the
default Monday-to-Friday schedule.

Work days are scoped by company. The same date can exist for multiple companies,
but only once per company.

Additional services are scoped by company and must only appear in that company's
monthly report.

## Screens

### Home

Shows the current date and two large autosave buttons:

- Before lunch
- After lunch

If the current weekday is disabled in settings, the home screen shows a folga message instead of the point buttons.

### Search

Allows searching saved work days by date or month. It shows only saved records and their two period values.

### Settings

Allows editing and saving the half day value and the active weekdays in local storage.

### Monthly Report

Shows only dates with at least one marked period. Empty days should not appear.
It also shows the monthly total using the saved half day value.

Clean report example:

```text
Monthly Report
June/2026

Date        Before   After    Value
16/06/2026  Yes      No       R$ 80,00
17/06/2026  Yes      Yes      R$ 160,00

Summary
Worked days: 2
Periods: 3
Total: R$ 240,00
```

PDF is the preferred export format because it is simple to preview, share, print, and keep consistent across Android and iOS.

## Story Plan

Each story should use its own branch. Branch names and commit messages must be in simple English.

1. `story/create-flutter-android` - create the Flutter project with Android focus.
2. `story/create-local-database` - add the local database and work day table.
3. `story/create-settings-value` - save the half day value.
4. `story/create-home-buttons` - add the main screen with two large autosave buttons.
5. `story/lock-old-days` - block editing outside the current day.
6. `story/create-settings-screen` - add the settings screen.
7. `story/create-search-screen` - search by date or month.
8. `story/create-month-report` - show only marked days in the monthly report.
9. `story/add-money-total` - calculate the monthly money total.
10. `story/create-report-pdf` - generate a clean monthly PDF.
11. `story/share-report-pdf` - view or share the generated PDF.

## Git Workflow

- Use one branch per story.
- Use branch names like `story/create-home-buttons`.
- Use Conventional Commits with a scope, for example:
  - `feat(home): add period buttons`
  - `fix(report): hide empty days`
  - `docs(context): add project rules`
- Keep commits small and clear.
- If a defect needs a formal correction flow, open an issue, fix it in a branch, and close the issue in the commit or pull request.
