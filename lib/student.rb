require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    # using inherited #self.column_names method to map it's corresponding db_table (students) to extract column names and used 
    # them to create attr_accessor keys for Students class
    self.column_names.each do |col|
        attr_accessor col.to_sym
    end

end
