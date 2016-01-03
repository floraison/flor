
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


class Flor::Storage

  def initialize(uri, opts={})

    @con = Sequel.connect(uri)

    delete_tables if opts[:storage_clean]
  end

  def connection; @con; end

  def store_message(subtype, msg)

    @con[:flor_items].insert(
      type: 'message',
      subtype: subtype.to_s,
      domain: msg[:domain] || msg['domain'],
      exid: msg[:exid] || msg['exid'],
      content: Sequel.blob(JSON.dump(msg)),
      status: 'created',
      tstamp: Time.now)
  end

  def list_schedules

    @con[:flor_items]
      .where(type: 'schedule', status: 'created')
      .order(:id)
      .all
      .collect { |h| Flor::Schedule.new(h) }
  end

  def list_dispatcher_messages

    @con[:flor_items]
      .where(type: 'message', subtype: 'dispatcher', status: 'created')
      .order(:id)
      .all
      .collect { |h| Flor::Message.new(h) }
  end

  def load_execution(exid)

    Flor::Execution.new(
      @con[:flor_items]
        .where(type: 'execution', status: 'created', exid: exid)
        .first)
  end

  def flag_as_consumed(items)

    ids = items.collect(&:id).compact

    return if ids.empty?

    @con[:flor_items]
      .where(id: ids)
      .update(status: 'consumed')
  end

  def create_tables

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

  def delete_tables

    @con[:flor_items].delete
  end
end

