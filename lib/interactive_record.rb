require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "pragma table_info('#{table_name}')"
        columns = DB[:conn].execute(sql)

        col_names = []
        columns.each do |col|
            col_names << col["name"]
        end
        col_names.compact
    end
  
    def initialize(params = {})
        params.each do |k,v|
            self.send("#{k}=", v)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    # iterate through all colums of parent class, use send_method(to set each column as getter function) in order to 
    # get value of column,  send value to value[] unless value is nil, (as "id" column is deleted during insertion into db)
    def values_for_insert
        values = []
        self.class.column_names.each do |col|
            values << "'#{send(col)}'" unless send(col).nil?
        end
        values.join(", ")
    end


    # interpolate table_name , table_Columns and table_values into sql script, grab db id and set as Instance id.
    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
    
    def self.find_by_name(name)
        sql = "select * from '#{self.table_name}' where name = ? "
        DB[:conn].execute(sql, name)
    end

    def self.find_by(name)
        sql = "select * from '#{self.table_name}' where name = ? "
        DB[:conn].execute(sql, name)

    end

    # for any number of attributes passed as params, select the first one
    # check if  first value selected is integer, 
    def self.find_by(attribute_hash)
        value = attribute_hash.values.first
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
        DB[:conn].execute(sql)
    end



end