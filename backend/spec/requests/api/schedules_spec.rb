require "rails_helper"

RSpec.describe "Schedules API", type: :request do
  describe "GET /api/schedule" do
    it "returns an existing Schedule without seeding from the upstream provider" do
      schedule = create(:schedule, date: Date.new(2026, 6, 8))
      allow(ScheduleSeeder).to receive(:new)

      get "/api/schedule", params: { date: "2026-06-08" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "date" => "2026-06-08",
        "appointments" => schedule.appointments
      )
      expect(ScheduleSeeder).not_to have_received(:new)
    end

    it "seeds and persists a missing Schedule from upstream appointments" do
      upstream_payload = JSON.parse(
        Rails.root.join("spec/fixtures/pet_pocketbook/schedule_success.json").read
      )
      client = instance_double(PetPocketbook::Client, fetch_schedule: upstream_payload)
      allow(PetPocketbook::Client).to receive(:new).and_return(client)

      get "/api/schedule", params: { date: "2026-06-09" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      persisted_schedule = Schedule.find_by!(date: Date.new(2026, 6, 9))
      expect(body).to eq(
        "date" => "2026-06-09",
        "appointments" => persisted_schedule.appointments
      )
      expect(body.fetch("appointments").length).to eq(upstream_payload.fetch("appointments").length)
      expect(body.fetch("appointments")).to all(include("id" => a_kind_of(String)))
    end

    it "returns the persisted Schedule after a date has been seeded" do
      upstream_payload = JSON.parse(
        Rails.root.join("spec/fixtures/pet_pocketbook/schedule_success.json").read
      )
      client = instance_double(PetPocketbook::Client)
      allow(client).to receive(:fetch_schedule).and_return(upstream_payload)
      allow(PetPocketbook::Client).to receive(:new).and_return(client)

      get "/api/schedule", params: { date: "2026-06-10" }
      seeded_appointments = JSON.parse(response.body).fetch("appointments")

      get "/api/schedule", params: { date: "2026-06-10" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "date" => "2026-06-10",
        "appointments" => seeded_appointments
      )
      expect(client).to have_received(:fetch_schedule).once
    end

    it "rejects missing request dates without seeding" do
      allow(PetPocketbook::Client).to receive(:new)

      get "/api/schedule"

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(PetPocketbook::Client).not_to have_received(:new)
    end

    it "rejects malformed request dates without seeding" do
      allow(PetPocketbook::Client).to receive(:new)

      get "/api/schedule", params: { date: "tomorrow" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(PetPocketbook::Client).not_to have_received(:new)
    end

    it "rejects impossible request dates without seeding" do
      allow(PetPocketbook::Client).to receive(:new)

      get "/api/schedule", params: { date: "2026-02-30" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(PetPocketbook::Client).not_to have_received(:new)
    end

    it "maps upstream failures to Bad Gateway without persisting a Schedule" do
      client = instance_double(PetPocketbook::Client)
      allow(client).to receive(:fetch_schedule).and_raise(
        PetPocketbook::Client::UpstreamError.new("PetPocketbook is unavailable")
      )
      allow(PetPocketbook::Client).to receive(:new).and_return(client)

      get "/api/schedule", params: { date: "2026-06-11" }

      expect(response).to have_http_status(:bad_gateway)
      expect(JSON.parse(response.body)).to eq("error" => "PetPocketbook is unavailable")
      expect(Schedule.find_by(date: Date.new(2026, 6, 11))).to be_nil
    end
  end

  describe "PUT /api/schedule" do
    it "replaces the Schedule for the requested date" do
      today_schedule = create(:schedule, date: Date.current)
      viewed_schedule = create(:schedule, date: Date.new(2026, 6, 12))
      replacement_appointments = [
        {
          "id" => "moved-appointment",
          "pet" => { "name" => "Briar", "type" => "Hedgehog" },
          "time" => "1:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-06-12", appointments: replacement_appointments }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "date" => "2026-06-12",
        "appointments" => replacement_appointments
      )
      expect(viewed_schedule.reload.appointments).to eq(replacement_appointments)
      expect(today_schedule.reload.appointments).not_to eq(replacement_appointments)
    end

    it "creates a Schedule for the requested date from a valid replacement" do
      replacement_appointments = [
        {
          "id" => "new-schedule-appointment",
          "pet" => { "name" => "Milla", "type" => "Rodent" },
          "time" => "5:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-06-13", appointments: replacement_appointments }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "date" => "2026-06-13",
        "appointments" => replacement_appointments
      )
      expect(Schedule.find_by!(date: Date.new(2026, 6, 13)).appointments).to eq(replacement_appointments)
    end

    it "preserves submitted Appointment IDs when replacing a Schedule" do
      create(:schedule, date: Date.new(2026, 6, 17))
      replacement_appointments = [
        {
          "id" => "submitted-stable-id",
          "pet" => { "name" => "Briar", "type" => "Hedgehog" },
          "time" => "2:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-06-17", appointments: replacement_appointments }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).fetch("appointments")).to eq(replacement_appointments)
      expect(Schedule.find_by!(date: Date.new(2026, 6, 17)).appointments).to eq(replacement_appointments)
    end

    it "rejects missing request dates without replacing a Schedule" do
      replacement_appointments = [
        {
          "id" => "missing-date-appointment",
          "pet" => { "name" => "Milla", "type" => "Rodent" },
          "time" => "5:00 PM"
        }
      ]

      put "/api/schedule", params: { appointments: replacement_appointments }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(Schedule.count).to eq(0)
    end

    it "rejects malformed request dates without replacing a Schedule" do
      replacement_appointments = [
        {
          "id" => "malformed-date-appointment",
          "pet" => { "name" => "Milla", "type" => "Rodent" },
          "time" => "5:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "tomorrow", appointments: replacement_appointments }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(Schedule.count).to eq(0)
    end

    it "rejects impossible request dates without replacing a Schedule" do
      replacement_appointments = [
        {
          "id" => "invalid-date-appointment",
          "pet" => { "name" => "Milla", "type" => "Rodent" },
          "time" => "5:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-02-30", appointments: replacement_appointments }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Missing or invalid `date` query param (expected YYYY-MM-DD)."
      )
      expect(Schedule.count).to eq(0)
    end

    it "rejects invalid appointment payloads without replacing a Schedule" do
      schedule = create(:schedule, date: Date.new(2026, 6, 14))
      original_appointments = schedule.appointments
      invalid_appointments = [
        {
          "id" => "invalid-appointment",
          "pet" => { "name" => "Milla", "type" => "Dragon" },
          "time" => "5:00 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-06-14", appointments: invalid_appointments }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => 'Appointment invalid-appointment pet.type "Dragon" is not allowed.'
      )
      expect(schedule.reload.appointments).to eq(original_appointments)
    end

    it "persists only permitted appointment fields from submitted appointments" do
      submitted_appointments = [
        {
          "id" => "permitted-appointment",
          "pet" => { "name" => "Briar", "type" => "Hedgehog", "secret" => "ignored" },
          "time" => "12:30 PM",
          "secret" => "ignored"
        }
      ]
      permitted_appointments = [
        {
          "id" => "permitted-appointment",
          "pet" => { "name" => "Briar", "type" => "Hedgehog" },
          "time" => "12:30 PM"
        }
      ]

      put "/api/schedule", params: { date: "2026-06-15", appointments: submitted_appointments }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "date" => "2026-06-15",
        "appointments" => permitted_appointments
      )
      expect(Schedule.find_by!(date: Date.new(2026, 6, 15)).appointments).to eq(permitted_appointments)
    end

    it "rejects requests without an appointments array" do
      schedule = create(:schedule, date: Date.new(2026, 6, 16))
      original_appointments = schedule.appointments

      put "/api/schedule", params: { date: "2026-06-16" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq(
        "error" => "Body must include an `appointments` array."
      )
      expect(schedule.reload.appointments).to eq(original_appointments)
    end
  end
end
