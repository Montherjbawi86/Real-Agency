module Admin
  class PaymentRequestsController < Admin::BaseController
    before_action :set_request, only: [:show, :approve, :reject]

    def index
      @requests = PaymentRequest.recent
      @requests = @requests.where(status: params[:status]) if params[:status].present?
      @counts = {
        pending:  PaymentRequest.pending.count,
        approved: PaymentRequest.approved.count,
        rejected: PaymentRequest.rejected.count
      }
    end

    def show; end

    def approve
      @request.approve!(current_user, notes: params[:notes])
      redirect_to admin_payment_request_path(@request),
                  notice: "✅ تم تفعيل الخطة للوكيل بنجاح"
    end

    def reject
      @request.reject!(current_user, notes: params[:notes])
      redirect_to admin_payment_request_path(@request),
                  notice: "❌ تم رفض الطلب"
    end

    private

    def set_request = @request = PaymentRequest.find(params[:id])
  end
end
