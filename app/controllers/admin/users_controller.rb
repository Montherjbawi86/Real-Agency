module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :toggle_admin, :toggle_verified]

    def index
      @users = User.includes(:agency).order(created_at: :desc)

      # Filters
      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @users = @users.where("full_name ILIKE :q OR email ILIKE :q OR phone ILIKE :q", q: q)
      end

      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where(admin: true) if params[:admin] == "1"

      @counts = {
        all:      User.count,
        buyers:   User.where(role: :buyer).count,
        property: User.where(role: :property_agent).count,
        car:      User.where(role: :car_agent).count,
        admins:   User.where(admin: true).count
      }
    end

    def show
      @subscriptions = @user.subscriptions.order(created_at: :desc)
      @properties    = @user.properties.limit(10) if @user.property_agent?
      @cars          = @user.cars.limit(10) if @user.car_agent?
      @payments      = @user.payments.limit(10)
      @payment_requests = @user.payment_requests.recent.limit(10)
    end

    def toggle_admin
      @user.update(admin: !@user.admin?)
      redirect_back fallback_location: admin_users_path,
                    notice: "تم #{@user.admin? ? 'منح' : 'إلغاء'} صلاحيات المشرف"
    end

    def toggle_verified
      if @user.agency
        @user.agency.update(verified: !@user.agency.verified?)
        redirect_back fallback_location: admin_user_path(@user),
                      notice: "تم #{@user.agency.verified? ? 'توثيق' : 'إلغاء توثيق'} الوكالة"
      else
        redirect_back fallback_location: admin_user_path(@user),
                      alert: "لا توجد وكالة لهذا المستخدم"
      end
    end

    private

    def set_user = @user = User.find(params[:id])
  end
end
