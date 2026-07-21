# Project Plan: Supabase Auth Integration & APK Build Guide

This document outlines the steps required to implement user authentication (Sign In/Up) in the Flutter application, isolate user data securely in Supabase using Row Level Security (RLS), identify potential security risks, and build a release-ready APK for distribution.

---

## 1. Supabase Authentication & User Isolation

Currently, the application writes directly to the `livros` table without user identification, meaning all books are shared globally. We need to introduce accounts and isolate data.

### Supabase Schema Updates (User Action Required)

#### A. Add `user_id` to `livros` Table
To link books to specific accounts, we need a foreign key relationship pointing to Supabase's built-in `auth.users` table:

```sql
-- Add user_id column to livros table
ALTER TABLE public.livros 
ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) DEFAULT auth.uid();

-- Force user_id to be populated automatically on insert
ALTER TABLE public.livros 
ALTER COLUMN user_id SET DEFAULT auth.uid();
```

#### B. Enable Row Level Security (RLS) on `livros`
By default, anyone with the anon key can read/write any row. We must restrict access so users can only perform CRUD operations on their own books:

```sql
-- Enable RLS on livros table
ALTER TABLE public.livros ENABLE ROW LEVEL SECURITY;

-- Policy: Allow users to select only their own books
CREATE POLICY "Users can view their own books" 
ON public.livros FOR SELECT 
USING (auth.uid() = user_id);

-- Policy: Allow users to insert their own books
CREATE POLICY "Users can insert their own books" 
ON public.livros FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: Allow users to update only their own books
CREATE POLICY "Users can update their own books" 
ON public.livros FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Allow users to delete only their own books
CREATE POLICY "Users can delete their own books" 
ON public.livros FOR DELETE 
USING (auth.uid() = user_id);
```

### Flutter Code Changes Needed

1. **Login & Registration UI**:
   * Create a new screen (`LoginScreen`) to handle email/password input.
   * Add options to toggle between Sign In and Sign Up (Registration).
2. **Auth State Controller**:
   * Create an `AuthController` using `ChangeNotifier` to manage user sessions.
   * Listen to auth state changes using `Supabase.instance.client.auth.onAuthStateChange`.
   * Automatically redirect authenticated users to the home screen, and unauthenticated users to the Login Screen.
3. **Link Book Creation to Current User**:
   * Update the book saving methods so that the new books automatically contain the logged-in user's ID (which Supabase handles automatically if configured with the `auth.uid()` default, but it's good practice to map in the client payload too).

---

## 2. Release & APK Distribution Build Steps

To distribute the app to users, we need to generate a release APK.

### A. Pre-requisites & Signing (Optional but Recommended)
For local testing or distribution to close friends, you can compile a debug APK directly. However, for a production/official release, you should sign the app:
1. Generate a keystore file using Java's `keytool`.
2. Reference the keystore in a `key.properties` file inside `android/` directory (which we added to `.gitignore`).
3. Configure the `signingConfigs` block inside `android/app/build.gradle`.

### B. Build Commands
Run the following terminal command from the project root:

```bash
# Build a release APK
flutter build apk --release
```

* This will output the release APK to:
  `build/app/outputs/flutter-apk/app-release.apk`
* You can send this `.apk` file directly to other people via email, chat, or file sharing platforms.

---

## 3. Security Risk Audit

Here are the security issues identified in the current code and how to mitigate them:

| Risk Area | Threat Level | Current Issue | Mitigation |
| :--- | :--- | :--- | :--- |
| **No RLS Enabled** | **CRITICAL** | Anyone with your Supabase Anon API key can read, edit, or delete any record in the `livros` database. | Enforce RLS policies (as detailed in Section 1) immediately. |
| **Exposed API Keys** | **LOW** | The Supabase Anon key is compiled into the app. | For client-side databases like Supabase, exposing the Anon Key is safe **only if** RLS is strictly configured on the database. RLS serves as the primary firewall. |
| **Image Upload Security** | **MEDIUM** | Storage buckets in Supabase may allow public write access, meaning anyone could upload arbitrary files. | Restrict bucket write access using Supabase Storage RLS policies, allowing only authenticated users to write to `book-covers`. |

---

## 4. Verification Checklist

- [ ] Execute SQL commands in Supabase SQL editor to create columns & enable RLS.
- [ ] Implement `LoginScreen` widget in Flutter.
- [ ] Connect `auth.onAuthStateChange` listener to manage routing.
- [ ] Verify that registering a new account isolates their library from other accounts.
- [ ] Run `flutter build apk --release` and check output file success.
