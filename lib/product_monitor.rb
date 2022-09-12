require "awesome_print"
require "byebug"
require "yaml"

class ProductMonitor
  class << self
    def start(params_filename)
      Thread.new { new(params_filename).run }
    end
  end

  def run
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
  end

  private

  attr_reader :products, :refresh_period, :sms, :store

  def initialize(params_filename)
    params = YAML.safe_load(File.read(params_filename)).symbolize_keys

    unless params[:products]
      puts "No products are defined"
      exit 1
    end
    @products = params[:products]&.map { |product| Product.new(product) }

    @store = Store.new(params[:store])
    puts "Watching store #{store.id} (#{store.name}) for the following items:"
    products.each { |p| puts "- #{p}" }

    sms_params = params[:sms]&.symbolize_keys
    @sms = SMSClient.new(sms_params) if sms_params
    if sms
      puts "Notifications will be sent to the following:"
      sms.destinations.each { |d| puts "- #{d}" }
    else
      puts "Notifications will not be sent"
    end

    @refresh_period = params[:refresh]&.to_i || 300
    puts "Stock will be checked every #{refresh_period} seconds"
  end
end