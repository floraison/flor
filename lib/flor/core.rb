#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
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

  def self.generate_exid(domain, unit)

    @exid_counter ||= 0
    @exid_mutex ||= Mutex.new

    t = Time.now.utc

    sus =
      @exid_mutex.synchronize do

        sus = t.sec * 100000000 + t.usec * 100 + @exid_counter

        @exid_counter = @exid_counter + 1
        @exid_counter = 0 if @exid_counter > 99

        Munemo.to_s(sus)
      end

    t = t.strftime('%Y%m%d.%H%M')

    "#{domain}-#{unit}-#{t}.#{sus}"
  end

  def self.make_launch_msg(exid, tree, opts)

    t =
      tree.is_a?(String) ?
      Flor::Lang.parse(tree, opts[:fname], opts) :
      tree

    unless t
      #h = opts.merge(prune: false, rewrite: false)
      #p Flor::Lang.parse(tree, h[:fname], h)
        # TODO re-parse and indicate what went wrong...
      fail ArgumentError.new('flor parse failure')
    end

    pl = opts[:payload] || opts[:fields] || {}
    vs = opts[:variables] || opts[:vars] || {}

    msg =
      { 'point' => 'execute',
        'exid' => exid,
        'nid' => '0',
        'tree' => t,
        'payload' => pl,
        'vars' => vs }

    msg['dvars'] = opts[:dvariables] \
      if opts.has_key?(:dvariables)

    msg
  end

  def self.load_procedures(dir)

    dirpath =
      if dir.match(/\A[.\/]/)
        File.join(dir, '*.rb')
      else
        File.join(File.dirname(__FILE__), dir, '*.rb')
      end

    Dir[dirpath].each { |path| require(path) }
  end
end

