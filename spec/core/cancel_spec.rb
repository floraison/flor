
#
# specifying flor
#
# Fri Dec 30 05:41:07 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # NOTA BENE: using "concurrence" even though it's deemed "unit" and not "core"

  describe 'cancel' do

    it 'cancels' do

      r = @executor.launch(
        %q{
          concurrence
            sequence # 0_0
              stall _
            sequence
              _skip 1
              cancel '0_0'
        },
        archive: true)

      expect(r['point']).to eq('terminated')

      seq = @executor.archive['0_0']

      expect(
        F.to_s(seq, :status)
      ).to eq(%{
        (status ended pt:receive fro:0_0 m:23)
        (status closed pt:cancel fla:cancel fro:0_1_1 m:18)
        (status o pt:execute)
      }.ftrim)

      expect(
        @executor.journal
          .collect { |m|
            cs = (m['cause'] || [])
              .collect { |c| [ c['cause'], c['m'], c['nid'] ].join(':') }
            cs = cs.any? ? " <-" + cs.join('<-') : ''
            "#{m['point']}:#{m['nid']}#{cs}" }
          .join("\n")
      ).to eq(%{
        execute:0
        execute:0_0
        execute:0_1
        execute:0_0_0
        execute:0_1_0
        execute:0_0_0_0
        execute:0_1_0_0
        receive:0_0_0
        execute:0_1_0_0_0
        receive:0_1_0_0
        receive:0_1_0
        receive:0_1
        execute:0_1_1
        execute:0_1_1_0
        execute:0_1_1_0_0
        receive:0_1_1_0
        receive:0_1_1
        cancel:0_0 <-cancel:18:0_0
        receive:0_1
        cancel:0_0_0 <-cancel:20:0_0_0<-cancel:18:0_0
        receive:0
        receive:0_0 <-cancel:20:0_0_0<-cancel:18:0_0
        receive:0 <-cancel:20:0_0_0<-cancel:18:0_0
        receive: <-cancel:20:0_0_0<-cancel:18:0_0
        terminated: <-cancel:20:0_0_0<-cancel:18:0_0
      }.gsub(/\n\s+/, "\n").strip)
    end

    it "doesn't over-cancel" do

      r = @executor.launch(
        %q{
          concurrence
            sequence # 0_0
              sequence
                sequence
                  sequence
                    sequence
                      sequence
                        sequence
                          stall _
            sequence
              _skip 1
              cancel '0_0'
              _skip 1
              cancel '0_0'
        }, archive: true)

      expect(r['point']).to eq('terminated')

      seq = @executor.archive['0_0']

      expect(
        F.to_s(seq, :status)
      ).to eq(%{
        (status ended pt:receive fro:0_0 m:54)
        (status closed pt:cancel fla:cancel fro:0_1_1 m:24)
        (status o pt:execute)
      }.ftrim)
    end

    it 'over-cancels if flavoured' # kill ???????????????????????????????????

    it 'cancels with "cancel" flavour even if aliased' do

      r = @executor.launch(
        %q{
          set fukup cancel
          concurrence
            sequence # 0_1_0
              stall _
            sequence
              _skip 1
              fukup '0_1_0'
        }, archive: true)

      expect(r['point']).to eq('terminated')

      seq = @executor.archive['0_1_0']

      expect(
        F.to_s(seq, :status)
      ).to eq(%{
        (status ended pt:receive fro:0_1_0 m:34)
        (status closed pt:cancel fla:cancel fro:0_1_1_1 m:29)
        (status o pt:execute)
      }.ftrim)
    end
  end
end

