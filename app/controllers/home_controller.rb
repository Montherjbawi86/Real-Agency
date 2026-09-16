class HomeController < ApplicationController
  def index
    @recent_properties = Property.published.recent.limit(6)
    @recent_cars       = Car.published.recent.limit(6)
    @cities            = City.order(:name_ar)
    @properties_count  = Property.published.count
    @cars_count        = Car.published.count
    @agents_count      = User.agents.count
    @cities_count      = City.count
    @buildings         = Building.includes(:city, :properties).order(created_at: :desc).limit(6)
  end

  def search
    if params[:type] == "car"
      redirect_to cars_path(
        city_id:   params[:city_id],
        body_type: params[:body_type],
        fuel_type: params[:fuel_type]
      )
    else
      redirect_to properties_path(
        city_id: params[:city_id],
        type:    params[:property_type],
        listing: params[:listing_type]
      )
    end
  end
end
