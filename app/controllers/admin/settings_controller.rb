module Admin
  class SettingsController < Admin::BaseController
    def show
      @settings = PlatformSetting.all.pluck(:key, :value).to_h
    end

    def update
      params[:settings].each do |key, value|
        PlatformSetting.set(key, value)
      end
      redirect_to admin_settings_path, notice: "✅ تم حفظ الإعدادات"
    end
  end
end
