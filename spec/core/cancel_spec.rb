
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
           .select { |m|
             m['cause'] }
           .collect { |m|
             c = m['cause']
             "#{m['point']} #{m['nid']} cause:#{c['cause']}:#{c['nid']}" }
       ).to eq([
         'cancel 0_0 cause:cancel:0_0',
         'cancel 0_0_0 cause:cancel:0_0',
         'receive 0_0 cause:cancel:0_0',
         'receive 0 cause:cancel:0_0',
         'receive  cause:cancel:0_0'
       ])
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
         (status ended pt:receive fro:0_1_0 m:30)
         (status closed pt:cancel fla:cancel fro:0_1_1_1 m:25)
         (status o pt:execute)
       }.ftrim)
     end
  end
end

