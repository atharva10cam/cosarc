import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts"

serve(async (req) => {
  try {
    const { sql, password } = await req.json();
    if (password !== 'cosarc_erp@123') throw new Error('Unauthorized');

    const client = new Client("postgresql://postgres:cosarc_erp@123@db.ccmalnekezlebsqxxlds.supabase.co:5432/postgres");
    await client.connect();
    
    await client.queryArray(sql);
    await client.end();
    
    return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' }});
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 400 });
  }
})
