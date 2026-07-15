# Admin Edit for Tactical Meeting Responses

## Problem

`redmine_operational_metrics` lets a user submit one Tactical Meeting Response
per meeting (`new`/`create`, uniqueness-enforced). There is no `edit`/`update`
action at all — once submitted, a response can only be viewed, never
corrected. Admins need a way to fix/update any user's response.

## Scope

- Admin-only edit. Regular (non-admin) users still cannot edit after
  submitting — no change to their flow.
- `break_down_count` / `break_through_count` remain read-only during edit
  (they're derived from `OperationalMetric` data at original submission time,
  not something an admin should hand-edit).

## Changes

### Routes (`config/routes.rb`)

```ruby
resources :tactical_meeting_responses, only: [:index, :show, :new, :create, :edit, :update]
```

### Controller (`app/controllers/tactical_meeting_responses_controller.rb`)

- `edit`: loads `@tactical_meeting_response` and `@tactical_meeting`;
  `render_403` unless `User.current.admin?`.
- `update`: same admin guard; updates via a dedicated permitted-params method
  that excludes `break_down_count` / `break_through_count` (enforced
  server-side, not just hidden in the view, so it can't be bypassed via a
  crafted request); re-renders `edit` on validation failure, otherwise
  redirects to `show` with a success notice.

### Views

- New `app/views/tactical_meeting_responses/edit.html.erb`: same fieldsets as
  `new.html.erb`'s response form (Review, Reflect, Result, Creation,
  Facilitate, Closure Notes), without the "Your Tasks" left panel (not
  relevant when editing) and with break down/through counts shown as static
  text, not inputs.
- `index.html.erb`: add an "Edit" link next to "View", visible only when
  `User.current.admin?`.
- `show.html.erb`: add an "Edit" link, visible only when
  `User.current.admin?`.

## Out of scope

- Non-admin self-edit.
- Any change to the count-calculation logic itself.
- Tests (no test suite exists yet for this plugin).
