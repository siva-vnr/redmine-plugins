# Redmine Operational Metrics Plugin

This repository contains the **Operational Metrics Plugin** for Redmine, designed to streamline the tracking of daily tasks, facilitate tactical meetings, and manage organizational holidays.

## 🚀 Concept & Overview

The primary goal of this plugin is to provide visibility into operational performance within a team. It moves beyond simple time tracking by categorizing tasks into "Break down" and "Break through" statuses, allowing for a more nuanced understanding of progress and roadblocks.

### Core Pillars

1.  **Operational Metrics**: A daily tracking system where users record their task progress, including project associations, time spent (supporting both decimal and `H:MM` formats), and qualitative details.
2.  **Tactical Meetings**: A structured framework for periodic team reviews. Facilitators can schedule meetings, and team members can submit responses detailing their goals, achievements, and challenges.
3.  **Holiday Management**: A central repository for holidays to ensure that operational reports and "last working day" calculations are accurate.

---

## ✨ Key Features

- **Dashboard & Statistics**: Visualize completion rates, project distributions, and total time spent.
- **Intelligent Date Handling**: Automatically identifies the "last working day" for report generation, accounting for weekends and custom holidays.
- **Role-Based Access**:
  - **Users**: Can track their own metrics and submit responses to assigned tactical meetings.
  - **Admins**: Full visibility across all users and projects, with the ability to manage holidays and schedule meetings.
- **Detailed Reporting**: Track "Break through" vs "Break down" counts to identify high-impact tasks vs. complex granular work.
- **Time Flexibility**: Seamlessly handles time entry in various formats (e.g., `1.5` hours or `1:30`).

---

## 🛠 Technical Architecture

### Models

- `OperationalMetric`: Stores the core task data, including `task_id`, `project`, `task_date`, and `completion` status.
- `TacticalMeeting`: Defines the meeting instances with `start_date`, `end_date`, and a `facilitator`.
- `TacticalMeetingResponse`: Captures user-specific details for a meeting, such as `individual_goals`, `learnings`, and `problems_doubts_fears`.
- `Holiday`: A simple record of non-working dates.

### Controllers

- `OperationalMetricsController`: Handles stats generation, CRUD operations for metrics, and the calculation of working days.
- `TacticalMeetingsController`: Manages the scheduling and listing of team meetings.
- `TacticalMeetingResponsesController`: Manages the submission and viewing of meeting responses, including auto-calculating metric summaries for the meeting period.
- `HolidaysController`: Provides an interface for managing the organizational holiday calendar.

---

## 📦 Installation

This is a standard Redmine plugin.

1.  Clone this repository into your Redmine `plugins` directory:
    ```bash
    git clone [repository-url] plugins/redmine_operational_metrics
    ```
2.  Run the plugin migrations:
    ```bash
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    ```
3.  Restart your Redmine application.
4.  Activate the plugin in Redmine settings and configure permissions as needed.
