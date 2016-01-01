
#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'logger'
require 'sequel'


module Flor

  module Db

    @con = Sequel.connect('sqlite:.')
      # connection to an empty memory database
      # before Flor::Db.connect() gets called

    def self.connect(uri)

      @con = Sequel.connect(uri)

      Flor::Db::Message
        .set_dataset(@con[:flor_items].where(type: 'message'))
      Flor::Db::Execution
        .set_dataset(@con[:flor_items].where(type: 'execution'))
      Flor::Db::Schedule
        .set_dataset(@con[:flor_items].where(type: 'schedule'))
    end

    def self.create_tables

      @con.create_table :flor_items do

        primary_key :id, type: Bignum
        String :type, null: false # 'execution', 'mdis', 'mexe', 'schedule', ...
        String :subtype
        String :schedule # '20141128.103239' or '00 23 * * *'
        String :domain, null: false
        String :exid, null: false
        File :content, null: false # JSON
        String :status, null: false # 'created' or something else
        Time :tstamp, null: false

        index :type
        index :domain
        index :exid
      end
    end

    class Execution < Sequel::Model
      #
      #self.set_dataset(Flor::DB[:flor_items].where(type: 'execution'))
    end

    class Message < Sequel::Model
      #
      #self.set_dataset(Flor::DB[:flor_items].where(type: 'message'))

      def self.list(type)

        self.where(type: type).order(:id).all
      end

      def self.store(subtype, msg)

        Flor::Db::Message.insert(
          type: 'message',
          subtype: subtype.to_s,
          domain: msg[:domain] || msg['domain'],
          exid: msg[:exid] || msg['exid'],
          content: Sequel.blob(JSON.dump(msg)),
          status: 'created',
          tstamp: Time.now)
      end
    end

    class Schedule < Sequel::Model
      #
      #self.set_dataset(Flor::DB[:flor_items].where(type: 'schedule'))
    end
  end
end


if $0 == __FILE__

  uri =
    ENV['FLOR_DB_URI'] ||
    case ENV['FLOR_ENV']
      when 'test', 'spec' then 'sqlite://tmp/test.db'
      #else /\Adev(elopment)?\z/ then 'sqlite://tmp/dev.db'
      else 'sqlite://tmp/dev.db'
    end

  puts "Flor::Db.connect(#{uri.inspect})"
  Flor::Db.connect(uri)
  Flor::Db.instance_eval { @con.loggers << Logger.new($stdout) }
  Flor::Db.create_tables
end

