class ScheduleSeeder
  def initialize(date:, client: PetPocketbook::Client.new)
    @date = date
    @client = client
  end

  def call
    raise NotImplementedError
  end
end
