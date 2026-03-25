# budgetfy

A new Flutter project.

# Setup config.json 
{
    "SUPABASE_URL": "[your url]",
    "SUPABASE_ANON_KEY": "[your anon key]"
}

# When running app:
flutter run --dart-define-from-file=config.json this is to avoid 

# When building app:
flutter build apk --dart-define-from-file=config.json