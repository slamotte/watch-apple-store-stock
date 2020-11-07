require "httparty"

class Store
  STOCK_URL = "https://www.apple.com/ca/shop/retail/pickup-message?store=%STORE_ID%&parts.0=%PRODUCT_ID%".freeze

  attr_reader :id, :name

  def initialize(params)
    params = params.symbolize_keys
    @id = params[:id]
    @name = params[:name]
  end

  def in_stock?(product)
    url = STOCK_URL
      .sub("%STORE_ID%", id)
      .sub("%PRODUCT_ID%", product.id)
    response = HTTParty.get(url, headers: {"content-Type" => "application/json;encoding=UTF-8;charset=UTF-8"})
    unless response.success?
      puts "😨 Error checking stock for URL #{url}"
      return false
    end

    status = response.dig("body", "stores")&.first&.dig("partsAvailability", product.id, "pickupDisplay")
    status == "available"
  end

  def to_s
    name
  end
end
