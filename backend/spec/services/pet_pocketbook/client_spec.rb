require "rails_helper"

RSpec.describe PetPocketbook::Client do
  describe "#fetch_schedule" do
    it "returns upstream schedule payloads" do
      response = instance_double(Faraday::Response, success?: true, body: { "appointments" => [] })
      connection = instance_double(Faraday::Connection)
      allow(connection).to receive(:get).and_return(response)
      client = described_class.new(connection: connection)

      payload = client.fetch_schedule

      expect(payload).to eq("appointments" => [])
    end

    it "raises an upstream error for failed HTTP responses" do
      response = instance_double(Faraday::Response, success?: false)
      connection = instance_double(Faraday::Connection)
      allow(connection).to receive(:get).and_return(response)
      client = described_class.new(connection: connection)

      expect { client.fetch_schedule }.to raise_error(
        PetPocketbook::Client::UpstreamError,
        "PetPocketbook returned an error."
      )
    end

    it "raises an upstream error for malformed response envelopes" do
      response = instance_double(Faraday::Response, success?: true, body: { "pets" => [] })
      connection = instance_double(Faraday::Connection)
      allow(connection).to receive(:get).and_return(response)
      client = described_class.new(connection: connection)

      expect { client.fetch_schedule }.to raise_error(
        PetPocketbook::Client::UpstreamError,
        "PetPocketbook response was malformed."
      )
    end

    it "raises an upstream error for malformed appointments" do
      response = instance_double(
        Faraday::Response,
        success?: true,
        body: { "appointments" => [{ "pet" => { "name" => "Briar" }, "time" => "12:30 PM" }] }
      )
      connection = instance_double(Faraday::Connection)
      allow(connection).to receive(:get).and_return(response)
      client = described_class.new(connection: connection)

      expect { client.fetch_schedule }.to raise_error(
        PetPocketbook::Client::UpstreamError,
        "PetPocketbook response was malformed."
      )
    end

    it "raises an upstream error for network failures" do
      connection = instance_double(Faraday::Connection)
      allow(connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("failed"))
      client = described_class.new(connection: connection)

      expect { client.fetch_schedule }.to raise_error(
        PetPocketbook::Client::UpstreamError,
        "PetPocketbook is unavailable."
      )
    end
  end
end
