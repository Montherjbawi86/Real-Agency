module Admin
  class DashboardController < Admin::BaseController
    def index
      @pending_requests  = PaymentRequest.pending
      @approved_today    = PaymentRequest.where(status: :approved, processed_at: Date.current.all_day)
      @total_users       = User.count
      @total_agents      = User.where(role: [:car_agent, :property_agent]).count
      @total_revenue_syp = PaymentRequest.approved.where(currency: "SYP").sum(:amount) || 0
      @total_revenue_usd = PaymentRequest.approved.where(currency: "USD").sum(:amount) || 0
      @active_subs       = Subscription.where(status: :active).where("ends_on IS NULL OR ends_on >= ?", Date.current).count
      @pending_agencies  = Agency.where(approval_status: :pending).count
      @total_properties  = Property.count
      @total_cars        = Car.count
      @pending_agencies_list = Agency.where(approval_status: :pending).includes(:user, :city).limit(5)
    end
  end
end
