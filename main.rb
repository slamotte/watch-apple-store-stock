require "awesome_print"
require "byebug"
require "yaml"

Dir["lib/**/*.rb"].each { |f| require_relative f }

CHECK_FREQUENCY = 5 * 60 # How many seconds between checks

params = YAML.safe_load(File.read("params.yml")).symbolize_keys
store = Store.new(params[:store])
products = params[:products].map { |product| Product.new(product) }

sms_params = params[:sms]&.symbolize_keys
sms = SMSClient.new(sms_params) if sms_params

loop do
  in_stock = store.in_stock(products)
  unless in_stock.empty?
    in_stock.each do |product|
      msg = "#{product} is IN STOCK at #{store.name}!"
      puts msg

      # Don't alert about this product again (unless sending the SMS fails)
      products.delete(product) unless sms && !sms.send(msg)
    end
  end

  sleep CHECK_FREQUENCY
end
