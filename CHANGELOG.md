
# CHANGELOG.md


## flor 1.0.2  not yet released


## flor 1.0.1  released 2020-11-23

* Accept sto_uri strings pointing to constant like 'DB'


## flor 1.0.0  released 2020-11-22

* Lots of incremental improvements


## flor 0.18.0  released 2019-05-05

* Refine BasicTasker#reply (more arg patterns)
* Fix "signal" vs exid: and payload:
* Make payload optional when cancelling
* Unlock `signal exid: other_execution_id "xxx"`
* Allow for `trap 'signal0' payload: { a: 'A' }`
* Allow for "on" in blocking mode (no block given)
* Turn "sequence" single string att results to tags
* gh-26, refine cancel / on_cancel and payload return
* Allow for custom :schema_info migration table
* Introduce a dedicated #refresh for all flor models
* Let scheduler sleep only 0.001s if @idle_count less than 1
* Implement Scheduler #dump and #load
* Default target #cancel and #kill to node '0'
* Expose taskname to tasker on detasking (@Subtletree)
* Refine BasicTasker#reply (more arg patterns)
* Allow for `trap 'signal0' payload: { a: 'A' }`
* Allow for "on" in blocking mode (no block given)
* Unlock `signal exid: other_execution_id "xxx"`
* Make payload optional when cancelling (default to payload as it was
  upon reaching the cancelled node)


## flor 0.17.0  released 2019-04-08

- Switch to 0.17.x


## flor 0.16.2  released 2019-04-08

- Many improvements
- Allow for `[ 'he' 'll' 'o' ] | + join: '.'` (yields "he.ll.o")
- Allow for `[ 1 2 3 ] | + _` (yields `6`)
- Make "child_on_error:"/"children_on_error:" a common attribute
- Ensure "on_cancel" sets only one handler


## flor 0.16.1  released 2019-02-05

- Depend on Sequel 5 (Sequel 4 and 5 seem OK)


## flor 0.16.0  released 2019-02-04

- Many many improvements
- Include "undense" work ("_ref" and friends)
- Include "undense" work (killing the dollar subsystem)
- Fix dereserving delayed messages
- allow for cancel behaviour when "cursor", "sequence", and "until"
  node_status flavour is "on-error"


## flor 0.15.0  released 2018-06-15

- Many many improvements
- Implement "cron" (macro for "schedule cron:")
- Introduce Flor.point?(s)
- Archive terminated, failed and ceased messages (Tsunehisa Doi)
- Let "case" match regular expressions


## flor 0.14.0  released 2017-06-13

- Implement "match"
- Implement "range"
- Implement "for-each"
- Merge enhancements by @jfrioux


## flor 0.13.0  released 2017-04-24

- Simplify "trace" implementation
- Simplify "task" implementation


## flor 0.12.0  released 2017-04-14

- Implementation of 'flank' and application to "trap" and "schedule"
- Introduce `{ a : 0 } quote: 'keys'`
- Introduce `vars: copy` or `vars: '*'`


## flor 0.11.0  released 2017-03-17

- Simplification of the tasker configuration files
  (alignment on hooks configuration files)
- Introduction of lib/hooks/
- go for ; and | (same level) and \ (child level)
- Implement "twig"
- Implement basic spooler (var/spool/)
- Introduce runner service
- Fix Storage#any_message (misuse of Sequel Dataset#count)


## flor 0.10.0  released 2017-03-03

- Enhance shell, bring in bin/flosh (though not in gem)
- Rework "deep" tools (accept square bracket indexes)
- Implement vanilla "case"
- Implement "graft"
- Link unit name and unit identifier
- Scheduler rework, emphasis on optimistic locking for messages and timers


## flor 0.9.5  released 2017-02-10

- Don't load exids for which there are "loaded" messages
- Use Flor.tstamp for flor_messages :mtime


## flor 0.9.4  released 2017-02-09

- Allow setting of flor_debug in ENV (FLOR_DEBUG) and in conf
- Revise Storage#load_exids (distinct/order by problem on MS-SQL)


## flor 0.9.3  released 2017-02-07

- Rename the head 'tasker' as 'ganger'
- Allow for (tasker, conf, message) ruby taskers


## flor 0.9.2  released 2017-02-03

- Allow for domain taskers (retasking)
- Pass flow path (if any) in launch message


## flor 0.9.1.1  released 2017-01-31

- Fix Gemfile.lock not updated...


## flor 0.9.1  released 2017-01-31

- Fix dropped exids problem


## flor 0.9.0  released 2017-01-30

- Initial release


## flor 0.0.1  released 2015-11-04

- Initial, empty, release (Juan's verandah)

