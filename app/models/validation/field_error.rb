class Validation::FieldError
  attr_reader :rejected_value, :code, :field

  def initialize(field, code, rejected_value)
    @field = field
    @code = code
    @rejected_value = rejected_value
  end
end
