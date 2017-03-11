
# services

* ganger - receives tasks from the scheduler and hands them to the right tasker
* hooker - sees any message passing and may alter them, mostly triggers
* loader - used by other services to load start variables, taskers, libraries, definitions
* logger
* storage - the service between flor and Sequel
* [spooler](spooler.md) - watches a "spool" dir for incoming flor messages (launch requests, answers from taskers, ...)

* the scheduler
* the executors

* the taskers

