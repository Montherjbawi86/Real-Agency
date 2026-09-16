module Billing
  class PaymentRequestsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_agent!

    def index
      @requests = current_user.payment_requests.recent
    end

    def show
      @request = current_user.payment_requests.find(params[:id])
    end

    def new
      @subscription = if params[:subscription_id]
        current_user.subscriptions.find(params[:subscription_id])
      else
        current_user.subscriptions.pending.order(created_at: :desc).first
      end

      if @subscription.nil?
        redirect_to billing_plans_subscription_path, alert: "اختر خطة أولاً"
        return
      end

      @plan    = @subscription.plan
      @request = current_user.payment_requests.new(
        subscription:  @subscription,
        plan:          @plan,
        amount:        @plan.price_syp,
        currency:      "SYP",
        transfer_date: Date.current
      )
      @settings = PlatformSetting.all.pluck(:key, :value).to_h
    end

    def create
      @subscription = current_user.subscriptions.find(params[:payment_request][:subscription_id])
      @request = current_user.payment_requests.new(payment_request_params)
      @request.subscription = @subscription
      @request.plan         = @subscription.plan

      if @request.save
        redirect_to billing_payment_request_path(@request),
                    notice: "تم إرسال طلبك ✅ — بانتظار مراجعة الإدارة"
      else
        @plan     = @subscription.plan
        @settings = PlatformSetting.all.pluck(:key, :value).to_h
        render :new, status: :unprocessable_entity
      end
    end

    private

    def require_agent!
      redirect_to root_path, alert: "هذه الصفحة للوكلاء فقط" unless current_user.agent?
    end

    def payment_request_params
      params.require(:payment_request).permit(
        :subscription_id, :amount, :currency, :payment_method,
        :reference_number, :transfer_date, :sender_name, :sender_phone,
        :proof_image
      )
    end
  end
end
