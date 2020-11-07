require "awesome_print"
require "byebug"
require "yaml"

require_relative "hash"
require_relative "product"
require_relative "store"

params = YAML.safe_load(File.read("params.yml")).symbolize_keys
products = params[:products].map { |product| Product.new(product) }
stores = params[:stores].map { |store| Store.new(store) }

stores.each { |store| store.check_stock(products) }
