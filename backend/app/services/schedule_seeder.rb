class ScheduleSeeder
  Result = Struct.new(:success, :schedule, :error, :status, keyword_init: true) do
    def success?
      success
    end
  end

  def initialize(date:, client: PetPocketbook::Client.new)
    @date = date
    @client = client
  end

  def call
    Schedule.transaction do
      appointments = build_appointments_from_upstream
      validate_appointments!(appointments)

      Result.new(success: true, schedule: create_schedule(appointments))
    end
  rescue PetPocketbook::Client::UpstreamError => e
    Result.new(success: false, error: e.message, status: e.status)
  end

  private

  attr_reader :date, :client

  def build_appointments_from_upstream
    client.fetch_schedule.fetch("appointments").map do |appointment|
      Appointment.from_upstream(appointment)
    end
  end

  def validate_appointments!(appointments)
    error_message = ScheduleAppointmentValidator.error_message(appointments.map(&:to_h))
    raise PetPocketbook::Client::UpstreamError, error_message if error_message
  end

  def create_schedule(appointments)
    Schedule.create!(date: date, appointments: appointments.map(&:to_h))
  end
end
