
# services

* the scheduler - contains and coordinates all the services that make up a flor "unit"

## core services

* [ganger](ganger.md) - receives tasks from the scheduler and hands them to the right tasker
* [hooker](hooker.md) - sees any message passing and may alter them, mostly triggers
* [loader](loader.md) - used by other services to load start variables, taskers, libraries, definitions
* runner - used by hooker and ganger to run/invoke taskers and hooks
* storage - the service between flor and Sequel
* [spooler](spooler.md) - watches a "spool" dir for incoming flor messages (launch requests, answers from taskers, ...)

## services subordinated to the hooker

* logger - currently bicephalous, the hooker hands it all messages for logging (will do nothing unless in debug mode) and receives log/info/warn/error calls and logs them

(I should probably split this logger in two)

* wait list - a small service only relevant in spec/tests, lets Ruby code wait until an message is seen in flor

## not really services

* executors
* taskers

