# Backend Scheduler Core PRD

Triage label: `ready-for-agent`

## Problem Statement

The PetPocketbook Scheduler frontend is already capable of loading a daily **Schedule**, moving **Appointments** between **Time Slots**, and deleting **Appointments**, but the Rails backend still contains stubs and one persistence bug. As a user of the scheduler, I need each viewed date to load reliably, persist changes for the correct **Schedule**, and survive page reloads after moves or deletes.

The implementation should complete the assessment's backend requirements while using small, expressive Rails objects that make the daily scheduling domain easy to test and discuss in an interview.

## Solution

Implement the backend workflows for loading, seeding, replacing, and removing **Appointments** from a daily **Schedule**. A **Schedule** is created from the upstream PetPocketbook schedule only on cache miss; once persisted, that date's **Schedule** becomes the source of truth for later views and changes.

The Rails API will continue to expose the existing frontend contract:

- `GET /api/schedule?date=YYYY-MM-DD` loads an existing **Schedule** or seeds one from the upstream provider.
- `PUT /api/schedule?date=YYYY-MM-DD` replaces the full appointment list for the requested date.
- `DELETE /api/schedule/:appointmentId?date=YYYY-MM-DD` removes one **Appointment** from an existing **Schedule**.

The solution will keep the frontend behavior and schema stable, use the existing JSON-backed persistence model, and introduce a few deep backend modules with simple interfaces: an **Appointment** value object, a shared schedule-date parser, service objects for load/replace workflows, and request specs that verify the database is updated end-to-end.

## User Stories

1. As a scheduler user, I want to open today's **Schedule**, so that I can see the pet **Appointments** planned for today.
2. As a scheduler user, I want to open a **Schedule** for another calendar date, so that I can plan work beyond today.
3. As a scheduler user, I want a date with no saved **Schedule** to be initialized from PetPocketbook, so that I see useful starter appointments instead of an empty or broken page.
4. As a scheduler user, I want the first view of a date to create that date's **Schedule**, so that later edits have a stable local source of truth.
5. As a scheduler user, I want repeated views of the same date to return the saved **Schedule**, so that my previous moves and deletes are preserved.
6. As a scheduler user, I want each **Appointment** to have a stable identity, so that dragging and deleting the appointment affects the right pet visit.
7. As a scheduler user, I want upstream PetPocketbook appointments to receive local UUIDs, so that appointments without provider IDs can still be tracked by the app.
8. As a scheduler user, I want appointment IDs to be preserved after moving between **Time Slots**, so that the app does not treat a move as a new appointment.
9. As a scheduler user, I want appointment IDs to be preserved across page reloads, so that drag/drop state remains consistent.
10. As a scheduler user, I want to drag an **Appointment** to a different **Time Slot**, so that I can adjust the day's schedule.
11. As a scheduler user, I want moved appointments to persist for the date I am viewing, so that changing tomorrow's schedule does not accidentally update today's schedule.
12. As a scheduler user, I want moving an appointment to replace the full **Schedule** state for that date, so that the server mirrors the frontend's complete schedule view.
13. As a scheduler user, I want to delete an **Appointment**, so that removed pet visits no longer appear on the **Schedule**.
14. As a scheduler user, I want deleted appointments to stay deleted after a page reload, so that the app does not only update the temporary response body.
15. As a scheduler user, I want deleting an already-absent **Appointment** to leave the **Schedule** unchanged, so that repeated delete attempts are harmless.
16. As a scheduler user, I want deleting from a date with no saved **Schedule** to fail clearly, so that the app does not create unexpected schedules through a delete action.
17. As a scheduler user, I want invalid request dates to fail clearly, so that the app does not save appointments under ambiguous or impossible dates.
18. As a scheduler user, I want malformed appointment submissions to fail clearly, so that bad data is not persisted into a **Schedule**.
19. As a scheduler user, I want upstream provider failures to be reported as backend gateway failures, so that the frontend can distinguish provider issues from local appointment validation issues.
20. As a scheduler user, I want malformed upstream appointment data to be rejected before persistence, so that bad provider data does not become the saved truth for a date.
21. As a scheduler user, I want valid pet types and **Time Slots** enforced consistently, so that the frontend can safely render avatars and schedule buckets.
22. As a backend maintainer, I want **Appointments** represented as rich Ruby objects internally, so that schedule behavior is easier to reason about than raw nested hashes.
23. As a backend maintainer, I want persisted appointment JSON to have one canonical shape, so that API responses and database contents stay consistent.
24. As a backend maintainer, I want **Appointments** in a **Schedule** to preserve display order, so that replacements and reloads do not unexpectedly reorder the schedule.
25. As a backend maintainer, I want date validation shared across schedule workflows, so that load, replace, and remove behavior do not diverge.
26. As a backend maintainer, I want service objects to return rich result objects, so that controllers can render success and failure without owning business branching.
27. As a backend maintainer, I want controllers to keep responsibility for request params and rendering, so that service objects are not coupled to Rails controller internals.
28. As a backend maintainer, I want Rails strong params for appointment submissions, so that request-shape handling follows Rails convention.
29. As a backend maintainer, I want the upstream client to reflect the provider contract accurately, so that business services decide what to do with provider data.
30. As a backend maintainer, I want upstream HTTP failures mapped to a consistent application error, so that controller error handling remains simple.
31. As a backend maintainer, I want service unit tests to run with doubles where appropriate, so that business branching is fast to verify.
32. As a backend maintainer, I want request specs to hit the Rails API and database together, so that persistence behavior is proven at the application boundary.
33. As a take-home reviewer, I want the implementation to complete the stated backend tasks, so that the submitted app satisfies the assessment rubric.
34. As a take-home reviewer, I want the implementation to show thoughtful but restrained refactoring, so that the candidate's design judgment is visible without unnecessary churn.
35. As a take-home reviewer, I want tests around the important workflows, so that regressions in schedule loading, moves, and deletes are easy to catch.

## Implementation Decisions

- Keep the existing frontend API contract unchanged.
- Keep the existing database schema unchanged: a **Schedule** stores its **Appointments** in a JSON column.
- Do not introduce an appointments table. The current app replaces whole-day appointment lists, and the README explicitly asks for a value object plus JSON persistence.
- Treat a **Schedule** as the set of pet **Appointments** for exactly one calendar date.
- Treat the upstream PetPocketbook schedule as a seed source for dates that do not yet have a local **Schedule**.
- Once a **Schedule** exists for a date, use local persisted data as the source of truth for that date.
- Implement **Appointment** as a plain Ruby value object with constructors for upstream data and persisted storage data.
- Assign UUIDs to upstream appointments only during initial seeding.
- Preserve appointment IDs when loading from storage and when replacing a **Schedule**.
- Serialize **Appointments** into one canonical API/storage shape with an `id`, nested `pet` object, and `time`.
- Have the **Schedule** expose ordered appointment records as **Appointment** objects rather than leaking raw JSON hashes throughout the domain layer.
- Fix appointment removal so that it assigns the filtered appointment list back to the **Schedule** and persists the change.
- Make appointment removal idempotent for unknown appointment IDs when the **Schedule** exists.
- Return `404` when deleting from a date with no saved **Schedule**.
- Do not seed a **Schedule** from a `DELETE` request.
- Use `PUT` as full replacement semantics. A direct `PUT` to a date with no **Schedule** may create a **Schedule** from the submitted appointment list without fetching upstream.
- Fix the existing replacement bug by persisting replacements to the requested date, not the current date.
- Keep validation at application boundaries. The replace workflow validates submitted appointments; the seed workflow validates normalized upstream appointments before persistence.
- Reuse the existing appointment validation rules for normalized upstream data instead of creating a separate upstream validator unless future provider-specific rules appear.
- Refactor the existing appointment validator enough to improve readability, but do not split it into multiple classes or add a new validation framework.
- Add a shared schedule-date parser that accepts raw date strings, validates them as ISO calendar dates, and returns a normalized date or a failure reason.
- Move load behavior into a load service that validates the date, returns an existing **Schedule**, or seeds on cache miss.
- Move replace behavior into a replace service that validates the date and appointment list, replaces the full **Schedule**, and returns a result.
- Service objects changed in this work should return rich local result objects with success status, schedule, error, and HTTP status information where appropriate.
- Keep result objects local and lightweight rather than introducing a global service framework.
- Keep controllers responsible for extracting params, applying strong params, invoking services, and rendering JSON.
- Use Rails strong params for appointment request bodies rather than custom unsafe-hash conversion.
- Keep destroy controller-level for now because it has not accumulated enough responsibility to justify a dedicated service object.
- Implement the upstream client using the existing provider URL, API-key fallback, and Faraday JSON connection.
- Add dependency injection for the upstream client's Faraday connection so it can be unit-tested with doubles.
- Map upstream network failures, non-success responses, malformed response envelopes, and missing appointment arrays to Bad Gateway failures.
- Do not pass a date to the upstream provider because the documented provider endpoint does not accept a date.
- Capture one real successful upstream response as a committed fixture for tests.
- Do not make automated tests call the live upstream provider.
- Avoid frontend refactors unless a backend contract issue is discovered.
- Avoid large architectural changes such as repositories, persistence redesign, or app-wide service frameworks.
- No ADR is required at this stage because the decisions are either assignment-driven, easy to reverse, or unsurprising given the existing stubs and schema.

## Testing Decisions

- Add RSpec rather than Minitest because the preferred Rails test stack for this work is RSpec, FactoryBot, and Shoulda Matchers.
- Add FactoryBot for concise persisted **Schedule** setup.
- Add Shoulda Matchers for Rails model validation expectations where useful.
- Good tests should verify externally observable behavior and stable object contracts, not private implementation details.
- Request specs should exercise the Rails API and database together, because they prove that **Schedules** are created, replaced, and mutated persistently.
- Unit specs should use stubs and doubles for service collaborators where that keeps tests fast and focused.
- Request specs should stub the upstream client using a realistic fixture rather than hitting the live provider.
- The upstream fixture should be captured manually once from the real provider and committed under the spec fixtures area.
- Client specs should use instance doubles for Faraday connection and response objects rather than WebMock.
- Test the schedule-date parser for valid ISO dates, missing dates, malformed dates, and impossible calendar dates.
- Test the **Appointment** value object for upstream construction with UUID assignment, storage construction with ID preservation, and canonical serialization.
- Test the **Schedule** model for ordered appointment records, full replacement persistence, and removal persistence.
- Test the load service for returning existing **Schedules**, seeding on cache miss, invalid date failures, and upstream failure mapping.
- Test the replace service for invalid date failures, appointment validation failures, full replacement behavior, and result object behavior.
- Test the API request for `GET` seeding on cache miss and persisting the newly seeded **Schedule**.
- Test that repeated `GET` requests for the same date return the persisted **Schedule** rather than reseeding from upstream.
- Test that `GET` maps upstream failures to Bad Gateway.
- Test that `PUT` replaces appointments for the requested date.
- Test that `PUT` does not accidentally persist moves to the current date when a different date is being viewed.
- Test that `PUT` rejects invalid appointment payloads.
- Test that `DELETE` removes exactly one **Appointment** and persists the removal after reload.
- Test that `DELETE` for an unknown appointment ID returns the unchanged **Schedule** with success.
- Test that `DELETE` for a missing **Schedule** returns not found.
- There is no existing test prior art in the repository, so the new specs should establish the convention for future backend tests.

## Out of Scope

- Frontend refactors or visual changes.
- Changing the public API shape consumed by the React frontend.
- Replacing JSON appointment persistence with a normalized appointments table.
- Adding appointment creation flows beyond seeding from the upstream provider.
- Adding partial-update semantics for moves; `PUT` remains full replacement.
- Making `DELETE` seed schedules on cache miss.
- Making automated tests depend on live upstream network calls.
- Adding WebMock or other HTTP-stubbing gems beyond the agreed RSpec, FactoryBot, and Shoulda Matchers stack.
- Introducing a global service-object framework or broad Rails app restructuring.
- Adding ADRs unless later implementation uncovers a hard-to-reverse, surprising trade-off.

## Further Notes

- The implementation should use the domain language from the glossary: **Schedule**, **Appointment**, and **Time Slot**.
- The assessment README asks for an AI usage disclosure in the eventual PR. This PRD does not create that disclosure, but implementation should preserve enough notes or transcripts to write it accurately.
- Local non-Docker Ruby verification may be blocked if Ruby 3.1.2 is not installed. Docker remains the documented app runtime.
- The current branch is already `takehome-implementation`.
- There was an existing working-tree modification to the Docker entrypoint before implementation planning began; it should not be reverted unless explicitly requested.
