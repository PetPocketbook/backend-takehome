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

    def initialize(connection: default_connection)
      @connection = connection
    end

    def fetch_schedule
      response = connection.get(UPSTREAM_URL, api_key: api_key)
      validated_payload(response)
    rescue Faraday::Error
      raise UpstreamError, "PetPocketbook is unavailable."
    end

    private

    attr_reader :connection

    def api_key
      ENV.fetch("PETPOCKETBOOK_API_KEY", DEFAULT_API_KEY)
    end

    def validated_payload(response)
      raise UpstreamError, "PetPocketbook returned an error." unless response.success?
      raise UpstreamError, "PetPocketbook response was malformed." unless response.body.is_a?(Hash)
      raise UpstreamError, "PetPocketbook response was malformed." unless response.body["appointments"].is_a?(Array)
      raise UpstreamError, "PetPocketbook response was malformed." unless response.body["appointments"].all? { |appointment| valid_appointment?(appointment) }

      response.body
    end

    def valid_appointment?(appointment)
      appointment.is_a?(Hash) &&
        appointment["pet"].is_a?(Hash) &&
        appointment.dig("pet", "name").is_a?(String) &&
        appointment.dig("pet", "type").is_a?(String) &&
        appointment["time"].is_a?(String)
    end

    def default_connection
      Faraday.new do |f|
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end
  end
end
