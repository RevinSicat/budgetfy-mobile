# Budgetfy
    A budgeting app built with Flutter and Supabase DB

## Budgetfy Tech Stack
    > Frontend: Flutter (Dart)
    > Backend: Supabase (PostgreSQL)
    > State Management: Riverpod

## SET UP
### Step 1: Create Account in Supabase
    > Create Project
### Step 2: Open SQL Editor 
    > Copy queries inside build_db_table.txt
### Step 3: In Your Supabase Project
    > Find and take note of supabase url, and anon key
### Step 4: Create config.json
    > Inside the config store place this inside and replace the contents with your supabase url, anon key
    {
        "SUPABASE_URL": "[your url]",
        "SUPABASE_ANON_KEY": "[your anon key]"
    }
### Step 5A: When Debuging App:
    > THIS IS A MUST or app debuging will fail
    > flutter run --dart-define-from-file=config.json
### Step 5B: When Building Apk:
    > THIS IS A MUST or apk building will fail
    > flutter build apk --dart-define-from-file=config.json