require "httparty"

class Store
  REQUEST_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0",
    "Accept" => "application/json, text/javascript, */*; q=0.01",
    "Accept-Language" => "en-CA,en-US;q=0.7,en;q=0.3",
    "Accept-Encoding" => "gzip, deflate, br",
    "X-Requested-With" => "XMLHttpRequest",
    "Connection" => "keep-alive",
    "Pragma" => "no-cache",
    "Cache-Control" => "no-cache"
  }.freeze

  attr_reader :id, :name, :url

  def initialize(params)
    params = params.symbolize_keys
    @id = params[:id]
    @name = params[:name]
    @url = params[:url]
  end

  # Returns an array of prducts that are in stock at this store
  def in_stock(products)
    params = ["store=#{id}"] + product_params(products).flatten
    url = "#{self.url}?#{params.join('&')}"
    response = HTTParty.get(url, headers: REQUEST_HEADERS)
    unless response.success?
      puts "😨 HTTP error #{response.code} for #{url}"
      return
    end

    error = response.dig("body", "errorMessage")
    raise "Error checking stock: #{error}. Review your store and product ids." if error

    stock = response.dig("body", "stores")&.first&.dig("partsAvailability")
    return unless stock

    products.select do |product|
      stock[product.id]&.dig("pickupDisplay") == "available"
    end
  rescue StandardError => e
    puts "😨 Error checking stock: #{e.message}"
    puts "Response: #{response.inspect}"
    puts "Stock checking continues..."
  end

  private

  def product_params(products)
    products.map.with_index do |product, i|
      [].tap do |result|
        result << "parts.#{i}=#{product.id}"
        result << "option.#{i}=#{product.option}" if product.option
      end
    end
  end
end
