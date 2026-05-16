// Supabase Edge Function: gemini-proxy
//
// Holds the Gemini API key server-side (Supabase secret GEMINI_API_KEY).
// The Flutter app calls this function with the anon key (public, safe);
// the Gemini key is never shipped to the client or committed to git.
//
// Deploy:  npx supabase functions deploy gemini-proxy
// Secret:  npx supabase secrets set GEMINI_API_KEY=your_key

const GEMINI_MODEL = "gemini-2.0-flash";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ProxyRequest {
  system?: string;
  contents: Array<{ role: string; parts: Array<{ text: string }> }>;
  generationConfig?: Record<string, unknown>;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    return json(
      { error: "GEMINI_API_KEY secret is not set on the server." },
      500,
    );
  }

  let body: ProxyRequest;
  try {
    body = await req.json();
  } catch (_) {
    return json({ error: "Invalid JSON body" }, 400);
  }

  if (!body.contents || !Array.isArray(body.contents)) {
    return json({ error: "Missing 'contents' array" }, 400);
  }

  const geminiUrl =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`;

  const payload: Record<string, unknown> = {
    contents: body.contents,
    generationConfig: body.generationConfig ?? {
      temperature: 0.4,
      maxOutputTokens: 800,
    },
  };
  if (body.system) {
    payload.system_instruction = { parts: [{ text: body.system }] };
  }

  try {
    const resp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const data = await resp.json();

    if (!resp.ok) {
      const msg = data?.error?.message ?? `Gemini error ${resp.status}`;
      return json({ error: msg }, resp.status);
    }

    const text =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    return json({ text });
  } catch (e) {
    return json({ error: `Upstream request failed: ${e}` }, 502);
  }
});

function json(obj: unknown, status = 200): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
