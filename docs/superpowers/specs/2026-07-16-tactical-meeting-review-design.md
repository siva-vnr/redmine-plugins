# Tactical Meeting Review (KRA-based scoring)

## Problem

The appraisal/increment process needs developers' tactical meeting
responses scored against role-specific Key Result Areas (KRAs), each with a
configurable weight. Two roles exist today: **Solution Architect** and
**Project Engineer**. Weights differ per role and must sum to 100% within a
role. The KRA framework for developers (from the appraisal doc) is:

| KRA                        | Weight |
|-----------------------------|--------|
| Client Communication        | 30%    |
| Project Delivery            | 10%    |
| Code & Tech Quality         | 5%     |
| Learning & Growth           | 30%    |
| Team & Accountability       | 20%    |
| Global Company Involvement  | 5%     |

This table is the **Project Engineer** framework. The **Solution Architect**
framework is not yet defined — the schema/UI must support an arbitrary
per-role KRA list (configured later through the admin UI), not hardcode
either role's KRAs.

This extends the existing `TacticalMeetingResponse` feature
(`plugins/redmine_operational_metrics`): a review is scored against one
specific response.

## Scope

- Admin-only: managing KRA definitions, and creating/editing reviews (same
  restriction already used for editing responses).
- One review per response (1:1). Role and KRA set are locked in at review
  creation; to re-role a review, delete and recreate it.
- KRA weight definitions are versioned by snapshotting into the review at
  creation time, so editing a role's KRA list later never changes the
  math of past reviews.
- Score per KRA is 0-100 (percentage). Comment is one overall free-text
  field per review, not per KRA.
- KRA weights for a role must sum to exactly 100 when saved.

## Data model

### `kras`

| column   | type    | notes                                          |
|----------|---------|-------------------------------------------------|
| role     | string  | `"Solution Architect"` or `"Project Engineer"`  |
| name     | string  | e.g. "Client Communication"                      |
| weight   | decimal | percentage, e.g. 30.00                           |
| position | integer | display order                                    |

Uniqueness: `name` unique within `role`. No seed data — both roles start
empty until an admin configures them via KRA Settings.

### `tactical_meeting_reviews`

| column                        | type    | notes                                    |
|-------------------------------|---------|-------------------------------------------|
| tactical_meeting_response_id  | FK      | unique (1:1 with response)                |
| reviewer_id                   | FK      | `User` who performed the review           |
| role                          | string  | snapshot of role used for this review     |
| overall_score                 | decimal | computed = Σ(item.score × item.weight/100)|
| comment                       | text    | optional overall comment                  |

### `tactical_meeting_review_items`

| column                       | type    | notes                                  |
|-------------------------------|---------|------------------------------------------|
| tactical_meeting_review_id    | FK      |                                            |
| kra_id                        | FK      | nullable; reference only, not used in math|
| kra_name                      | string  | snapshot at review creation time          |
| weight                        | decimal | snapshot at review creation time          |
| score                         | decimal | 0-100                                     |

## KRA management (admin)

New top-menu item "KRA Settings" (admin-only visibility). Routes:
`GET /kras` (index, links to each role), `GET/PATCH /kras/:role` (edit/update
that role's full KRA list — name/weight/position, add/remove rows). On
`update`, the whole list for that role is replaced in one transaction;
rejected if the submitted weights don't sum to 100.

## Review flow

Nested under the response:

```ruby
resources :tactical_meeting_responses do
  resource :review, controller: 'tactical_meeting_reviews', only: [:new, :create, :edit, :update]
end
```

All actions `render_403` unless `User.current.admin?`.

- **New**: admin first picks a role (GET form, reloads with `role` in the
  query string). Once a role is chosen, the form renders one row per KRA
  configured for that role (pulled live from `kras`, ordered by `position`),
  each with a 0-100 score input, plus one overall comment box. If the role
  has zero KRAs configured, show a message + link to KRA Settings instead
  of an empty form.
- **Create**: builds the review and its snapshotted items from the
  submitted scores, computes `overall_score`, saves.
- **Edit/Update**: scores and comment are editable. Role and KRA set
  (name/weight per item) are immutable after creation — only `score` and
  the review's `comment` can change.

## Display

Rendered inline on the existing `tactical_meeting_responses#show` page,
below the response content:
- If no review exists: admin sees an "Add Review" link; non-admins see
  nothing extra.
- If a review exists: render each KRA row (name, weight, score, weighted
  contribution = `score × weight / 100`), the `overall_score`, and the
  `comment`. Admin additionally sees an "Edit Review" link.

No standalone review index page — always accessed through its parent
response.

## Out of scope

- Solution Architect's actual KRA weights (configured later via the UI,
  not part of this change).
- The broader increment/appraisal-pool calculation described in the
  appraisal document (billing-linked pool, promotions, multi-person
  distribution) — this change only covers capturing the per-response KRA
  score, not downstream increment math.
- Non-admin access to reviews (viewing or scoring).
- Changing a review's role after creation (requires delete + recreate).
- Tests (no test suite exists yet for this plugin).
