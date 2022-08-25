require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song
    # .table name
    def self.table_name
       self.to_s.downcase.pluralize
    end

    # .column names
    def self.column_names
        DB[:conn].results_as_hash = true
        table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
        column_names = []
        table_info.each do |column|
            column_names << column["name"]
        end
        column_names.compact
    end

    #creating attr_accessor by metaprogramming
    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

    #initialize method
    def initialize (option={})
        option.each do |prop, value|
            self.send("#{prop}=", value)
        end
    end

    #table_to_ into ==== getting the table name to be populated
    def table_to_insert_into 
        self.class.table_name
    end

    # #column to insert into
    def column_names_for_insert
       self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    #values to insert
    def values_to_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        valuse.join(", ")
    end

    # save method
    def save
        DB[:conn].execute("INSERT INTO #{table_to_insert_into} (#{olumn_names_for_insert}) VALUES (?)", [values_to_insert])
      
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_to_insert_into}")[0][0]
    end

    # class find method
    def self.find_by_name (name)
        DB[:conn].execute("SELECT * FROM #{table_to_insert_into} WHERE name = ?", [name])
    end
end
