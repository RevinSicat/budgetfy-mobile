# Budgetfy
    A budgeting app built with Flutter and Supabase DB

## Features
    - Create and manage Accounts, Categories, Subcategories, and Transactions
    - Track and log your expenses with ease
    - Securely store all your data in your own Supabase project

## Budgetfy Tech Stack
    - Frontend: Flutter (Dart)
    - Backend: Supabase (PostgreSQL)
    - State Management: Riverpod

## SET UP
### Step 1: Create Account in Supabase
    - Create Project
### Step 2: Open SQL Editor 
    - Copy queries inside build_db_table.txt
### Step 3: In Your Supabase Project
    - Find and take note of supabase url, and anon key
### Step 4: When Debuging/Building App"
    - flutter run
    - flutter build
### (Optional) Step 1: Create config.json:
    - Inside the config store place this inside and replace the contents with your supabase url, anon key
    {
        "SUPABASE_URL": "[your url]",
        "SUPABASE_ANON_KEY": "[your anon key]"
    }
### (Optional) Step 2: When Debuging App with config.json:
    - flutter run --dart-define-from-file=config.json
    - flutter build apk --dart-define-from-file=config.json