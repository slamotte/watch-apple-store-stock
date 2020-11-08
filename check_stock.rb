require "awesome_print"
require "byebug"
require "yaml"

require_relative "hash"
require_relative "product"
require_relative "sms_client"
require_relative "store"

params = YAML.safe_load(File.read("params.yml")).symbolize_keys
store = Store.new(params[:store])
products = params[:products].map { |product| Product.new(product) }

sms_params = params[:sms].symbolize_keys
sms = SMSClient.new(sms_params)

loop do
  in_stock = store.in_stock(products)
  unless in_stock.empty?
    in_stock.each do |product|
      msg = "#{product} is IN STOCK at #{store.name}!"
      puts msg

      # Don't alert about this product again
      products.delete(product) if sms.send(msg)
    end
  end

  sleep 60
end
