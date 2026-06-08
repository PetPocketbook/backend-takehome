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
end
