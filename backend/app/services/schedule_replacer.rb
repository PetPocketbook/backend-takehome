class ScheduleReplacer
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
    return invalid_date_result unless parsed_date.success?
    return invalid_appointments_result if appointment_error

    Result.new(success: true, schedule: replace_schedule)
  end

  private

  attr_reader :raw_date, :appointments

  def parsed_date
    @parsed_date ||= ScheduleDate.parse(raw_date)
  end

  def appointment_error
    @appointment_error ||= ScheduleAppointmentValidator.error_message(appointments)
  end

  def replace_schedule
    schedule = Schedule.find_or_initialize_by(date: parsed_date.date)
    schedule.replace_appointments(appointments)
  end

  def invalid_date_result
    Result.new(success: false, error: parsed_date.error, status: parsed_date.status)
  end

  def invalid_appointments_result
    Result.new(success: false, error: appointment_error, status: :bad_request)
  end
end
