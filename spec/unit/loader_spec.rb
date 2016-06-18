
#
# specifying flor
#
# Sat Jun 18 16:43:30 JST 2016
#

require 'spec_helper'


describe Flor::Loader do

  describe '#load' do

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

    it 'loads'
  end
end

