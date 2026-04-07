# DayPlanner

A minimal macOS daily planner with glass UI and Kanban view.

<img src="logo.png" width="128" alt="DayPlanner">

## Features

- 3-state todos: todo, doing, done
- List and Kanban views
- Recurring todos
- Menu bar quick access
- Adaptive glass UI (light and dark mode)
- Drag-and-drop reordering
- Auto-updates via Sparkle
- Data export/import for backups

## Requirements

- macOS 26.0 (Tahoe) or later

## Install

1. Download `DayPlanner.zip` from [Releases](../../releases)
2. Extract the archive
3. Drag DayPlanner to `/Applications`
4. Right-click and select **Open** on first launch (required for unsigned apps)

## Data Storage

Your todos and recurring todos are stored as JSON files in:

```
~/Library/Application Support/DayPlanner/
```

You can export and import your data from **Settings > Data > Backup** to protect against data loss when uninstalling.

## Updates

The app checks for updates automatically on launch. You can also check manually from **DayPlanner menu > Check for Updates** or **Settings > About > Check for Updates**.

Updates are delivered through [Sparkle](https://sparkle-project.org) and signed with EdDSA keys for security.

## Building from Source

1. Clone the repository
2. Open `DayPlanner.xcodeproj` in Xcode
3. Build and run

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
