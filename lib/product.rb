class Product
  attr_reader :id, :name, :storage, :color

  def initialize(params)
    params = params.symbolize_keys
    @id = params[:id]
    @name = params[:name]
    @storage = params[:storage]
    @color = params[:color]
  end

  def to_s
    [name, storage, color].compact.join(" ")
  end
end
