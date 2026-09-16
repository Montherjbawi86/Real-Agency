class AddYoutubeUrlToPropertiesAndCars < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :youtube_url, :string
    add_column :cars,       :youtube_url, :string
  end
end
