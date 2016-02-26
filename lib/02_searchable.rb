require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'
module Searchable
  def where(params)
    attribute_values = params.values
    params = params.keys.map { |col| "#{col} = ?" }.join(" AND ")


    result = DBConnection.execute(<<-SQL, *attribute_values)
      select
        *
      from
        #{self.table_name}
      where
        #{params}
    SQL
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
