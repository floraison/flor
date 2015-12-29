
#--
# Copyright (c) 2015-2015, John Mettraux, jmettraux+flon@gmail.com
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

require 'sequel'


module Flor

  module Db

    #def self.configure(uri)
    #  Flor::DB = Sequel.connect(uri)
    #end

    def self.create_tables(db)

      Flor::DB.create_table :flor_items do

        primary_key :id, type: Bignum
        String :type, null: false # 'execution', 'message', 'task', 'schedule'
        String :subtype, null: false
        String :schedule, null: false # '20141128.103239' or '00 23 * * *'
        String :domain, null: false
        String :exid, null: false
        File :content # JSON
        String :status, null: false # 'created' or something else
        Time :tstamp

        index :type
        index :domain
        index :exid
      end
    end

    class Execution < Sequel::Model
      #
      self.set_dataset(
        Flor::DB[:flor_items].where(flor_items__type: 'execution'))
    end

    class Message < Sequel::Model
      #
      self.set_dataset(
        Flor::DB[:flor_items].where(flor_items__type: 'message'))
    end

    class Schedule < Sequel::Model
      #
      self.set_dataset(
        Flor::DB[:flor_items].where(flor_items__type: 'schedule'))
    end
  end
end

