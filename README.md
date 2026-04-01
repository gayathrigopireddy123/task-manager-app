# Task Manager App

A Flutter task management app built for the Flodo AI take-home assignment.

## Track Chosen
Track B — Mobile Specialist (Local SQLite database, no backend)

## Stretch Goal
None

## Setup Instructions

1. Install Flutter from https://flutter.dev/docs/get-started/install
2. Clone this repository:
   git clone https://github.com/YourName/task-manager-app.git
3. Navigate to project folder:
   cd task_manager_app
4. Install dependencies:
   flutter pub get
5. Run the app:
   flutter run -d chrome
## Features
- Create, Read, Update, Delete tasks
- Each task has Title, Description, Due Date, Status and Blocked By fields
- Blocked By feature — if Task B is blocked by Task A, Task B shows greyed out with lock icon until Task A is marked Done
- Draft persistence — if you leave the create screen, your typed text is saved and restored
- Search tasks by title
- Filter tasks by status (To-Do, In Progress, Done)
- 2-second simulated save delay with loading spinner
- Save button disabled during loading to prevent double taps

## Tech Stack
- Flutter & Dart
- SQLite (sqflite) for local database
- Provider for state management
- SharedPreferences for draft persistence
## AI Usage Report

### Prompts that helped most:
- "Give me a Flutter Provider class that manages a list of tasks with search and filter functionality"
- "How to persist form draft data using SharedPreferences in Flutter"
- "Create a Flutter TaskCard widget that shows greyed out UI when a task is blocked"

### AI mistake encountered:
- Claude initially suggested wrong sqflite batch() syntax for bulk inserts
- Fixed by checking the official sqflite documentation on pub.dev
- Also had a code truncation issue in task_form_screen.dart where pasting cut off the bottom half of the file, causing bracket mismatch errors — fixed by replacing the entire file with complete code