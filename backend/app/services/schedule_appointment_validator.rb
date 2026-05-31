class ScheduleAppointmentValidator
  ALLOWED_PET_TYPES = %w[Dog Cat Bird Rabbit Hedgehog Turtle Rodent].freeze
  TIME_SLOT_PATTERN = /\A(1[0-2]|[1-9]):(00|30) (AM|PM)\z/

  def self.error_message(appointments)
    new(appointments).error_message
  end

  def initialize(appointments)
    @appointments = appointments
  end

  def error_message
    return "Body must include an `appointments` array." unless @appointments.is_a?(Array)

    seen_ids = {}
    @appointments.each_with_index do |appointment, index|
      return "Appointment at index #{index} is not an object." unless appointment.respond_to?(:[])

      id = appointment["id"] || appointment[:id]
      return "Appointment at index #{index} is missing a string `id`." unless id.is_a?(String) && !id.empty?

      if seen_ids[id]
        return %(Duplicate appointment id "#{id}".)
      end
      seen_ids[id] = true

      pet = appointment["pet"] || appointment[:pet]
      return "Appointment #{id} is missing a `pet` object." unless pet.respond_to?(:[])

      pet_name = pet["name"] || pet[:name]
      pet_type = pet["type"] || pet[:type]
      return "Appointment #{id} pet.name must be a non-empty string." unless pet_name.is_a?(String) && !pet_name.empty?

      unless valid_pet_type?(pet_type)
        return %(Appointment #{id} pet.type "#{pet_type}" is not allowed.)
      end

      time = appointment["time"] || appointment[:time]
      unless valid_time?(time)
        return %(Appointment #{id} time "#{time}" is not a 30-min slot between 8:00 AM and 6:00 PM.)
      end
    end

    nil
  end

  def valid_pet_type?(type)
    type.is_a?(String) && ALLOWED_PET_TYPES.include?(type)
  end

  def valid_time?(time)
    time.is_a?(String) && time.match?(TIME_SLOT_PATTERN)
  end
end
