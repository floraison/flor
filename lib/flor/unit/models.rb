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

  DUMMY_DB = Sequel.connect(
    RUBY_PLATFORM.match(/java/) ? 'jdbc:sqlite::memory:' : 'sqlite::memory:')
      # TODO use dummy adapter not something real like sqlite...

  class Execution < Sequel::Model(DUMMY_DB)
  end
  #class Task < Sequel::Model(DUMMY_DB)
  #end

  DUMMY_DB.disconnect

  class Scheduler

    def executions

      @storage.models[:executions] ||=
        Class.new(Flor::Execution) do
          self.dataset = @storage.db[:flor_executions]
        end
    end

    #def tasks
    #
    #  (@model_cache ||= {})[""] ||=
    #    Class.new(Flor::Task) do
    #      self.dataset = @storage.db[:flor_tasks]
    #    end
    #end
  end
end

