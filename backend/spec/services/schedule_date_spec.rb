require "rails_helper"

RSpec.describe ScheduleDate do
  describe ".parse" do
    it "returns a normalized Schedule date for valid ISO dates" do
      result = described_class.parse("2026-06-24")

      expect(result).to be_success
      expect(result.date).to eq("2026-06-24")
    end

    it "rejects missing dates" do
      result = described_class.parse(nil)

      expect(result).not_to be_success
      expect(result.error).to eq("Missing or invalid `date` query param (expected YYYY-MM-DD).")
      expect(result.status).to eq(:bad_request)
    end

    it "rejects malformed dates" do
      result = described_class.parse("tomorrow")

      expect(result).not_to be_success
      expect(result.error).to eq("Missing or invalid `date` query param (expected YYYY-MM-DD).")
      expect(result.status).to eq(:bad_request)
    end

    it "rejects impossible dates" do
      result = described_class.parse("2026-02-30")

      expect(result).not_to be_success
      expect(result.error).to eq("Missing or invalid `date` query param (expected YYYY-MM-DD).")
      expect(result.status).to eq(:bad_request)
    end
  end
end
