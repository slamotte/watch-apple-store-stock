class Product
  attr_reader :id, :option, :name, :storage, :color, :url

  def initialize(params)
    params = params.symbolize_keys
    @id = params[:id]
    @option = params[:option]
    @name = params[:name]
    @storage = params[:storage]
    @color = params[:color]
    @url = params[:url]
  end

  def to_s
    [name, storage, color].compact.join(" ")
  end
end
