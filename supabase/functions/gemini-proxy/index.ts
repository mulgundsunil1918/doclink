// Supabase Edge Function: gemini-proxy
//
// Despite the name, this proxies Groq (Gemini free tier is blocked for this
// Google account/region). The Flutter app's request shape is unchanged —
// this function translates the Gemini-style payload to Groq's
// OpenAI-compatible API. The Groq API key lives in the Supabase secret
// GROQ_API_KEY — never in the client or in git.
//
// Deploy:  npx supabase functions deploy gemini-proxy
// Secret:  npx supabase secrets set GROQ_API_KEY=your_key

// Primary model (best clinical reasoning). Falls back to the smaller, higher
// quota model if the big one is rate-limited.
const GROQ_MODEL = "llama-3.3-70b-versatile";
const GROQ_FALLBACK_MODEL = "llama-3.1-8b-instant";
const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ProxyRequest {
  system?: string;
  contents: Array<{ role: string; parts: Array<{ text: string }> }>;
  generationConfig?: { temperature?: number; maxOutputTokens?: number };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) {
    return json(
      { error: "GROQ_API_KEY secret is not set on the server." },
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

  // Translate Gemini-style payload -> OpenAI/Groq chat format.
  const messages: Array<{ role: string; content: string }> = [];
  if (body.system) {
    messages.push({ role: "system", content: body.system });
  }
  for (const c of body.contents) {
    const text = (c.parts ?? []).map((p) => p.text ?? "").join("\n");
    messages.push({
      role: c.role === "model" ? "assistant" : "user",
      content: text,
    });
  }

  const temperature = body.generationConfig?.temperature ?? 0.4;
  const maxTokens = body.generationConfig?.maxOutputTokens ?? 800;

  async function callGroq(model: string): Promise<Response> {
    return await fetch(GROQ_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages,
        temperature,
        max_tokens: maxTokens,
      }),
    });
  }

  try {
    let resp = await callGroq(GROQ_MODEL);
    // If the big model is rate-limited, retry once on the smaller model.
    if (resp.status === 429) {
      resp = await callGroq(GROQ_FALLBACK_MODEL);
    }

    const data = await resp.json();
    if (!resp.ok) {
      const msg = data?.error?.message ?? `Groq error ${resp.status}`;
      return json({ error: msg }, resp.status);
    }

    const text = data?.choices?.[0]?.message?.content ?? "";
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
