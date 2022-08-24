# frozen_string_literal: true


module Flor

  class Message < FlorModel

    #create_table :flor_messages do
    #
    #  primary_key :id, type: :Integer
    #  String :domain, null: false
    #  String :exid, null: false
    #  String :point, null: false # 'execute', 'task', 'receive', ...
    #  File :content # JSON
    #  String :status, null: false
    #  String :ctime, null: false
    #  String :mtime, null: false
    #  String :cunit
    #  String :munit
    #
    #  index :exid
    #end

    def nid; data['nid']; end
    def tasker; data['tasker']; end
    alias payload data

    def fei; [ exid, nid ].join('-') rescue nil; end
  end
end

