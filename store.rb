require "httparty"

class Store
  STOCK_URL = "https://www.apple.com/ca/shop/retail/pickup-message".freeze

  attr_reader :id, :name

  def initialize(params)
    params = params.symbolize_keys
    @id = params[:id]
    @name = params[:name]
  end

  # Returns an array of prducts that are in stock at this store
  def check_stock(products)
    params = ["store=#{id}"] + product_params(products)
    url = "#{STOCK_URL}?#{params.join('&')}"
    response = HTTParty.get(url)
    unless response.success?
      puts "😨 Error checking stock for URL #{url}"
      return false
    end

    availabilities = response.dig("body", "stores")&.first&.dig("partsAvailability")
    return unless availabilities

    in_stock = products.select do |product|
      availabilities[product.id]&.dig("pickupDisplay") == "available"
    end.compact
    return if in_stock.empty?

    in_stock.each do |product|
      puts "🎉🎉🎉 #{product} is IN STOCK at #{name} 🎉🎉🎉"
    end
  end

  private

  def product_params(products)
    products.map.with_index { |product, i| "parts.#{i}=#{product.id}" }
  end
end
