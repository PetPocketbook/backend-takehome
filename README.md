# PetPocketbook Scheduler — take-home exercise

Welcome to the PetPocketbook backend take-home!

In this exercise, we've set up a Docker-based app with a Rails backend and React front end that's setup as as a basic scheduler for pets.  Your mission will be to complete some rails logic so the app runs smoothly.  The work should take you 4 hours - and if you don't finish then just document what you'd plan to do later if you were to work on this more.

Do all work on a **new branch**. When ready, open a pull request.

## First, an AI usage disclosure

It's 2026 - you may use AI tools. If you do, include a brief write-up in your PR describing:

* Which tools you used (IDE-integrated vs browser/app-based)
* How you used them (plan/ask/agent modes, debugging vs implementation, etc.)
* What you implemented yourself vs AI-assisted, and roughly what percentage was AI-assisted

Include exported chat transcripts or prompts in your branch. Using AI will not negatively affect evaluation - and sharing your prompting will help us understand how you use it - a key skill in itself.

## Here's what you need to do

Implement the stubs in these files. The app should boot and serve the frontend. Seeding, schedule moves, and deletes depend on your work.

| Number | Task | File(s) | Notes |
| --- | ---|---|---|
| 1 | Upstream API client | `backend/app/services/pet_pocketbook/client.rb` | Fetch upstream schedule; map errors to 502 |
| 2 | Schedule seeder | `backend/app/services/schedule_seeder.rb` | Seed a day on cache miss |
| 3 | DELETE endpoint | `backend/app/controllers/api/schedules_controller.rb#destroy` | Remove one appointment for a date |
| 4 | Domain modeling | `backend/app/models/appointment.rb`, `Schedule#remove_appointment!`, `Schedule#appointment_records` | Value object + persistence |
| 5 | Fix persistence bug | `backend/app/controllers/api/schedules_controller.rb#update` | Moves should persist for the **viewed** date |

** Here's an API key for the PetPocketbook API: ** `jQkI63suJhqd3DtL`
** We've already done: ** `Schedule#replace_appointments`, validation in `ScheduleAppointmentValidator`, routes, and the full React UI.
** Hint: ** After wiring DELETE, verify removal with a page reload — not only the JSON response body.

## Here's the API you'll implement with these tasks

* `GET    /api/schedule?date=YYYY-MM-DD` — load or seed a day
* `PUT    /api/schedule?date=YYYY-MM-DD` — replace appointments (drag-to-move)
* `DELETE /api/schedule/:appointmentId?date=YYYY-MM-DD` — remove one appointment

## Here's a gist of the app's features/purpose
1. It's a schedule, with pet appointments.
2. If we're adding a new appointment for any day without a saved schedule, we'll initialize one from the PetPocketbook upstream API.
3. We persist and return that schedule whenever someone views the same day.
4. We let the user pick which date to view (default: today).
5. We show a schedule for the day.
   * Pet avatar images reflect appointment pet type (`backend/public/images/`)
6. The user can drag and drop appointments between time slots
7. The user can delete an appointment by dragging it to the trash icon (desktop only; no trash on mobile)

## How to get the app running

Start docker.

```bash
docker compose up --build
```

Open `http://localhost:3000`

### PetPocketbook upstream API

```
GET https://candidate.petpocketbook.com/schedule?api_key=<your key>
```

Response shape:

```json
{
  "appointments": [
    {
      "pet": { "name": "Briar", "type": "Hedgehog" },
      "time": "12:30 PM"
    }
  ]
}
```

Allowed pet types: `Dog`, `Cat`, `Bird`, `Rabbit`, `Hedgehog`, `Turtle`, `Rodent`  
Times: 30-minute increments from `8:00 AM` through `6:00 PM`

Assign a UUID `id` to each appointment when seeding from upstream (upstream rows have no id).