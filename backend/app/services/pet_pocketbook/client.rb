module PetPocketbook
  class Client
    UPSTREAM_URL = "https://candidate.petpocketbook.com/schedule".freeze
    DEFAULT_API_KEY = "jQkI63suJhqd3DtL".freeze

    UpstreamError = Class.new(StandardError) do
      attr_reader :status

      def initialize(message, status: 502)
        super(message)
        @status = status
      end
    end

    def fetch_schedule
      raise NotImplementedError
    end

    private

    def api_key
      ENV.fetch("PETPOCKETBOOK_API_KEY", DEFAULT_API_KEY)
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end
  end
end
