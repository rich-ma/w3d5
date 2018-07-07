require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @result if @result
    @result = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    LIMIT 0
    SQL
    @result = @result.first.map {|el| el.to_sym}
  end

  def self.finalize!
    self.columns
    @result.each do |attribute|
      define_method("#{attribute}=") do |val|
        attributes[attribute] = val
      end

      define_method(attribute) do
        attributes[attribute]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    self.to_s.downcase + "s"
  end

  def self.all
    results = DBConnection.execute2(<<-SQL)
    SELECT
    *
    FROM
    #{self.table_name}
    SQL
    self.parse_all(results[1..-1])
  end

  def self.parse_all(results)
    results.map do |obj_info|
      self.new(obj_info)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL,id)
    SELECT
    *
    FROM
    #{self.table_name}
    WHERE
    #{self.table_name}.id = ?
    SQL


    return nil if result.empty?
    self.parse_all(result).first
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |attribute, val|
      attribute.is_a?(Symbol) ? attribute : attribute = attribute.to_sym
      raise "unknown attribute '#{attribute}'" unless columns.include?(attribute)
      self.send("#{attribute}=".to_sym, val)
    end
  end

  def attributes
    return @attributes = {} unless @attributes
    @attributes
  end

  def attribute_values
    @attributes.values
  end

  def insert

    # DBConnection.execute2(<<-SQL,id)
    # INSERT INTO
    #   #{self.table_name} (?,?,)
    # VALUES
    # (?, ?, ?)
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
