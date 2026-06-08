class ScheduleReplacer
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

  Result = Struct.new(:success, :schedule, :error, :status, keyword_init: true) do
    def success?
      success
    end
  end

  def initialize(date:, appointments:)
    @raw_date = date
    @appointments = appointments
  end

  def call
    return invalid_date_result unless valid_date?
    return invalid_appointments_result if appointment_error

    Result.new(success: true, schedule: replace_schedule)
  end

  private

  attr_reader :raw_date, :appointments

  def valid_date?
    raw_date.to_s.match?(DATE_PATTERN) && Date.iso8601(raw_date.to_s)
  rescue ArgumentError
    false
  end

  def appointment_error
    @appointment_error ||= ScheduleAppointmentValidator.error_message(appointments)
  end

  def replace_schedule
    schedule = Schedule.find_or_initialize_by(date: raw_date)
    schedule.replace_appointments(appointments)
  end

  def invalid_date_result
    Result.new(
      success: false,
      error: "Missing or invalid `date` query param (expected YYYY-MM-DD).",
      status: :bad_request
    )
  end

  def invalid_appointments_result
    Result.new(success: false, error: appointment_error, status: :bad_request)
  end
end
