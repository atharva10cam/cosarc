# My Gym Data Flow & Resolution

This document explains how identity and data flow across the monorepo for the My Gym module.

## 1. Identity Verification Flow (JWKS)
When a user opens the My Gym tab in `cosarc_app`:
1. `GymApiService` constructs an HTTP POST request to the `gym-gateway` edge function.
2. The user's `cosarc_app` JWT is attached in the `Authorization` header.
3. The `gym-gateway` fetches the public JSON Web Key Set (JWKS) from `cosarc_app`'s Supabase auth endpoint (`/auth/v1/.well-known/jwks.json`).
4. The edge function cryptographically verifies the `ES256` signature of the JWT using the retrieved public key. This establishes trust without requiring any shared secret keys between the two distinct Supabase projects.

## 2. Identity Mapping Resolution
Once the JWT is verified, the user's `sub` (`cosarc_app_user_id`) and `email` are extracted.
The gateway maps this local identity to a `cosarc_erp` identity using the `external_identity_map` table:
- **Fast Path**: It queries `external_identity_map` by `cosarc_app_user_id`. If a link exists, it uses the mapped `erp_member_id`.
- **Fallback Match**: It queries the ERP `members` table by normalized `email`. If matched, it automatically inserts a new link into `external_identity_map` and proceeds with the found `erp_member_id`.
- **No Match (Empty State)**: The gateway interprets this as the user not having any gym membership. It returns `null` or empty lists to the Flutter UI, which natively renders the "Join a Gym" empty state.

## 3. Data Adaptation Layer
The `gym-gateway` reads strictly from the canonical tables in the `cosarc_erp` database (e.g., `members`, `attendance`, `classes`, `class_bookings`, etc.).
Before returning the response to Flutter, the edge function formats the JSON payload to exactly match the DTO structures expected by `cosarc_app`'s models (e.g., nesting trainer objects, mapping `check_in` to `check_in_time`). This ensures that neither the Flutter widgets nor the core ERP schema required any naming modifications to accommodate the integration.
