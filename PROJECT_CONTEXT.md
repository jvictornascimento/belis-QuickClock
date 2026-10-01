# Mini Time Clock Context

## Product Summary

This project is a small offline time clock app built with Flutter. The first target is Android, but the code should stay ready for iOS by avoiding platform-specific native code when possible.

The Flutter app is now the functional reference for a planned PWA migration.
The future backend and frontend projects must keep the same product rules unless
the shared context is intentionally updated.

## Related Project Paths

- Flutter reference app: `/mnt/c/projetos/ponto-eletronico`
- Spring backend: `/mnt/z/Spring/QuickClock`
- React PWA frontend: `/mnt/z/react/QuickClock`

When `PROJECT_CONTEXT.md` changes in one project, mirror the same context update
in the other two paths so backend, frontend, and Flutter reference stay aligned.

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

Estimates are scoped by company and keep their own history. Draft estimates do
not enter payment totals. Approved estimates keep the original record and store
`approved_at` for the future report payment month.
Monthly reports include only approved estimates, grouped by the `approved_at`
month and shown separately from additional services.

## Financial Control

This app is for personal use. Besides tracking work by company, it should also
support a simple financial control module.

Expected income already comes from monthly work reports:

- Worked day totals by company.
- Additional services by company.
- Approved estimates by company.

These expected values must be possible to mark as paid. When marked as paid,
they become income entries in the financial control. Keep the source relation so
the user can see whether the income came from worked days, an additional
service, or an approved estimate.

The financial control must also allow expense entries with:

- Date.
- Description.
- Amount in cents.
- Payment method, such as cash, Pix, debit, or credit card.
- Optional category.
- Optional installment data, for example `1/3`, `2/3`, `3/3`.

Installment expenses should appear month by month in the dashboard. Example:
`Credit card - tool purchase - installment 1/3` in one month, then installment
`2/3` in the next month, and so on.

### Financial Dashboard

The financial dashboard is not the main screen. The main screen must remain the
daily work entry flow. The dashboard should be opened only when the user chooses
to view financial information.

Dashboard views should include:

- Monthly income.
- Monthly expenses.
- Monthly balance.
- Detail by company.
- Detail by category.
- Detail by payment method.
- Installment timeline by month.
- Paid and unpaid expected income.

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
Reports are scoped by selected company and must show the company name.

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

### Financial Dashboard

Shows income, expenses, balance, paid items, pending expected income, categories,
payment methods, and installment details by month. It must be available from a
menu or secondary navigation, not as the default app entry screen.

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
