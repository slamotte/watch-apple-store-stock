require "awesome_print"
require "byebug"
require "yaml"

Dir[File.join(%w[lib ** *.rb])].each { |f| require_relative f }

params = YAML.safe_load(File.read("params.yml")).symbolize_keys

unless params[:products]
  puts "No products are defined"
  exit 1
end
products = params[:products]&.map { |product| Product.new(product) }

store = Store.new(params[:store])
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

refresh_period = params[:refresh]&.to_i || 300
puts "Stock will be checked every #{refresh_period} seconds"
loop do
  store.in_stock(products)&.each do |product|
    msg = "🎉🎉🎉 #{product} is IN STOCK at #{store.name} as of #{Time.now.strftime('%b %-d, %Y at %I:%M:%S%P')}"
    puts msg

    # Don't alert about this product again (unless sending the SMS fails)
    products.delete(product) unless sms && !sms.send(msg)
  end

  sleep refresh_period
rescue Interrupt
  puts "\nExiting..."
  exit 130
rescue StandardError => e
  puts e.message
  exit 1
end
