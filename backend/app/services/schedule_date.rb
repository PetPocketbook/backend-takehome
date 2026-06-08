class ScheduleDate
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/
  INVALID_DATE_MESSAGE = "Missing or invalid `date` query param (expected YYYY-MM-DD).".freeze

  Result = Struct.new(:success, :date, :error, :status, keyword_init: true) do
    def success?
      success
    end
  end

  def self.parse(raw_date)
    new(raw_date).parse
  end

  def initialize(raw_date)
    @raw_date = raw_date
  end

  def parse
    return invalid_result unless raw_date.to_s.match?(DATE_PATTERN)

    Result.new(success: true, date: Date.iso8601(raw_date.to_s).to_s)
  rescue ArgumentError
    invalid_result
  end

  private

  attr_reader :raw_date

  def invalid_result
    Result.new(success: false, error: INVALID_DATE_MESSAGE, status: :bad_request)
  end
end
