require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize(options = {})
    options.each{|key, value| send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    col_names = []
    self.class.column_names.each do |col_name|
      col_names << "#{col_name}" unless send(col_name).nil?
    end
    col_names.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(key_value)
    key_value = key_value.flatten
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{key_value[0].to_s} = ?
    SQL
    puts sql
    DB[:conn].execute(sql, key_value[1])
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).map{|column| column["name"]}
  end

end