require "awesome_print"
require "byebug"
require "yaml"

Dir[File.join(%w[lib ** *.rb])].each { |f| require_relative f }

CHECK_FREQUENCY = 5 * 60 # How many seconds between checks

params = YAML.safe_load(File.read("params.yml")).symbolize_keys
store = Store.new(params[:store])

unless params[:products]
  puts "No products are defined"
  exit
end
products = params[:products]&.map { |product| Product.new(product) }
puts "Watching store #{store.id} (#{store.name}) for the following items:"
products.each { |p| puts "- #{p}" }

sms_params = params[:sms]&.symbolize_keys
sms = SMSClient.new(sms_params) if sms_params
if sms
  puts "Notifications will be sent to the following:"
  sms.destinations.each { |d| puts "- #{d}" }
else
  puts "Notifications will not be sent"
end

puts "Stock will be checked every #{CHECK_FREQUENCY} seconds"
loop do
  store.in_stock(products)&.each do |product|
    msg = "🎉🎉🎉 #{product} is IN STOCK at #{store.name}!"
    puts msg

    # Don't alert about this product again (unless sending the SMS fails)
    products.delete(product) unless sms && !sms.send(msg)
  end

  sleep CHECK_FREQUENCY
rescue StandardError => e
  puts e.message
  exit
end
