xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.changefreq "daily"
    xml.priority "1.0"
  end

  Property.published.find_each do |p|
    xml.url do
      xml.loc property_url(p)
      xml.lastmod p.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  Car.published.find_each do |c|
    xml.url do
      xml.loc car_url(c)
      xml.lastmod c.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  %w[about contact faq how-to-sell terms privacy cookies sitemap].each do |page|
    xml.url do
      xml.loc "#{root_url}#{page}"
      xml.changefreq "monthly"
      xml.priority "0.5"
    end
  end
end
