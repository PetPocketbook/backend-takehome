class ScheduleLoader
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
    return invalid_date_result unless parsed_date.success?

    existing_schedule || seed_schedule
  end

  private

  attr_reader :raw_date, :seeder

  def parsed_date
    @parsed_date ||= ScheduleDate.parse(raw_date)
  end

  def existing_schedule
    schedule = Schedule.find_for_date(parsed_date.date)
    Result.new(success: true, schedule: schedule) if schedule
  end

  def seed_schedule
    seeder.new(date: parsed_date.date).call
  end

  def invalid_date_result
    Result.new(success: false, error: parsed_date.error, status: parsed_date.status)
  end
end
