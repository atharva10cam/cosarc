# Integration Architecture

## Overview
The goal is to migrate the Flutter application's (cosarc_app) "My Gym" module to read and write directly from the ERP application's (cosarc_erp) database, making `cosarc_erp` the single source of truth for all gym-related data.

## The Identity Bridge
Users are authenticated against `cosarc_app`'s Supabase project. `cosarc_erp` does not natively recognize their sessions, and merging the authentication systems is strictly prohibited.
To solve this:
1. **Edge Function (`gym-gateway`)**: A Supabase Edge Function will be created within `cosarc_erp`.
2. **Flutter Integration**: The existing `GymService` in `cosarc_app` will be re-wired to route all requests through a new `GymApiService`, which calls the `gym-gateway` passing the user's `cosarc_app` JWT.
3. **Identity Verification**: Inside `gym-gateway`, the edge function will use `cosarc_app`'s Service Role Key (securely stored as a secret in the ERP) to verify the JWT by interacting with `cosarc_app`'s Auth Admin API.
4. **Data Access**: Upon successful identity verification, the function will act on the `cosarc_erp` database using the ERP's own Service Role Key, processing the request and returning the data formatted exactly to match the Flutter app's existing models.

## Client-Side Architecture
- `GymApiService`: A new API service located in `cosarc_app/lib/services/gym_api_service.dart`. This service exclusively manages the HTTP requests to `gym-gateway`.
- `GymRepository`: Acts as the domain layer boundary.
- `GymService`: The internals of this service will be replaced to delegate all operations to `GymRepository`/`GymApiService`, keeping its public interface completely untouched so that no UI widget needs modification.
