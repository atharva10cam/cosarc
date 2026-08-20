import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const client = new Client("postgresql://postgres:cosarc_erp@123@db.ccmalnekezlebsqxxlds.supabase.co:5432/postgres");

async function main() {
  try {
    await client.connect();
    console.log("Connected to DB!");
    const result = await client.queryArray("SELECT count(*) FROM members;");
    console.log("Members count:", result.rows);
    
    try {
      const extResult = await client.queryArray("SELECT count(*) FROM external_identity_map;");
      console.log("external_identity_map count:", extResult.rows);
    } catch (e) {
      console.log("external_identity_map missing!", e.message);
      const schemaSql = await Deno.readTextFile("/Users/atharva/cosarc/cosarc_erp/schema.sql");
      await client.queryArray(schemaSql);
      console.log("Executed schema.sql successfully.");
    }
    
  } catch (err) {
    console.error("DB Error:", err);
  } finally {
    await client.end();
  }
}
main();
