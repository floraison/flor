
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
  # │       └── dot.json
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

  describe '#variables' do

    it 'loads variables' do

      vs = @loader.variables('net.example')

      expect(vs['flower']).to eq('rose')

      vs = @loader.variables('org.example')

      expect(vs['flower']).to eq('lilly')
    end
  end

  describe '#split' do

    it 'splits domains' do

      expect(
        @loader.send(:split, 'org.example.x.y.z')
      ).to eq(%w[
        org org.example org.example.x org.example.x.y org.example.x.y.z
      ])
    end
  end
end

