module Billing
  class SubscriptionsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_agent!

    def show
      @subscription = current_user.current_subscription
      @plan         = current_user.current_plan
      @listings     = current_user.listings_count
      @remaining    = current_user.listings_remaining
      @requests     = current_user.payment_requests.recent.limit(5)
    end

    def plans
      @plans         = Plan.active
      @current_plan  = current_user.current_plan
      @subscription  = current_user.current_subscription
    end

    def upgrade
      @plan = Plan.find(params[:plan_id])
      @subscription = current_user.subscriptions.create!(plan: @plan, status: :pending)
      redirect_to new_billing_payment_request_path(subscription_id: @subscription.id)
    end

    private

    def require_agent!
      redirect_to root_path, alert: "هذه الصفحة للوكلاء فقط" unless current_user.agent?
    end
  end
end
