class Appointment
  attr_reader :id, :pet_name, :pet_type, :time

  def initialize(id:, pet_name:, pet_type:, time:)
    @id = id
    @pet_name = pet_name
    @pet_type = pet_type
    @time = time
  end

  def self.from_upstream(raw)
    pet = raw.fetch("pet")

    new(
      id: SecureRandom.uuid,
      pet_name: pet.fetch("name"),
      pet_type: pet.fetch("type"),
      time: raw.fetch("time")
    )
  end

  def self.from_storage(raw)
    pet = raw.fetch("pet")

    new(
      id: raw.fetch("id"),
      pet_name: pet.fetch("name"),
      pet_type: pet.fetch("type"),
      time: raw.fetch("time")
    )
  end

  def to_h
    {
      "id" => id,
      "pet" => { "name" => pet_name, "type" => pet_type },
      "time" => time
    }
  end
end
