class Appointment
  attr_reader :id, :pet_name, :pet_type, :time

  def initialize(id:, pet_name:, pet_type:, time:)
    @id = id
    @pet_name = pet_name
    @pet_type = pet_type
    @time = time
  end

  def self.from_upstream(raw)
    raise NotImplementedError
  end

  def self.from_storage(raw)
    raise NotImplementedError
  end

  def to_h
    raise NotImplementedError
  end
end
