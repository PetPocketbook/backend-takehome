require "rails_helper"

RSpec.describe Appointment do
  describe ".from_upstream" do
    it "builds a local Appointment from an upstream appointment" do
      uuid_pattern = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/

      appointment = described_class.from_upstream(
        "pet" => { "name" => "Briar", "type" => "Hedgehog" },
        "time" => "12:30 PM"
      )

      expect(appointment.to_h).to match(
        "id" => match(uuid_pattern),
        "pet" => { "name" => "Briar", "type" => "Hedgehog" },
        "time" => "12:30 PM"
      )
    end
  end

  describe ".from_storage" do
    it "builds a local Appointment from a persisted appointment" do
      appointment = described_class.from_storage(
        "id" => "persisted-appointment-id",
        "pet" => { "name" => "Milla", "type" => "Rodent" },
        "time" => "5:00 PM"
      )

      expect(appointment.to_h).to eq(
        "id" => "persisted-appointment-id",
        "pet" => { "name" => "Milla", "type" => "Rodent" },
        "time" => "5:00 PM"
      )
    end
  end
end
