class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  rescue_from ActiveRecord::RecordNotUnique, with: :handle_duplicate

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :phone, :role])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :phone])
  end

  def update_resource(resource, params)
    params.delete(:role) if params[:role].present?
    super
  end

  private

  def handle_duplicate(exception)
    field = exception.message[/index_\w+_on_(\w+)/, 1] || "field"
    field_ar = { "phone" => "رقم الهاتف", "email" => "البريد الإلكتروني" }[field] || field
    flash[:alert] = "#{field_ar} مستخدم بالفعل — جرب تسجيل الدخول أو استخدم رقماً آخر."
    redirect_to new_user_registration_path
  end
end
