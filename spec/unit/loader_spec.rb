
#
# specifying flor
#
# Sat Jun 18 16:43:30 JST 2016
#

require 'spec_helper'


describe Flor::Loader do

  before :each do

    unit =
      OpenStruct.new(conf: {
        'lod_path' => File.dirname(__FILE__) + '/loader/'
      })
    @loader = Flor::Loader.new(unit)
  end

  # spec/unit/loader
  # ├── etc
  # │   └── variables
  # │       ├── dot.json
  # │       ├── net.example.json
  # │       └── net.json
  # ├── lib
  # │   ├── flows
  # │   │   ├── net.example
  # │   │   │   └── flow0.flon
  # │   │   └── org.example
  # │   │       └── flow0.flon
  # │   └── taskers
  # │       ├── alice
  # │       │   └── dot.json
  # │       ├── net.example
  # │       │   └── .gitkeep
  # │       └── org.example
  # │           ├── alice
  # │           │   └── dot.json
  # │           └── bob
  # │               └── dot.json
  # └── usr
  #     ├── net.example
  #     │   ├── etc
  #     │   │   └── variables
  #     │   │       └── dot.json
  #     │   └── lib
  #     │       ├── flows
  #     │       │   └── flow1.flon
  #     │       └── taskers
  #     │           └── bob
  #     │               └── dot.json
  #     └── org.example
  #         ├── etc
  #         │   └── variables
  #         │       └── dot.json
  #         └── lib
  #             ├── flows
  #             │   └── flow1.flon
  #             └── taskers
  #                 └── .gitkeep

  describe '#variables' do

    it 'loads variables' do

      n = @loader.variables('net')

      expect(n['car']).to eq('fiat')

      ne = @loader.variables('net.example')

      expect(ne['car']).to eq('alfa romeo')
      expect(ne['flower']).to eq('rose')

      oe = @loader.variables('org.example')

      expect(oe['car']).to eq(nil)
      expect(oe['flower']).to eq('lilly')

      nea = @loader.variables('net.example.alpha')

      expect(nea['car']).to eq('lancia')
      expect(nea['flower']).to eq('forget-me-not')
    end
  end
end

