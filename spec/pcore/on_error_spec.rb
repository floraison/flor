
#
# specifying flor
#
# Sun May  6 05:54:58 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'on_error' do

    it 'binds in the parent node' do

      @executor.launch(
        %q{
          sequence
            on_error (def err \ _)
            stall _
        })

      expect(
        @executor.execution['nodes']['0']['on_error']
      ).to eq([
        [ [ '*' ],
          [ '_func',
            { 'nid' => '0_0_0',
              'tree' => [
                'def', [
                  [ '_att', [ [ 'err', [], 3 ] ], 3 ], [ '_', [], 3 ] ], 3],
              'cnid' => '0',
              'fun' => 0,
              'on_error' => true },
            3 ] ]
      ])
    end

    it 'binds with criteria' do

      @executor.launch(
        %q{
          sequence
            on_error (def err \ _) (/it failed/) class: 'RuntimeError'
            stall _
        })

      expect(
        @executor.execution['nodes']['0']['on_error']
      ).to eq([
        [ [ [ 'class', 'RuntimeError', 3 ],
            [ '_rxs', '/it failed/', 3 ] ],
          [ '_func',
            { 'nid' => '0_0_1',
              'tree' => [
                'def', [
                  [ '_att', [ [ 'err', [], 3 ] ], 3 ], [ '_', [], 3 ] ], 3],
              'cnid' => '0',
              'fun' => 0,
              'on_error' => true },
            3 ] ]
      ])
    end

    it 'triggers on error' do

      r = @executor.launch(
        %q{
          #define eh err
          #  push f.l err.error.msg
          sequence
            on_error (def err \ push f.l err.error.msg)
            #on_error eh
            push f.l 0
            push f.l x
            push f.l 1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, "don't know how to apply \"x\"" ])
    end

    it 'triggers on error (class criteria match)' do

      r = @executor.launch(
        %q{
          define on_err x
            def err \ push f.l [ x, err.error.msg ]
          sequence
            set f.l []
            on_error class: 'NadaError' (on_err 'n')  # no
            on_error class: 'FlorError' (on_err 'F')  # YES
            on_error (on_err '*')                     # no
            push f.l 0
            push f.l x                                # FAILS! ^^^
            push f.l 1
        })

      expect(
        r['point']
      ).to eq('terminated')
      expect(
        r['payload']['l']
      ).to eq([ 0, [ 'F', "don't know how to apply \"x\"" ] ])
    end

    it 'triggers on error (string criteria match)'
    it 'triggers on error (regex criteria match)'

    it 'does not trigger on error (criteria mismatch)'
  end
end

