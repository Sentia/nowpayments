# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NOWPayments API Integration", :vcr do
  before(:all) do
    skip "Set NOWPAYMENTS_SANDBOX_API_KEY in .env to run integration tests" unless ENV["NOWPAYMENTS_SANDBOX_API_KEY"]
  end

  let(:client) do
    NOWPayments::Client.new(
      api_key: ENV["NOWPAYMENTS_SANDBOX_API_KEY"] || "test_key",
      sandbox: true
    )
  end

  describe "API Status and Info" do
    it "checks API status", vcr: { cassette_name: "api_status" } do
      result = client.status
      expect(result).to be_a(Hash)
      expect(result["message"]).to eq("OK")
    end

    it "gets available currencies", vcr: { cassette_name: "currencies" } do
      result = client.currencies
      expect(result).to be_a(Hash)
      expect(result["currencies"]).to be_an(Array)
      expect(result["currencies"]).to include("btc", "eth")
    end

    it "gets full currency info", vcr: { cassette_name: "full_currencies" } do
      result = client.full_currencies
      expect(result).to be_a(Hash)
      expect(result["currencies"]).to be_an(Array)
    end
  end

  describe "Payment Estimation" do
    it "gets minimum amount", vcr: { cassette_name: "min_amount" } do
      result = client.min_amount(
        currency_from: "usd",
        currency_to: "btc"
      )

      expect(result).to be_a(Hash)
      expect(result).to have_key("min_amount")
      expect(result["min_amount"]).to be > 0
    end

    it "estimates price", vcr: { cassette_name: "estimate_price" } do
      result = client.estimate(
        amount: 100,
        currency_from: "usd",
        currency_to: "btc"
      )

      expect(result).to be_a(Hash)
      expect(result).to have_key("estimated_amount")
      expect(result["estimated_amount"]).to be > 0
    end
  end

  describe "Payment Creation and Management" do
    it "creates a payment", vcr: { cassette_name: "create_payment" } do
      payment = client.create_payment(
        price_amount: 100.0,
        price_currency: "usd",
        pay_currency: "btc",
        order_id: "test-#{Time.now.to_i}"
      )

      expect(payment).to be_a(Hash)
      expect(payment).to have_key("payment_id")
      expect(payment).to have_key("pay_address")
      expect(payment).to have_key("payment_status")
      expect(payment["payment_status"]).to eq("waiting")
    end

    it "gets payment status", vcr: { cassette_name: "get_payment" } do
      # First create a payment
      payment = client.create_payment(
        price_amount: 100.0,
        price_currency: "usd",
        pay_currency: "btc",
        order_id: "test-status-#{Time.now.to_i}"
      )

      # Then retrieve it
      result = client.payment(payment["payment_id"])

      expect(result).to be_a(Hash)
      expect(result["payment_id"]).to eq(payment["payment_id"])
      expect(result).to have_key("payment_status")
    end
  end

  describe "Invoice Creation" do
    it "creates an invoice", vcr: { cassette_name: "create_invoice" } do
      invoice = client.create_invoice(
        price_amount: 50.0,
        price_currency: "usd",
        order_id: "inv-#{Time.now.to_i}"
      )

      expect(invoice).to be_a(Hash)
      expect(invoice).to have_key("id")
      expect(invoice).to have_key("invoice_url")
      expect(invoice["invoice_url"]).to match(%r{^https?://})
    end
  end

  describe "Error Handling" do
    it "raises AuthenticationError for invalid API key" do
      invalid_client = NOWPayments::Client.new(
        api_key: "invalid_key",
        sandbox: true
      )

      expect do
        invalid_client.status
      end.to raise_error(NOWPayments::AuthenticationError)
    end

    it "raises ValidationError for invalid payment params" do
      expect do
        client.create_payment(
          price_amount: 100,
          price_currency: "usd",
          pay_currency: "btc",
          payout_address: "some_address"
          # Missing payout_currency - should raise error
        )
      end.to raise_error(NOWPayments::ValidationError, /payout_currency required/)
    end
  end
end
