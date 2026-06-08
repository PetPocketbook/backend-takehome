require "rails_helper"

RSpec.describe Schedule, type: :model do
  subject(:schedule) { build(:schedule) }

  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:appointments) }
  it { should validate_uniqueness_of(:date) }

  it "builds a valid Schedule factory" do
    expect(schedule).to be_valid
  end

  it "creates a persisted Schedule factory" do
    persisted_schedule = create(:schedule)

    expect(persisted_schedule).to be_persisted
    expect(persisted_schedule.appointments).to contain_exactly(
      a_hash_including(
        "id" => a_kind_of(String),
        "pet" => { "name" => "Briar", "type" => "Hedgehog" },
        "time" => "12:30 PM"
      )
    )
  end

  describe "#appointment_records" do
    it "returns persisted Appointments in Schedule order" do
      schedule = build(
        :schedule,
        appointments: [
          {
            "id" => "first-appointment",
            "pet" => { "name" => "Briar", "type" => "Hedgehog" },
            "time" => "12:30 PM"
          },
          {
            "id" => "second-appointment",
            "pet" => { "name" => "Milla", "type" => "Rodent" },
            "time" => "5:00 PM"
          }
        ]
      )

      expect(schedule.appointment_records.map(&:to_h)).to eq(schedule.appointments)
    end
  end

  describe "#replace_appointments" do
    it "persists canonical appointment JSON" do
      schedule = create(:schedule)
      appointment = Appointment.new(
        id: "replacement-appointment",
        pet_name: "Briar",
        pet_type: "Hedgehog",
        time: "12:30 PM"
      )

      schedule.replace_appointments([appointment])

      expect(schedule.reload.appointments).to eq(
        [
          {
            "id" => "replacement-appointment",
            "pet" => { "name" => "Briar", "type" => "Hedgehog" },
            "time" => "12:30 PM"
          }
        ]
      )
    end
  end

  describe "#remove_appointment!" do
    it "persists the Schedule without the removed Appointment" do
      remaining_appointment = {
        "id" => "remaining-appointment",
        "pet" => { "name" => "Milla", "type" => "Rodent" },
        "time" => "5:00 PM"
      }
      schedule = create(
        :schedule,
        appointments: [
          {
            "id" => "removed-appointment",
            "pet" => { "name" => "Briar", "type" => "Hedgehog" },
            "time" => "12:30 PM"
          },
          remaining_appointment
        ]
      )

      schedule.remove_appointment!("removed-appointment")

      expect(schedule.reload.appointments).to eq([remaining_appointment])
    end

    it "leaves the Schedule unchanged for an unknown Appointment ID" do
      schedule = create(:schedule)
      original_appointments = schedule.appointments

      schedule.remove_appointment!("unknown-appointment")

      expect(schedule.reload.appointments).to eq(original_appointments)
    end
  end
end
