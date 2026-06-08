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
  end
end
