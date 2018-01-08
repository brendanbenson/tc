class Validation::Errors
  attr_reader :field_errors, :global_errors

  def initialize
    @field_errors = []
    @global_errors = []
  end

  def add_global_error(global_error)
    @global_errors << global_error
  end

  def add_field_error(field_error)
    @field_errors << field_error
  end

  def has_errors?
    @field_errors.present? || @global_errors.present?
  end
end