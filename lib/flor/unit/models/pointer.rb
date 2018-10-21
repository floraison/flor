
module Flor

  class Pointer < FlorModel

    #create_table :flor_pointers do
    #
    #  primary_key :id, type: :Integer
    #  String :domain, null: false
    #  String :exid, null: false
    #  String :nid, null: false
    #  String :type, null: false  # task, tasked, tag, var
    #  String :name, null: false # task name, tasked name, tag name, var name
    #  String :value
    #  String :ctime, null: false
    #
    #  # no :status, no :mtime
    #
    #  index :exid
    #  index [ :exid, :nid ]
    #  index [ :type, :name, :value ]
    #
    #  String :cunit
    #  String :munit
    #
    #  #unique [ :exid, :type, :name, :value ]
    #    # we don't care, pointers are cleaned anyway when the flow dies
    #end
  end
end

