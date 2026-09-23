class HomeController < ApplicationController
  def index
    @recent_properties = Property.published.recent.limit(6)
    @recent_cars       = Car.published.recent.limit(6)
    @cities            = City.order(:name_ar)
    @properties_count  = Property.published.count
    @cars_count        = Car.published.count
    @agents_count      = User.agents.count
    @cities_count      = City.count
  end

  def search
    if params[:type] == "car"
      redirect_to cars_path(
        city_id:   params[:city_id].presence,
        body_type: params[:body_type].presence,
        fuel_type: params[:fuel_type].presence,
        max_price: params[:max_price].presence
      )
    else
      redirect_to properties_path(
        city_id:   params[:city_id].presence,
        type:      params[:property_type].presence,
        listing:   params[:listing_type].presence,
        max_price: params[:max_price].presence
      )
    end
  end
end
