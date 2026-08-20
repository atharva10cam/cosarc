# Deployment Guide (Monorepo Integration)

## 1. Database Migrations
Run the updated `schema.sql` on your `cosarc_erp` Supabase project to ensure all required canonical tables and junction maps are present:
- `external_identity_map`
- `gyms`
- `classes` & `class_bookings`
- `trainer_sessions`
- `alerts`, `challenges`, `badges`, `member_badges`

*(This also seeds the test gym "Erande's Arena" with gym code `ERANDE123`).*

## 2. Edge Function Deployment
The `gym-gateway` resides in `cosarc_erp/supabase/functions/gym-gateway`.
It requires the `cosarc_app` URL to dynamically fetch the JWKS for secure JWT verification.

```bash
# From the cosarc_erp directory:

# 1. Set the cross-app URL secret
supabase secrets set CROSS_APP_URL="https://lgblxxixgldizfidscpz.supabase.co"

# 2. Deploy the edge function
# Note: --no-verify-jwt is required because this function implements its own cross-project 
# JWT verification using JWKS rather than relying on the ERP's default Auth mechanism.
supabase functions deploy gym-gateway --no-verify-jwt
```

*Note: Since the edge function leverages JWKS (ES256), the `CROSS_APP_SERVICE_KEY` shared secret is no longer required.*

## 3. Testing the Integration
To test the end-to-end flow:
1. Open the Flutter app and navigate to "My Gym".
2. Because the user is not in the `external_identity_map`, the empty state will appear natively.
3. Enter `ERANDE123` to join.
4. The gateway will automatically create a member record in the ERP, insert a link in the `external_identity_map`, and approve the membership.
5. The UI will instantly unlock. Real-time data (attendance, classes) will now pull directly from the `cosarc_erp` database without any further configuration.
