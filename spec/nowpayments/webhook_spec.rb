# frozen_string_literal: true

require "spec_helper"

RSpec.describe NOWPayments::Webhook do
  let(:secret) { "test_secret" }

  let(:payload_hash) do
    {
      "payment_id" => 123_456,
      "payment_status" => "finished",
      "pay_address" => "bc1qtest",
      "price_amount" => 100.0,
      "price_currency" => "usd",
      "pay_amount" => 0.00123,
      "pay_currency" => "btc",
      "order_id" => "test-123"
    }
  end

  let(:raw_body) { JSON.generate(payload_hash) }

  describe ".verify!" do
    it "verifies valid signature" do
      # Sort keys and generate signature
      sorted_json = described_class.send(:sort_keys_recursive, payload_hash)
      signature = described_class.send(:generate_signature, sorted_json, secret)

      result = described_class.verify!(raw_body, signature, secret)

      expect(result).to be_a(Hash)
      expect(result["payment_id"]).to eq(123_456)
      expect(result["payment_status"]).to eq("finished")
    end

    it "raises SecurityError for invalid signature" do
      invalid_signature = "invalid_signature_hash"

      expect do
        described_class.verify!(raw_body, invalid_signature, secret)
      end.to raise_error(NOWPayments::SecurityError, /Invalid IPN signature/)
    end

    it "raises ArgumentError for missing raw_body" do
      expect do
        described_class.verify!(nil, "sig", secret)
      end.to raise_error(ArgumentError, /raw_body required/)
    end

    it "raises ArgumentError for missing signature" do
      expect do
        described_class.verify!(raw_body, nil, secret)
      end.to raise_error(ArgumentError, /signature required/)
    end

    it "raises ArgumentError for missing secret" do
      expect do
        described_class.verify!(raw_body, "sig", nil)
      end.to raise_error(ArgumentError, /secret required/)
    end

    context "with nested objects" do
      let(:nested_payload) do
        {
          "payment_id" => 123,
          "fee" => {
            "currency" => "btc",
            "depositFee" => 0.0001,
            "withdrawalFee" => 0.0002
          },
          "metadata" => {
            "user_id" => 456,
            "extra" => {
              "nested" => "value"
            }
          }
        }
      end

      let(:nested_raw_body) { JSON.generate(nested_payload) }

      it "handles nested hash key sorting correctly" do
        sorted_json = described_class.send(:sort_keys_recursive, nested_payload)
        signature = described_class.send(:generate_signature, sorted_json, secret)

        result = described_class.verify!(nested_raw_body, signature, secret)

        expect(result).to be_a(Hash)
        expect(result["payment_id"]).to eq(123)
        expect(result["fee"]["currency"]).to eq("btc")
      end
    end
  end

  describe "private methods" do
    describe ".sort_keys_recursive" do
      it "sorts top-level keys" do
        unsorted = { "z" => 1, "a" => 2, "m" => 3 }
        result = described_class.send(:sort_keys_recursive, unsorted)

        expect(result.keys).to eq(%w[a m z])
      end

      it "sorts nested hash keys" do
        unsorted = {
          "z" => { "nested_z" => 1, "nested_a" => 2 },
          "a" => { "nested_m" => 3 }
        }
        result = described_class.send(:sort_keys_recursive, unsorted)

        expect(result["a"].keys).to eq(["nested_m"])
        expect(result["z"].keys).to eq(%w[nested_a nested_z])
      end

      it "handles arrays with hashes" do
        with_array = {
          "items" => [
            { "z" => 1, "a" => 2 },
            { "m" => 3, "b" => 4 }
          ]
        }
        result = described_class.send(:sort_keys_recursive, with_array)

        expect(result["items"][0].keys).to eq(%w[a z])
        expect(result["items"][1].keys).to eq(%w[b m])
      end
    end

    describe ".secure_compare" do
      it "returns true for identical strings" do
        result = described_class.send(:secure_compare, "test123", "test123")
        expect(result).to be true
      end

      it "returns false for different strings" do
        result = described_class.send(:secure_compare, "test123", "test456")
        expect(result).to be false
      end

      it "returns false for different length strings" do
        result = described_class.send(:secure_compare, "test", "testing")
        expect(result).to be false
      end
    end
  end
end
