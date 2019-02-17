
#
# specifying flor
#
# Sun Jul 10 06:48:32 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a hook' do

    it 'is given the opportunity to see any message' do

      msgs = new_safe_array
      @unit.hook do |message|
        msgs << Flor.dup(message) if message['consumed']
        [] # make sure to return an empty list of new messages
      end

      @unit.launch(%{
        sequence
          noret _
      }, wait: true)

      sleep 0.770 # the wait might exit before the hook, especially on JRuby

      expect(
        msgs
          .collect { |m| %w[ point nid ].collect { |k| m[k].to_s }.join('-') }
          .join("\n")
      ).to eq(
        @unit.journal
          .collect { |m| %w[ point nid ].collect { |k| m[k].to_s }.join('-') }
          .join("\n")
      )
    end

    it 'may alter a message' do

      @unit.hook do |message|
        next if message['consumed']
        next unless message['point'] == 'execute'
        message['tree'][1] = 'blue' if message['tree'][0] == '_sqs'
      end

      @unit.launch(%{
        sequence
          trace 'red'
      }, wait: true)

      expect(
        @unit.traces.collect { |t| "#{t.nid}:#{t.text}" }
      ).to eq(%w[
        0_0:blue
      ])
    end
  end

  describe 'Flor::Scheduler#hook' do

    it 'may filter on consumed:/c:' do

      ncms = new_safe_array
      @unit.hook(consumed: false) { |m| ncms << Flor.dup(m); [] }
      cms = new_safe_array
      @unit.hook(c: true) { |m| cms << Flor.dup(m); [] }
      ms = new_safe_array
      @unit.hook { |m| ms << Flor.dup(m); [] }

      @unit.launch(
        %q{
          sequence
            noret _
        })

      wait_until { ms.size == 15 }

      expect([ ms.size, cms.size, ncms.size ]).to eq([ 15, 8, 7 ])
    end

    it 'may filter on point:/p:' do

begin
      ms0 = new_safe_array
      @unit.hook(point: 'execute') { |m| ms0 << Flor.dup(m); [] }
      ms1 = new_safe_array
      @unit.hook(p: %w[ execute terminated ]) { |m| ms1 << Flor.dup(m); [] }

      @unit.launch(%{
        sequence
          noret _
      }, wait: true)

      expect(
        ms0.collect { |m| m['point'] }.uniq).to eq(%w[ execute ])
      expect(
        ms1.collect { |m| m['point'] }.uniq).to eq(%w[ execute terminated ])
rescue (defined?(Java::JavaLang::Exception) ? Java::JavaLang::Exception : Exception) => ex
  puts "=" * 80
  p ex.inspect
  puts ex.backtrace
  puts "-" * 80
  fail "**INTERCEPTED**"
end
    end

    it 'may filter on domain:/d:' do

      ms0 = new_safe_array
      @unit.hook(domain: 'com.acme') { |m| ms0 << Flor.dup(m); [] }
      ms1 = new_safe_array
      @unit.hook(d: %w[ com.acme org.acme ]) { |m| ms1 << Flor.dup(m); [] }
      ms2 = new_safe_array
      @unit.hook(d: /\A(com|org)\.acme(\.|$)/) { |m| ms2 << Flor.dup(m); [] }
      ms3 = new_safe_array
      @unit.hook(d: /\Anet\.acme(\.|$)/) { |m| ms2 << Flor.dup(m); [] }

      rs = []
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'com.acme')
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'org.acme')
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'za.co.acme')
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'org.acme.sub0')

      expect(rs.collect { |r| r['point'] }.uniq).to eq(%w[ terminated ])

      sleep 0.4

      expect(ms0.size).to eq(11)
      expect(ms1.size).to eq(22)
      expect(ms2.size).to eq(33)
      expect(ms3.size).to eq(0)
    end

    it 'may filter on subdomain:/sd: (domain and its subdomains)' do

      ms0 = new_safe_array
      @unit.hook(subdomain: 'com.acme') { |m| ms0 << Flor.dup(m); [] }
      ms1 = new_safe_array
      @unit.hook(subdomain: [ 'com', 'org' ]) { |m| ms1 << Flor.dup(m); [] }
      ms2 = new_safe_array
      @unit.hook(subdomain: 'net') { |m| ms2 << Flor.dup(m); [] }

      rs = []
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'com.acme')
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'com.acme.sub0')
      rs << @unit.launch(%{ noret _ }, wait: true, domain: 'org.acme.sub0')

      expect(rs.collect { |r| r['point'] }.uniq).to eq(%w[ terminated ])

      sleep 0.4

      expect(ms0.size).to eq(22)
      expect(ms1.size).to eq(33)
      expect(ms2.size).to eq(0)
    end

    it 'may filter on heap:/hp:' do

      ms0 = new_safe_array
      @unit.hook(heap: 'sequence') { |m| ms0 << Flor.dup(m); [] }
      ms1 = new_safe_array
      @unit.hook(hp: %w[ sequence noret ]) { |m| ms1 << Flor.dup(m); [] }

      @unit.launch(%{
        sequence
          noret _
      }, wait: true)

      expect(
        F.to_s(ms0.reject { |m| ! m['consumed'] })
      ).to eq(%{
        (msg 0 execute)
        (msg 0 receive from:0_0)
      }.ftrim)

      expect(
        F.to_s(ms1.reject { |m| ! m['consumed'] })
      ).to eq(%{
        (msg 0 execute)
        (msg 0_0 execute from:0)
        (msg 0_0 receive from:0_0_0)
        (msg 0 receive from:0_0)
      }.ftrim)
    end

    it 'may filter on heat:/ht:' do

      ms0 = new_safe_array
      @unit.hook(heat: 'fun0', c: false) do |x, m, o|
        #pp m
        #pp x.node(m['nid'])
        ms0 << Flor.dup(m)
        []
      end

      ms1 = new_safe_array
      @unit.hook(ht: %w[ fun1 ], c: false) do |x, m, o|
        ms1 << Flor.dup(m)
        []
      end

      r =
        @unit.launch(%q{
          define fun0 x \ trace "fun0:$(x)"
          define fun1 x \ trace "fun1:$(x)"
          sequence
            fun0 'a'
            fun1 'b'
        }, wait: true)

      expect(r).to have_terminated_as_point

      expect(
        @unit.traces.collect { |t| "#{t.nid}:#{t.text}" }
      ).to eq(%w[
        0_0_2-1:fun0:a
        0_1_2-2:fun1:b
      ])

      expect(
        ms0.collect { |m| m['nid'] }).to eq(%w[ 0_2_0 ] * 3)
      expect(
        ms0.collect { |m| m['point'] }).to eq(%w[ execute receive receive ])

      expect(
        ms1.collect { |m| m['nid'] }).to eq(%w[ 0_2_1 ] * 3)
      expect(
        ms1.collect { |m| m['point'] }).to eq(%w[ execute receive receive ])
    end

    it 'may filter on tag:/t:' do

      ms0 = new_safe_array
      @unit.hook(tag: 'blue', c: false) { |x, m, o| ms0 << Flor.dup(m); [] }
      ms1 = new_safe_array
      @unit.hook(tag: 'yellow', c: false) { |x, m, o| ms1 << Flor.dup(m); [] }

      r =
        @unit.launch(%{
          sequence tag: 'blue'
            trace 'blue'
          sequence tag: 'yellow'
            trace 'yellow'
        }, wait: true)

      expect(r).to have_terminated_as_point

      expect(
        @unit.traces.collect { |t| "#{t.nid}:#{t.text}" }
      ).to eq(%w[
        0_0_1:blue
        0_1_1:yellow
      ])

      expect(
        ms0.collect { |m| "#{m['point']}:#{m['nid']}" }
      ).to eq(%w[ entered:0_0 left:0_0 ])
      expect(
        ms1.collect { |m| "#{m['point']}:#{m['nid']}" }
      ).to eq(%w[ entered:0_1 left:0_1 ])
    end

    it 'may filter on t: and p:' do

      ms0 = new_safe_array
      @unit.hook(tag: 'blue', c: false, p: 'entered') { |x, m, o|
        ms0 << Flor.dup(m)
        []
      }
      ms1 = new_safe_array
      @unit.hook(
        t: %w[ blue yellow ], c: false, p: %w[ entered left ]
      ) { |x, m, o|
        ms1 << Flor.dup(m)
        []
      }

      r =
        @unit.launch(%{
          sequence tag: 'blue'
            trace 'blue'
          sequence tag: 'yellow'
            trace 'yellow'
        }, wait: true)

      expect(r).to have_terminated_as_point

      expect(
        @unit.traces.collect { |t| "#{t.nid}:#{t.text}" }
      ).to eq(%w[
        0_0_1:blue
        0_1_1:yellow
      ])

      expect(
        ms0.collect { |m| "#{m['point']}:#{m['nid']}" }
      ).to eq(%w[ entered:0_0 ])
      expect(
        ms1.collect { |m| "#{m['point']}:#{m['nid']}" }
      ).to eq(%w[ entered:0_0 left:0_0 entered:0_1 left:0_1 ])
    end
  end
end

