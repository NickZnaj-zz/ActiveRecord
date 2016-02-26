require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @col_names if @col_names

    array = DBConnection.execute2(<<-SQL)
      select
        *
      FROM
        #{self.table_name}
    SQL

    col_names = array.first
    @col_names = col_names.map{ |col| col.to_sym }
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end
    end

    self.columns.each do |col|
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name.tableize
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
      select
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    parse_all(result)

  end

  def self.parse_all(results)

    results.map { |thing| self.new(thing) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      select
        *
      FROM
        #{self.table_name}
      where

        id = (?)
    SQL

    result.empty? ? nil : parse_all(result).first
  end

  def initialize(params = {})
    params = params.each { |key, _| key.to_sym }
    cols = self.class.columns.each
    params.each do |k, v|

      if cols.include?(k.to_sym)
        self.send("#{k}=", v)
      else
        raise "unknown attribute '#{k}'"
      end
    end
  end

  def attributes
    @attributes ||= {}

  end

  def attribute_values
    result = []
    self.class.columns.each { |v| result << self.send(v) }
    result
  end

  def insert
    col_names = self.class.columns
    question_marks = (["?"] * col_names.length).join(",")

    result = DBConnection.execute(<<-SQL, *attribute_values)
      insert into
        #{self.class.table_name} (#{col_names.join(", ")})
      values
        (#{question_marks})
    SQL

    new_id = DBConnection.last_insert_row_id
    self.id = new_id
  end

  def update
    columns = self.class.columns.map { |col| "#{col} = ?" }.join(",")

    result = DBConnection.execute(<<-SQL, *attribute_values, id)
      update
        #{self.class.table_name}
      set
        #{columns}
      where
        id = ?
    SQL
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
  end
end
