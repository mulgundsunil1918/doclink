// The Gemini API key is NOT stored here anymore.
//
// It lives server-side in a Supabase secret (GEMINI_API_KEY) and is used
// only by the 'gemini-proxy' Edge Function. The Flutter app calls that
// function via the public Supabase anon key, so no AI key is ever shipped
// to the client or committed to git.
//
// To rotate the key:  npx supabase secrets set GEMINI_API_KEY=your_new_key
