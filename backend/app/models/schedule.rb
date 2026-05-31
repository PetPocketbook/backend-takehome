class Schedule < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :appointments, presence: true

  def self.find_for_date!(date_string)
    find_by!(date: date_string)
  end

  def self.find_for_date(date_string)
    find_by(date: date_string)
  end

  def appointment_records
    raise NotImplementedError
  end

  def replace_appointments(appointment_values)
    records = Array(appointment_values).map { |value| coerce_appointment(value) }
    self.appointments = records.map(&:to_h)
    save!
    self
  end

  def remove_appointment!(appointment_id)
    appointments = appointments.reject { |appointment| appointment["id"] == appointment_id }
    save!
    self
  end

  private

  def coerce_appointment(value)
    return value if value.is_a?(Appointment)

    Appointment.from_storage(value)
  end
end
