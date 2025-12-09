# frozen_string_literal: true

require "spec_helper"

RSpec.describe NOWPayments::Webhook do
  let(:secret) { "test_secret" }

  describe ".verify!" do
    context "with valid signature" do
      let(:raw_body) do
        '{"order_id":"test-123","pay_amount":0.00123,"pay_currency":"btc",' \
          '"payment_id":123456,"payment_status":"finished","price_amount":100.0,"price_currency":"usd"}'
      end
      let(:valid_signature) { OpenSSL::HMAC.hexdigest("SHA512", secret, raw_body) }

      it "verifies valid signature and returns parsed payload" do
        result = described_class.verify!(raw_body, valid_signature, secret)

        expect(result).to be_a(Hash)
        expect(result["payment_id"]).to eq(123_456)
        expect(result["payment_status"]).to eq("finished")
      end
    end

    it "raises SecurityError for invalid signature" do
      raw_body = '{"payment_id":123}'
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
      raw_body = '{"payment_id":123}'
      expect do
        described_class.verify!(raw_body, nil, secret)
      end.to raise_error(ArgumentError, /signature required/)
    end

    it "raises ArgumentError for missing secret" do
      raw_body = '{"payment_id":123}'
      expect do
        described_class.verify!(raw_body, "sig", nil)
      end.to raise_error(ArgumentError, /secret required/)
    end

    context "with scientific notation in payload" do
      # This is the critical test case that proves why we MUST use raw body directly.
      # Ruby's JSON.generate converts "1e-7" to "0.0000001", breaking the signature.
      let(:raw_body_with_scientific) { '{"amount":1e-7,"payment_id":123}' }
      let(:valid_sig) { OpenSSL::HMAC.hexdigest("SHA512", secret, raw_body_with_scientific) }

      it "verifies signature correctly without re-serializing" do
        result = described_class.verify!(raw_body_with_scientific, valid_sig, secret)

        expect(result).to be_a(Hash)
        expect(result["amount"]).to eq(1e-7)
        expect(result["payment_id"]).to eq(123)
      end

      it "demonstrates why re-serialization breaks signatures" do
        # If we parse and re-serialize, the JSON string changes
        parsed = JSON.parse(raw_body_with_scientific)
        regenerated = JSON.generate(parsed)

        expect(raw_body_with_scientific).not_to eq(regenerated)
        expect(raw_body_with_scientific).to eq('{"amount":1e-7,"payment_id":123}')
        expect(regenerated).to eq('{"amount":0.0000001,"payment_id":123}')

        # This means HMAC computed on regenerated string would be different
        wrong_sig = OpenSSL::HMAC.hexdigest("SHA512", secret, regenerated)
        expect(wrong_sig).not_to eq(valid_sig)
      end
    end

    context "with real production webhook payload" do
      let(:ipn_secret) { "m+uEkMgkRR3ir3i+bX4ezfTLne5LN4Pq" }
      # rubocop:disable Layout/LineLength
      let(:raw_body) do
        '{"actually_paid":0.00656612,"actually_paid_at_fiat":0,"fee":{"currency":"btc","depositFee":0.000002,"serviceFee":0.000003,"withdrawalFee":0},"invoice_id":null,"order_description":null,"order_id":"deposit_a7936ab3-8970-4d3b-8f79-d17aa8928b03_1765249230","outcome_amount":0.00022187,"outcome_currency":"btc","parent_payment_id":null,"pay_address":"0x05Db991D7930CE6Ac8c21064de9A14EB2a154746","pay_amount":0.00656612,"pay_currency":"eth","payin_extra_id":null,"payment_extra_ids":null,"payment_id":5800567260,"payment_status":"finished","price_amount":20,"price_currency":"usd","purchase_id":"5172103429","updated_at":1765249461097}'
      end
      let(:received_signature) do
        "da9aa86444805aa09917654dec3a524d84d6ce2d5e60fa0dbfef53312e7219a4f8f7ee24314ebce597bb28e037e67c03205a9c5094ba88ef8854f9ad36cc6292"
      end
      # rubocop:enable Layout/LineLength

      it "verifies signature for real production webhook data" do
        result = described_class.verify!(raw_body, received_signature, ipn_secret)

        expect(result).to be_a(Hash)
        expect(result["payment_id"]).to eq(5_800_567_260)
        expect(result["payment_status"]).to eq("finished")
        expect(result["order_id"]).to eq("deposit_a7936ab3-8970-4d3b-8f79-d17aa8928b03_1765249230")
        expect(result["pay_currency"]).to eq("eth")
        expect(result["outcome_currency"]).to eq("btc")
        expect(result["fee"]).to eq(
          "currency" => "btc",
          "depositFee" => 0.000002,
          "serviceFee" => 0.000003,
          "withdrawalFee" => 0
        )
      end

      it "computes HMAC directly on raw body" do
        computed_sig = OpenSSL::HMAC.hexdigest("SHA512", ipn_secret, raw_body)
        expect(computed_sig).to eq(received_signature)
      end
    end
  end

  describe "private methods" do
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
