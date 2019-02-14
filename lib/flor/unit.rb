
require 'sequel'
require 'sequel/extensions/migration'

require 'fugit'

require 'flor'
require 'flor/unit/hook'
require 'flor/unit/hooker'
require 'flor/unit/caller'
require 'flor/unit/wlist'
require 'flor/unit/logger'
require 'flor/unit/journal'
require 'flor/unit/storage'
require 'flor/unit/executor'
require 'flor/unit/waiter'
require 'flor/unit/scheduler'
require 'flor/unit/models'
require 'flor/unit/loader'
require 'flor/unit/hloader'
require 'flor/unit/ganger'
require 'flor/unit/spooler'
require 'flor/unit/taskers'

Flor.load_procedures('punit')

module Flor

  Unit = Scheduler
    # an alias
end

