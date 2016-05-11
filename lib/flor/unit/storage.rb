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


module Flor

  class Storage

    attr_reader :unit, :db

    def initialize(unit)

      @unit = unit
      @db = connect
    end

    def migrate(to=nil, from=nil)

      dir = @unit.conf['db_migrations'] || 'migrations'

      Sequel::Migrator.apply(@db, dir, to, from)
    end

    def clear

      [ :flon_messages, :flon_executions, :flon_timers, :flon_logs ].each do |t|
        @db[t].delete
      end
    end

#    def fetch_messages
#
#      @db[:flon_messages]
#        .select(:id, :content)
#        .where(status: 'created')
#        .order_by(:id)
#        .collect { |m| r = m.content; r['mid'] = m.id; r }
#    end

    def load_exids

      @db[:flon_messages]
        .select(:exid)
        .where(status: 'created')
        .order_by(:ctime)
        .distinct
        .all
        .collect { |r| r[:exid] }
    end

    def load_timers

      @db[:flon_timers]
        .select(:id, :content)
        .where(status: 'created')
        .order_by(:id)
        .collect { |m| r = m.content; r['mid'] = m.id; r }
    end

    def put_message(m)

      @db[:flon_messages]
        .insert(
          exid: m['exid'],
          point: m['point'],
          content: Sequel.blob(JSON.dump(m)),
          status: 'created',
          ctime: Time.now)
    end

    protected

    def connect

      Sequel.connect(@unit.conf['sto_uri'])
    end
  end
end

