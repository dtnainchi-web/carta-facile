// Supabase Edge Function: write-letter
// The user describes in their language what they want to say; we return a
// polite Italian letter plus a short explanation in their language.
//
// Secrets: ANTHROPIC_API_KEY, optional CLAUDE_MODEL (default claude-sonnet-5-5)

const LANGUAGE_NAMES: Record<string, string> = {
  ar: "Modern Standard Arabic",
  fr: "French",
  it: "Italian",
  en: "English",
};

const RECIPIENTS: Record<string, string> = {
  landlord: "the landlord (proprietario di casa)",
  employer: "the employer (datore di lavoro)",
  office: "a public office (ufficio pubblico)",
  school: "a school (scuola)",
  other: "the person or office the user describes",
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { recipient, message, language } = await req.json();
    if (!message || typeof message !== "string" || message.length > 3000) {
      return json({ error: "bad message" }, 400);
    }
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) return json({ error: "server not configured" }, 500);

    const lang = LANGUAGE_NAMES[language] ?? "English";
    const to = RECIPIENTS[recipient] ?? RECIPIENTS.other;

    const system = `You help immigrants in Italy write letters and emails in Italian.
Write a short, clear and polite letter in correct Italian, addressed to ${to}, based only on what the user wants to say.
Use placeholders in square brackets for missing personal details, e.g. [Nome e cognome], [Indirizzo], [Data]. Never invent facts, names, dates or amounts.
Reply ONLY with a JSON object with two keys:
- "italian": the full letter in Italian.
- "meaning": 1-2 sentences in ${lang} explaining what the letter says.`;

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
        system,
        messages: [{ role: "user", content: message }],
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
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start === -1 || end === -1) return json({ error: "bad_ai_output" }, 502);
    return json(JSON.parse(text.slice(start, end + 1)), 200);
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
