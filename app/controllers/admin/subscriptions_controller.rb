module Admin
  class SubscriptionsController < Admin::BaseController
    before_action :set_subscription, only: [:show, :activate, :cancel]

    def index
      @subscriptions = Subscription.includes(:user, :plan).order(created_at: :desc)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @subscriptions = @subscriptions.joins(:user).where("users.full_name ILIKE :q OR users.email ILIKE :q", q: q)
      end

      @subscriptions = @subscriptions.where(status: params[:status]) if params[:status].present?

      @counts = {
        all:     Subscription.count,
        active:  Subscription.where(status: :active).count,
        pending: Subscription.where(status: :pending).count,
        expired: Subscription.where(status: :expired).count
      }
    end

    def show; end

    def activate
      @subscription.activate!
      redirect_to admin_subscription_path(@subscription), notice: "✅ تم تنشيط الاشتراك"
    end

    def cancel
      @subscription.update!(status: :cancelled)
      redirect_to admin_subscription_path(@subscription), notice: "❌ تم إلغاء الاشتراك"
    end

    private

    def set_subscription = @subscription = Subscription.find(params[:id])
  end
end
