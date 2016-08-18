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

  class Loader

    # NB: tasker configuration entries start with "loa_"

    def initialize(unit)

      @unit = unit

      @cache = {}
      @mutex = Mutex.new
    end

    def shutdown
    end

    def variables(domain)

      Dir[File.join(root, '**/*.json')]
        .select { |f| f.index('/etc/variables/') }
        .sort # just to be sure
        .sort_by(&:length)
        .select { |f| path_matches?(domain, f) }
        .inject({}) { |vars, f| vars.merge!(interpret(f)) }
    end

    #def procedures(path)
    #
    #  # TODO
    #  # TODO work with Flor.load_procedures
    #end

    def library(domain, name=nil)

      domain, name = split_dn(domain, name)

      path =
        (Dir[File.join(root, '**/*.{flon,flor}')])
          .sort
          .sort_by(&:length)
          .select { |f| f.index('/lib/') }
          .select { |f| path_name_matches?(domain, name, f) }
          .first

      path ? File.read(path) : nil
    end

    def tasker(domain, name=nil)

      domain, name = split_dn(domain, name)

      path = Dir[File.join(root, '**/*.json')]
        .select { |f| f.index('/lib/taskers/') }
        .sort # just to be sure
        .sort_by(&:length)
        .select { |f| path_name_matches?(domain, name, f) }
        .last

      path ? interpret(path) : nil
    end

    protected

    def split_dn(domain, name)

      if name
        [ domain, name ]
      else
        elts = domain.split('.')
        [ elts[0..-2].join('.'), elts[-1] ]
      end
    end

    def root

      if lp = @unit.conf['lod_path']
        File.absolute_path(lp)
      else
        File.dirname(File.absolute_path(@unit.conf['_path'] + '/..'))
      end
    end

    def path_matches?(domain, f)

      f = f[root.length..-1]
      f = f[5..-1] if f[0, 5] == '/usr/'

      f = f
        .sub(/\/etc\/variables\//, '/')
        .sub(/\/lib\/(flows|taskers)\//, '/')
        .sub(/\/\z/, '')
        .sub(/\/(flon|flor|dot)\.json\z/, '')
        .sub(/\.(flon|flor|json)\z/, '')
        .sub(/\A\//, '')
        .gsub(/\//, '.')

#p [ :pm, domain[0, f.length], f, '=>', domain[0, f.length] == f ]
      domain[0, f.length] == f
    end

    def path_name_matches?(domain, name, f)

#p [ :pnm, domain, name, f ]
      f = f.sub(/\/(flon|flor|dot)\.json\z/, '.json')

      return false if File.basename(f).split('.').first != name

      path_matches?(domain, File.dirname(f) + '/')
    end

    def interpret(path)

      @mutex.synchronize do

        mt1 = File.mtime(path)
        val, mt0 = @cache[path]
        #p [ :cached, path ] if val && mt1 == mt0
        return val if val && mt1 == mt0

        (@cache[path] = [ Flor::ConfExecutor.interpret(path), mt1 ]).first
      end
    end
  end
end

