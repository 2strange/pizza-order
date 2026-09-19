# The sizes a pizza comes in. A size is a value, not a record: the list is fixed,
# and a multiplier is a rule of the menu, not data a customer enters.
class Size
  attr_reader :key, :label, :multiplier

  def initialize(key, label, multiplier)
    @key = key
    @label = label
    @multiplier = BigDecimal(multiplier)
    freeze
  end

  ALL = [
    new(:small, "Klein", "0.7"),
    new(:medium, "Mittel", "1.0"),
    new(:large, "Groß", "1.3")
  ].freeze

  def self.all = ALL

  def self.find(key)
    ALL.find { |size| size.key == key&.to_sym } or raise ArgumentError, "Unknown size: #{key.inspect}"
  end

  # Scales a cent amount by the size's multiplier, rounded half up to whole cents.
  def scale(cents)
    (cents * multiplier).round(0, :half_up).to_i
  end

  def ==(other) = other.is_a?(Size) && other.key == key
  alias eql? ==
  def hash = key.hash
  def to_s = label
  def inspect = "#<Size #{key}>"

  # Lets a record declare `attribute :size, Size::Type.new`: stored as the key,
  # read back as a Size, assignable as either. Unknown keys cast to nil.
  class Type < ActiveModel::Type::Value
    def cast(value)
      return value if value.is_a?(Size) || value.nil?

      ALL.find { |size| size.key.to_s == value.to_s }
    end

    def serialize(size)
      size&.key&.to_s
    end
  end
end
