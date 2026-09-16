module Dashboard
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_agent!

    layout "dashboard"

    private

    def require_agent!
      unless current_user.agent?
        redirect_to root_path, alert: "هذه الصفحة للوكلاء فقط"
      end
    end
  end
end
