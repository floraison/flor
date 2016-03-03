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

  class Executor

    attr_reader :execution
    attr_reader :options

    def initialize(opts)

      @options =
        (ENV['FLOR_DEBUG'] || '').split(',').inject({}) { |h, k|
          kv = k.split(':')
          h[kv[0].to_sym] = kv[1] ? JSON.parse(kv[1]) : true
          h
        }
      @options.merge!({ err: 1, log: 1, tree: 1 }) if @options[:all]

      @options.merge!(opts)
    end

    protected

    def make_launch_msg(tree, opts)

      t = tree.is_a?(String) ? Flor::Radial.parse(tree, opts[:fname], opts) : t

      unless t
        #h = opts.merge(prune: false, rewrite: false)
        #p Flor::Radial.parse(tree, h[:fname], h)
          # TODO re-parse and indicate what went wrong...
        fail ArgumentError.new('radial parse failure')
      end

      { 'point' => 'execute',
        'exid' => @execution['exid'],
        'nid' => '0',
        'tree' => t,
        'payload' => opts[:payload] || opts[:fields] || {},
        'vars' => opts[:variables] || opts[:vars] || {} }
    end

    def execute(message)

      nid = message['nid']

      now = Flor.tstamp

      node = {
        'nid' => nid,
        'parent' => message['from'],
        'ctime' => now,
        'mtime' => now }

      if vs = message['vars']
        node['vars'] = vs
      end
      if vs = message['tree'][1]['vars']
        node['vars'] = (node['vars'] || {}).merge(vs) if vs.is_a?(Hash)
      end
      if cnid = message['cnid']
        node['cnid'] = cnid
      end

      @execution['nodes'][nid] = node

      apply(node, message)
    end

    def rewrite(tree)

      tree
    end

    def apply(node, message)

      n = Flor::Node.new(@execution, node, message)

      tree0 = n.lookup_tree(node['nid'])
      tree0 = node['tree'] = message['tree'] unless tree0

      tree = rewrite(tree0)

      heat = n.deref(tree[0])

      return error_reply(
        node, message, "don't know how to apply #{Flor.de_val(tree[0]).inspect}"
      ) if heat == nil

      heak =
        if tree[1].empty? && tree[3].empty?
          Flor::Pro::Val
        elsif heat[1]['t'] == 'procedure'
          Flor::Executor.procedures[heat[1]['v']]
        elsif heat[1]['t'] == 'function'
          Flor::Pro::Apply
        else
          Flor::Pro::Val
        end
#p [ 0, :tree, tree ]
#p [ 1, :heat, heat ]
#p [ 2, :heak, heak ]

      head = heak.new(@execution, node, message)
      head.heat = heat if head.respond_to?(:heat=)

      head.send(message['point'])
    end

#    def expand(o, expander)
#
#      case o
#        when Array
#          o.collect { |e| expand(e, expander) }
#        when Hash
#          o.inject({}) { |h, (k, v)|
#            h[expand(k, expander)] = expand(v, expander); h }
#        when String
#          expander.expand(o)
#        else
#          o
#      end
#    end

#    def rewrite_tree(node, message)
#
#      tree0 = message['tree']
#
#      expander = Flor::Instruction.new(@execution, node, message, true)
#
#      tree1 = [ *expand(tree0[0, 2], expander), *tree0[2..-1] ]
#      tree1 = rewrite(node, message, tree1)
#
#      # TODO beware always reduplicating the tree children
#      # TODO should be OK, the rewrite_ methods return a new tree as soon
#      #      as they rewrite
#
#      node['inst'] = tree1.first
#      node['tree'] = tree1 if node['nid'] == '0' || tree1 != tree0
#    end

    def receive(message)

      from = message['from']

#p [ :delete, from ]
      fnode = @execution['nodes'][from]
      if fnode
        fnode['deleted'] = true
        @execution['nodes'].delete(from) if (fnode['closures'] || []).empty?
      end

      nid = message['nid']

      return [
        message.merge('point' => 'terminated', 'vars' => (fnode || {})['vars'])
      ] if nid == nil

      node = @execution['nodes'][nid]

      apply(node, message)
    end

    def log(m)

      _dg, _yl, _rs =
        $stdout.tty? ? [ "[1;30m", "[1;33m", "[0;0m" ] : [ '', '', '' ]

      pt = m['point'][0, 3]
      ni = m['nid'] ? " #{m['nid']}" : ''
      fr = m['from'] ? " from #{m['from']}" : ''

      t = m['tree'];
      t0 = t ? " [#{_yl}#{t[0]}#{_dg}" : ''
      #t = t ? " #{t[1..-2].inspect[1..-2]}]" : ''
      t = t ? " #{Flor.to_d(t[1])} #{t[2]}]" : ''

      ind = '  ' * ni.split('_').size

      puts "#{_dg}#{ind}#{pt}#{ni}#{t0}#{t}#{fr}#{_rs}"
    end

    def print_tree(tree, nid='0')

      _dg, _yl, _rs =
        $stdout.tty? ? [ "[1;30m", "[1;33m", "[0;0m" ] : [ '', '', '' ]

      puts "#{_dg}+" if nid == '0'
      puts "#{_dg}| #{nid} #{_yl}#{tree[0]}#{_dg} #{Flor.to_d(tree[1])} #{tree[2]} #{tree[4]}#{_rs}"
      tree[3].each_with_index { |ct, i| print_tree(ct, "#{nid}_#{i}") }
      puts "#{_dg}+#{_rs}" if nid == '0'
    end

    def generate_exid(domain)

      @exid_counter ||= 0
      @exid_mutex ||= Mutex.new

      local = true

      uid = 'u0'

      t = Time.now
      t = t.utc unless local

      sus =
        @exid_mutex.synchronize do

          sus = t.sec * 100000000 + t.usec * 100 + @exid_counter

          @exid_counter = @exid_counter + 1
          @exid_counter = 0 if @exid_counter > 99

          Munemo.to_s(sus)
        end

      t = t.strftime('%Y%m%d.%H%M')

      "#{domain}-#{uid}-#{t}.#{sus}"
    end

    def error_reply(node, message, o)

      # TODO: use node (which may be nil)

      m = { 'point' => 'failed' }
      m['fpoint'] = message['point']
      m['exid'] = message['exid']
      m['nid'] = message['nid']
      m['from'] = message['from']
      m['payload'] = message['payload']
      m['tree'] = message['tree']
      m['error'] = Flor.to_error(o)

      [ m ]
    end
  end

  # class methods
  #
  class Executor

    def self.procedures

      @@procedures ||= {}
    end
  end

  class TransientExecutor < Executor

    def initialize(opts={})

      super(opts)

      @execution = {
        'exid' => generate_exid('eval'),
        'nodes' => {},
        'errors' => [],
        'counters' => { 'sub' => 0, 'fun' => -1 } }
    end

    def launch(tree, opts={})

      messages = [ make_launch_msg(tree, opts) ]
      message = nil

      print_tree(messages.first['tree']) if @options[:tree]

      loop do

        message = messages.pop

        break unless message

        log(message) if @options[:log]

        point = message['point']

        pp message if point == 'failed' && @options[:err]

        break if point == 'failed'
        break if point == 'terminated'

        msgs =
          begin
            self.send(point.to_sym, message)
          rescue => e
            error_reply(nil, message, e)
          end

        messages.concat(msgs)
      end

      message
    end
  end
end

