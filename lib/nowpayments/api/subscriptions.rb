# frozen_string_literal: true

module NOWPayments
  module API
    # Subscription and recurring payment endpoints
    module Subscriptions
      # Get subscription plans
      # GET /v1/subscriptions/plans
      # @return [Hash] List of subscription plans
      def subscription_plans
        get("subscriptions/plans").body
      end

      # Create subscription plan
      # POST /v1/subscriptions/plans
      # @param plan_data [Hash] Plan configuration
      # @return [Hash] Created plan
      def create_subscription_plan(plan_data)
        post("subscriptions/plans", body: plan_data).body
      end

      # Update subscription plan
      # PATCH /v1/subscriptions/plans/:plan_id
      # @param plan_id [String, Integer] Plan ID
      # @param plan_data [Hash] Updated plan configuration
      # @return [Hash] Updated plan details
      def update_subscription_plan(plan_id, plan_data)
        patch("subscriptions/plans/#{plan_id}", body: plan_data).body
      end

      # Get specific subscription plan
      # GET /v1/subscriptions/plans/:plan_id
      # @param plan_id [String, Integer] Plan ID
      # @return [Hash] Plan details
      def subscription_plan(plan_id)
        get("subscriptions/plans/#{plan_id}").body
      end

      # Create email subscription
      # POST /v1/subscriptions
      # @param plan_id [String] Subscription plan ID
      # @param email [String] Customer email
      # @return [Hash] Subscription result
      def create_subscription(plan_id:, email:)
        post("subscriptions", body: {
               plan_id: plan_id,
               email: email
             }).body
      end

      # List recurring payments with filters
      # GET /v1/subscriptions
      # @param limit [Integer] Results per page
      # @param offset [Integer] Offset for pagination
      # @param status [String, nil] Filter by status (WAITING_PAY, PAID, PARTIALLY_PAID, EXPIRED)
      # @param subscription_plan_id [String, Integer, nil] Filter by plan ID
      # @param is_active [Boolean, nil] Filter by active status
      # @return [Hash] List of recurring payments
      def list_recurring_payments(limit: 10, offset: 0, status: nil, subscription_plan_id: nil, is_active: nil)
        params = { limit: limit, offset: offset }
        params[:status] = status if status
        params[:subscription_plan_id] = subscription_plan_id if subscription_plan_id
        params[:is_active] = is_active unless is_active.nil?

        get("subscriptions", params: params).body
      end

      # Get specific recurring payment
      # GET /v1/subscriptions/:subscription_id
      # @param subscription_id [String, Integer] Subscription ID
      # @return [Hash] Recurring payment details
      def recurring_payment(subscription_id)
        get("subscriptions/#{subscription_id}").body
      end

      # Delete recurring payment
      # DELETE /v1/subscriptions/:subscription_id
      # @param subscription_id [String, Integer] Subscription ID
      # @return [Hash] Deletion result
      def delete_recurring_payment(subscription_id)
        delete("subscriptions/#{subscription_id}").body
      end

      # Get subscription payments
      # GET /v1/subscriptions/:subscription_id/payments
      # @param subscription_id [String, Integer] Subscription ID
      # @return [Hash] Subscription payments
      def subscription_payments(subscription_id)
        get("subscriptions/#{subscription_id}/payments").body
      end
    end
  end
end
