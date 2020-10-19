# frozen_string_literal: true

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
      Flor.parse(tree, opts[:fname] || opts[:path], opts) :
      tree

    unless t

      #h = opts.merge(prune: false, rewrite: false, debug: 0)
      #Raabro.pp(Flor.parse(tree, h[:fname], h))
        # TODO re-parse and indicate what went wrong...

      fail ArgumentError.new(
        "flow parsing failed: " + tree.inspect[0, 35] + '...')
    end

    pl = opts[:payload] || opts[:fields] || {}
    vs = opts[:variables] || opts[:vars] || {}

    fail ArgumentError.new(
      "given launch payload should be a Hash, but it's a #{pl.class}"
    ) unless pl.is_a?(Hash)
    fail ArgumentError.new(
      "given launch variables should come in a Hash, but it's a #{vs.class}"
    ) unless vs.is_a?(Hash)

    msg = {
      'point' => 'execute',
      'exid' => exid,
      'nid' => '0',
      'tree' => t,
      'payload' => pl,
      'vars' => vs }

    msg['vdomain'] = opts[:vdomain] \
      if opts.has_key?(:vdomain)

    msg
  end

  def self.load_procedures(dir)

    dirpath =
      if dir.match(/\A[.\/]/)
        File.join(dir, '*.rb')
      else
        File.join(File.dirname(__FILE__), dir, '*.rb')
      end

    Dir[dirpath].sort.each { |path| require(path) }
  end
end

