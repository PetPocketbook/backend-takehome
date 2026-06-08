class ScheduleLoader
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

  Result = Struct.new(:success, :schedule, :error, :status, keyword_init: true) do
    def success?
      success
    end
  end

  def initialize(date:, seeder: ScheduleSeeder)
    @raw_date = date
    @seeder = seeder
  end

  def call
    return invalid_date_result unless valid_date?

    existing_schedule || seed_schedule
  end

  private

  attr_reader :raw_date, :seeder

  def valid_date?
    raw_date.to_s.match?(DATE_PATTERN) && Date.iso8601(raw_date.to_s)
  rescue ArgumentError
    false
  end

  def existing_schedule
    schedule = Schedule.find_for_date(raw_date)
    Result.new(success: true, schedule: schedule) if schedule
  end

  def seed_schedule
    seeder.new(date: raw_date).call
  end

  def invalid_date_result
    Result.new(
      success: false,
      error: "Missing or invalid `date` query param (expected YYYY-MM-DD).",
      status: :bad_request
    )
  end
end
