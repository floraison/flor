
#
# specifying flor
#
# Sat Jun 18 16:43:30 JST 2016
#

require 'spec_helper'


describe Flor::Loader do

  before :each do

    unit = OpenStruct.new(conf: { 'lod_path' => '_spec/unit/loader/' })
      # force a specific file hieararchy root on the loader via 'lod_path'

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
  # │   │   │   └── flow0.flor
  # │   │   └── org.example
  # │   │       └── flow0.flor
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
  #     │       │   └── flow1.flor
  #     │       └── taskers
  #     │           └── bob
  #     │               └── dot.json
  #     └── org.example
  #         ├── etc
  #         │   └── variables
  #         │       └── dot.json
  #         └── lib
  #             ├── flows
  #             │   └── flow1.flor
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

  describe '#library' do

    it 'loads a lib' do

      pa, fn = @loader.library('net.example', 'flow1')

      expect(
        pa
      ).to eq(
        '_spec/unit/loader/usr/net.example/lib/flows/flow1.flo'
      )

      expect(
        fn.strip
      ).to eq(%{
        task 'alice'
      }.strip)

      pa, fn = @loader.library('org.example.flow1')

      expect(
        fn.strip
      ).to eq(%{
        task 'oskar'
      }.strip)
    end
  end

  describe '#tasker' do

    it 'loads a tasker configuration' do

      t = @loader.tasker('', 'alice')

      expect(t['description']).to eq('basic alice')
      expect(t.keys).to eq(%w[ description a _path ])

      t = @loader.tasker('net.example', 'alice')

      expect(t['description']).to eq('basic alice')
      expect(t.keys).to eq(%w[ description a _path ])

      t = @loader.tasker('org.example', 'alice')

      expect(t['description']).to eq('org.example alice')
      expect(t.keys).to eq(%w[ description ao _path ])

      t = @loader.tasker('', 'bob')

      expect(t).to eq(nil)

      t = @loader.tasker('net.example', 'bob')

      expect(t['description']).to eq('usr net.example bob')
      expect(t.keys).to eq(%w[ description ubn _path ])

      t = @loader.tasker('org.example', 'bob')

      expect(t['description']).to eq('org.example bob')
      expect(t.keys).to eq(%w[ description bo _path ])

      t = @loader.tasker('org.example.bob')

      expect(t['description']).to eq('org.example bob')
      expect(t.keys).to eq(%w[ description bo _path ])
    end
  end
end

