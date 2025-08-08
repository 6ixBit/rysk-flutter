# Supabase Setup Guide for Rysk

This guide will help you set up Supabase integration for your Rysk Flutter app.

## 🚀 Prerequisites

- Flutter development environment
- Supabase account (free tier available)

## 📋 Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in/sign up
2. Click "New Project"
3. Choose your organization
4. Fill in project details:
   - Name: `rysk-app` (or your preferred name)
   - Database Password: Generate a strong password (save it!)
   - Region: Choose closest to your users
5. Click "Create new project"
6. Wait for the project to be created (2-3 minutes)

## 🔧 Step 2: Configure Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the entire contents of `supabase/schema.sql` in this project
3. Paste it into the SQL Editor
4. Click "Run" to execute the schema
5. Verify tables are created in **Table Editor**

## 🔑 Step 3: Get Your Credentials

1. In Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (something like `https://your-project.supabase.co`)
   - **Anon Public Key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## ⚙️ Step 4: Configure Flutter App

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';

  static const String documentImagesBucket = 'document-images';
}
```

## 🔒 Step 5: Configure Authentication

### Email Settings (Optional but Recommended)

1. Go to **Authentication** → **Settings** → **Auth Settings**
2. Configure email templates and settings as needed
3. For production, set up custom SMTP in **SMTP Settings**

### Social Auth (Optional)

To enable Google/Apple sign-in:

1. Go to **Authentication** → **Settings** → **Auth Providers**
2. Enable Google and/or Apple
3. Configure OAuth credentials from Google/Apple
4. Update login screen to use social auth methods

## 📁 Step 6: Set Up Storage

The storage bucket `document-images` should be created automatically by the schema.

To verify:

1. Go to **Storage** in Supabase dashboard
2. You should see `document-images` bucket
3. The bucket should have RLS policies configured

## 🧪 Step 7: Test the Integration

1. Run your Flutter app: `flutter run`
2. Try creating an account on the login screen
3. Check the **Authentication** → **Users** section in Supabase dashboard
4. Verify the user profile was created in **Table Editor** → **profiles**

## 📱 Step 8: Test on Physical Device

```bash
# iOS
flutter run --release

# Android
flutter build apk --release
```

## 🔍 Troubleshooting

### Common Issues

**Issue**: "Invalid API key" error

- **Solution**: Double-check your `supabaseUrl` and `supabaseAnonKey` in `supabase_config.dart`

**Issue**: "Row Level Security" errors

- **Solution**: Ensure RLS policies are properly set up by running the schema again

**Issue**: Authentication not working

- **Solution**: Check Supabase Auth logs in dashboard for detailed error messages

**Issue**: Storage uploads failing

- **Solution**: Verify storage policies and bucket configuration

### Debug Mode

Enable debug logging in your Flutter app:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: true, // Add this for debugging
  );

  runApp(const MyApp());
}
```

## 📊 Database Schema Overview

### Tables Created:

- **profiles**: User profile information
- **documents**: Document metadata and analysis results
- **document_images**: Image files for each document
- **risky_clauses**: Individual risky clauses found in documents

### Storage:

- **document-images**: Secure bucket for document image files

### Security:

- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- Automatic profile creation on user signup

## 🚀 Next Steps

After completing this setup:

1. **Test Authentication**: Try signing up and signing in
2. **Test Document Upload**: Scan or upload a document
3. **Check Database**: Verify data is being stored correctly
4. **Deploy**: When ready, deploy your Flutter app

## 📧 Support

If you encounter issues:

1. Check Supabase dashboard logs
2. Review Flutter console for error messages
3. Verify all configuration steps were followed
4. Check the official Supabase Flutter documentation

---

**Important**: Keep your Supabase credentials secure and never commit them to public repositories. Consider using environment variables for production deployments.
