FactoryBot.define do
  factory :schedule do
    date { Date.new(2026, 6, 7) }
    appointments do
      [
        {
          "id" => SecureRandom.uuid,
          "pet" => { "name" => "Briar", "type" => "Hedgehog" },
          "time" => "12:30 PM"
        }
      ]
    end
  end
end
