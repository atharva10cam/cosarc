# Database Boundary

## cosarc_app Database (Flutter App)
- **Role**: Continues to act as the primary database for user profiles, Cosmos, Nutrition, Community, AI, settings, and authentication.
- **My Gym Tables**: The existing tables (`gyms`, `gym_memberships`, `gym_attendance`, `gym_classes`, `class_bookings`, `trainers`, etc.) within `cosarc_app` will become dormant. They will no longer be queried or updated by the client.

## cosarc_erp Database (ERP Web App)
- **Role**: Becomes the Single Source of Truth for everything gym-related.
- **Schema Evolution**: The `cosarc_erp` `schema.sql` currently features CRM tables (`members`, `attendance`, `payments`, etc.) tailored to a simpler setup. To support the full robust functionality expected by the app (multi-gym support, classes, challenges, leaderboards, alerts), we will need to inject the required `My Gym` table structures into the `cosarc_erp` database.
- **Data Access Boundary**: No `cosarc_app` user will ever have direct anon-level write access to member-specific ERP tables. Member-specific reads and writes are securely brokered exclusively through the `gym-gateway` Edge Function using Service Role permissions internally.
