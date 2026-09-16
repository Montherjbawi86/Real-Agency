class AddSocialUrlsToAgencies < ActiveRecord::Migration[7.2]
  def change
    add_column :agencies, :facebook_url,  :string
    add_column :agencies, :instagram_url, :string
    add_column :agencies, :tiktok_url,    :string
    add_column :agencies, :youtube_url,   :string
    add_column :agencies, :twitter_url,   :string
    add_column :agencies, :telegram_url,  :string
  end
end
