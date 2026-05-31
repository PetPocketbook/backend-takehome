# PetPocketbook Scheduler — take-home exercise

Rails 7 API + React frontend. The **frontend is complete**; your work is on the **Rails backend** (~4 hours).

Do all work on a **new branch**. When ready, open a pull request.

## AI usage disclosure

You may use AI tools. If you do, include a brief write-up in your PR describing:

* Which tools you used (IDE-integrated vs browser/app-based)
* How you used them (plan/ask/agent modes, debugging vs implementation, etc.)
* What you implemented yourself vs AI-assisted, and roughly what percentage was AI-assisted

Include exported chat transcripts or prompts in your branch. Using AI will not negatively affect evaluation.

## Features / requirements

1. For any day without a saved schedule, initialize one from the PetPocketbook upstream API
2. Persist and return that schedule whenever someone views the same day
3. Let the user pick which date to view (default: today)
4. Show a schedule for the day (see wireframes below)
   * Pet avatar images reflect appointment pet type (`backend/public/images/`)
5. Drag and drop appointments between time slots
6. Mobile-friendly layout (see wireframes)
7. Delete an appointment by dragging it to the trash icon (desktop only; no trash on mobile)

**API key:** `jQkI63suJhqd3DtL`

## Backend tasks (your scope)

Implement the stubs in these files. The app should boot and serve the frontend; seeding, moves, and deletes depend on your work.

| Task | File(s) | Notes |
|---|---|---|
| Upstream API client | `backend/app/services/pet_pocketbook/client.rb` | Fetch upstream schedule; map errors to 502 |
| Schedule seeder | `backend/app/services/schedule_seeder.rb` | Seed a day on cache miss |
| DELETE endpoint | `backend/app/controllers/api/schedules_controller.rb#destroy` | Remove one appointment for a date |
| Domain modeling | `backend/app/models/appointment.rb`, `Schedule#remove_appointment!`, `Schedule#appointment_records` | Value object + persistence |
| Fix persistence bug | `backend/app/controllers/api/schedules_controller.rb#update` | Moves should persist for the **viewed** date |

**Already provided (working):** `Schedule#replace_appointments`, validation in `ScheduleAppointmentValidator`, routes, and the full React UI.

**Hint:** After wiring DELETE, verify removal with a page reload — not only the JSON response body.

## Wireframes

You may change the design; be ready to explain why.

![Desktop wireframe](/backend/public/Desktop_Wireframe.png?raw=true)

* Sticky date header and sidebar while scrolling
* Prev/next arrows change the day
* 30-minute slots from 8:00 AM – 6:00 PM
* Overflow wraps to the next line when a slot is full

![Mobile wireframe](/backend/public/Mobile_Wireframe.png?raw=true)

* No trash drag target on mobile
* Calendar icon in the header opens date picker

## How to run

```bash
cd backend && bundle install && bin/rails db:prepare && cd ..
npm run frontend:install
bin/dev
```

Open `http://localhost:5173` (Vite dev server proxies API calls to Rails on port 3000).

Production-style (built SPA served by Rails):

```bash
npm run start:prod
```

## API (implemented by you)

* `GET    /api/schedule?date=YYYY-MM-DD` — load or seed a day
* `PUT    /api/schedule?date=YYYY-MM-DD` — replace appointments (drag-to-move)
* `DELETE /api/schedule/:appointmentId?date=YYYY-MM-DD` — remove one appointment

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

## Deployed reference API

_(Interviewer: add the Render URL for the fully working solution repo here.)_

## Time budget

* **Target:** ~4 hours
* If you run over, note in your PR how you would finish remaining tasks
