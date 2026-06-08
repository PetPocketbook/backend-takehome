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
end
