require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # @class_name.constantize
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # debugger
    options[:foreign_key].nil? ? @foreign_key = :house_id : @foreign_key = options[:foreign_key]
    options[:class_name].nil? ? @class_name = 'House' : @class_name = options[:class_name]
    options[:primary_key].nil? ? @primary_key = :id : @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options[:foreign_key].nil? ? @foreign_key = :human_id : @foreign_key = options[:foreign_key]
    options[:class_name].nil? ? @class_name = 'Cat' : @class_name = options[:class_name]
    options[:primary_key].nil? ? @primary_key = :id : @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
