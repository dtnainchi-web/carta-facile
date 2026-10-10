// Supabase Edge Function: explain-letter
// Receives a photo of an Italian letter and returns a simple explanation
// in the user's language. The photo is NOT stored anywhere.
//
// Secrets (Supabase → Edge Functions → Secrets):
//   ANTHROPIC_API_KEY  – your Claude API key
//   CLAUDE_MODEL       – optional, defaults to claude-sonnet-5-5

const LANGUAGE_NAMES: Record<string, string> = {
  ar: "Modern Standard Arabic",
  fr: "French",
  it: "simple Italian",
  en: "English",
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function systemPrompt(language: string): string {
  const lang = LANGUAGE_NAMES[language] ?? "English";
  return `You help immigrants in Italy understand official letters and documents.
Read the photo of the letter and explain it in ${lang}, in short and simple sentences.
Never invent information that is not in the letter. If the image is unreadable or is not a letter/document, say so in "summary" and leave the other fields empty.
Reply ONLY with a JSON object, no other text, with these keys:
- "sender": the office that sent it, written as on the letter (e.g. "Questura di Milano", "INPS", "Agenzia delle Entrate"), or "".
- "summary": one sentence saying what the letter is about.
- "details": 1-3 short sentences with the important details (amounts, documents to bring, place).
- "actions": an array of 1-4 short steps the person must do.
- "deadline": the most important date in the letter as "YYYY-MM-DD", or null.
- "deadline_label": a short title for that date (e.g. "Appointment for fingerprints"), or null.
This is general help, not legal advice.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { image, media_type, language } = await req.json();
    if (!image || typeof image !== "string") {
      return json({ error: "missing image" }, 400);
    }
    // ~6 MB of base64 is plenty for a phone photo resized by the app.
    if (image.length > 6_000_000) return json({ error: "image too large" }, 413);

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) return json({ error: "server not configured" }, 500);

    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: Deno.env.get("CLAUDE_MODEL") ?? "claude-sonnet-5-5",
        max_tokens: 1024,
        system: systemPrompt(language ?? "en"),
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: { type: "base64", media_type: media_type ?? "image/jpeg", data: image },
              },
              { type: "text", text: "Explain this letter." },
            ],
          },
        ],
      }),
    });

    if (!response.ok) {
      console.error("AI error", response.status, await response.text());
      return json({ error: "ai_failed" }, 502);
    }

    const data = await response.json();
    const text: string = (data.content ?? [])
      .filter((b: { type: string }) => b.type === "text")
      .map((b: { text: string }) => b.text)
      .join("");

    // The model is asked for pure JSON; take the outermost {...} to be safe.
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start === -1 || end === -1) return json({ error: "bad_ai_output" }, 502);
    const result = JSON.parse(text.slice(start, end + 1));

    return json(result, 200);
  } catch (e) {
    console.error(e);
    return json({ error: "server_error" }, 500);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });
}
