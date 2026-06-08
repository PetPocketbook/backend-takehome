# Plan: Backend Scheduler Core

> Source PRD: `docs/issues/backend-scheduler-core-prd.md`

## Architectural decisions

Durable decisions that apply across all phases:

- **Routes**: Keep the existing API routes: `GET /api/schedule?date=YYYY-MM-DD`, `PUT /api/schedule?date=YYYY-MM-DD`, and `DELETE /api/schedule/:appointmentId?date=YYYY-MM-DD`.
- **Schema**: Keep the existing single-table schedule schema. A **Schedule** has one calendar date and stores **Appointments** in a JSON array.
- **Key models**: A **Schedule** is the set of pet **Appointments** for exactly one calendar date. An **Appointment** is a scheduled visit for one pet at one **Time Slot**.
- **Persistence boundary**: Do not introduce an appointments table. Persist appointments as canonical JSON and expose richer Ruby objects through the backend domain layer.
- **Source of truth**: The upstream PetPocketbook API seeds a date only when no local **Schedule** exists. Once a **Schedule** exists for a date, local persisted data is the source of truth.
- **API contract**: Keep the frontend response shape unchanged: a schedule payload contains the date and an appointments array with stable appointment IDs, nested pet data, and time.
- **Mutation semantics**: `PUT` replaces the full appointment list for the requested date. `DELETE` removes one appointment from an existing **Schedule** and does not seed on cache miss.
- **Validation boundary**: Validate request dates and appointment payloads at application workflow boundaries. Validate normalized upstream appointments before persistence.
- **Service objects**: Workflow services changed in this work should expose simple call interfaces and return lightweight result objects with success, schedule, error, and status information where appropriate.
- **Controller boundary**: Controllers remain responsible for extracting Rails params, applying strong params, invoking workflows, and rendering JSON.
- **Third-party boundary**: The upstream client reflects the provider contract, uses the existing API key fallback, and maps provider/network failures to Bad Gateway behavior.
- **Testing stack**: Use RSpec, FactoryBot, and Shoulda Matchers. Request specs verify API/database behavior; unit specs verify deep modules and service branching.

---

## Phase 1: Test Harness And Fixture Baseline

**User stories**: 31, 32, 35

### What to build

Establish the backend test stack and fixture baseline needed to verify every later slice. The project should have a conventional RSpec setup, factories for persisted **Schedules**, matcher configuration, and a realistic captured upstream schedule fixture that tests can use without calling the live provider.

### Acceptance criteria

- [x] RSpec runs in the backend environment.
- [x] FactoryBot can build and create **Schedules**.
- [x] Shoulda Matchers is configured for Rails specs.
- [x] A realistic upstream PetPocketbook schedule fixture exists for specs.
- [x] The test setup does not call the live upstream provider.

---

## Phase 2: Appointment Value Object And Schedule Persistence

**User stories**: 6, 8, 9, 22, 23, 24, 33, 34

### What to build

Complete the JSON-backed appointment modeling path. **Appointments** should be represented as rich Ruby objects internally, serialize to one canonical API/storage shape, preserve IDs when loaded from storage, and preserve order when exposed from a **Schedule**. Schedule replacement and removal should persist canonical appointment JSON correctly.

### Acceptance criteria

- [x] Upstream appointment data can become local **Appointments** with generated UUIDs.
- [x] Persisted appointment data can become local **Appointments** while preserving IDs.
- [x] **Appointments** serialize to the canonical API/storage shape.
- [x] A **Schedule** exposes ordered appointment records as **Appointment** objects.
- [x] Replacing a **Schedule** persists canonical appointment JSON.
- [x] Removing an appointment updates and persists the **Schedule**.
- [x] Unknown appointment IDs leave an existing **Schedule** unchanged.

---

## Phase 3: Load Or Seed Schedule

**User stories**: 1, 2, 3, 4, 5, 7, 17, 19, 20, 21, 25, 26, 29, 30, 32, 33

### What to build

Implement the `GET /api/schedule?date=YYYY-MM-DD` path end-to-end. A valid request should return an existing **Schedule** or seed a new one from upstream provider data. Appointments created from upstream data during seeding should receive stable UUIDs, be validated before persistence, and become the saved source of truth for later views of that date. Invalid dates and upstream failures should produce clear API failures.

### Acceptance criteria

- [x] A valid date with an existing **Schedule** returns the persisted schedule payload.
- [x] A valid date without a **Schedule** is seeded from the upstream provider.
- [x] Appointments created from upstream data during seeding receive local UUIDs.
- [x] Appointments created from upstream data during seeding are persisted for the requested date.
- [x] Repeated loads for the same date return persisted data rather than reseeding.
- [x] Invalid or impossible request dates fail clearly.
- [x] Upstream network, HTTP, envelope, or malformed appointment failures are mapped to Bad Gateway behavior.
- [x] The service result shape lets the controller render success and failure without owning business branching.

---

## Phase 4: Replace Viewed Schedule

**User stories**: 8, 10, 11, 12, 17, 18, 21, 25, 26, 27, 28, 32, 33

### What to build

Implement the `PUT /api/schedule?date=YYYY-MM-DD` path end-to-end. A valid request should replace the full appointment list for the requested date, preserve submitted appointment IDs, reject invalid payloads, and fix the existing bug where replacements persist to the current date instead of the viewed date.

### Acceptance criteria

- [x] The controller uses strong params for submitted appointments.
- [x] A valid replacement updates the **Schedule** for the requested date.
- [x] Replacements do not accidentally update the current date when another date is viewed.
- [x] A direct replacement can create a **Schedule** for the requested date from the submitted full appointment list.
- [x] Submitted appointment IDs are preserved.
- [x] Invalid dates fail clearly.
- [x] Invalid appointment payloads fail clearly and do not persist bad data.
- [x] The response payload matches the existing frontend API contract.

---

## Phase 5: Remove Appointment From Existing Schedule

**User stories**: 13, 14, 15, 16, 17, 25, 27, 32, 33

### What to build

Implement the `DELETE /api/schedule/:appointmentId?date=YYYY-MM-DD` path end-to-end. A valid request should remove exactly one appointment from an existing **Schedule**, persist that removal across reloads, and treat unknown appointment IDs as an idempotent no-op. Delete should not seed schedules on cache miss.

### Acceptance criteria

- [x] Deleting an existing appointment removes it from the requested **Schedule**.
- [x] The removal persists after reloading the **Schedule** from the database.
- [x] Deleting an unknown appointment ID from an existing **Schedule** returns the unchanged schedule payload.
- [x] Deleting from a date with no **Schedule** returns not found.
- [x] Delete does not seed a new **Schedule**.
- [x] Invalid dates fail clearly.
- [x] The response payload matches the existing frontend API contract.

---

## Phase 6: Assessment Hardening And Verification

**User stories**: 33, 34, 35

### What to build

Verify the completed backend assessment flow and prepare the work for submission. The app should satisfy the README tasks, preserve frontend behavior, and have clear test/manual verification results. Any local environment blockers should be documented rather than hidden.

### Acceptance criteria

- [ ] Backend specs pass in an available Ruby or Docker environment.
- [ ] The app boots through the documented Docker path or any blocker is documented.
- [ ] Manual API checks confirm load, move, delete, and reload persistence behavior.
- [ ] The frontend API contract remains unchanged.
- [ ] The completed work maps cleanly to the README task list.
- [ ] Notes are available for the eventual AI usage disclosure requested by the assessment.
