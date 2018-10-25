
# patterns__control_flow.md

## introduction

This document describe Flor implementation for each of the [Control-Flow Patterns](http://www.workflowpatterns.com/patterns/control/) presented by the [Workflow Patterns](http://www.workflowpatterns.com/) website which catalog a comprehensive list of those workflow building blocks. Each implementation are provided with a link to the original pattern explanation and flash animation.

This is a self-evaluation. For an authoritative source, see the [workflow patterns website](http://www.workflowpatterns.com/) and its [mailing list](http://groups.google.com/group/workflow-patterns).

If you disagree with a solution proposed here, you are much welcome to [raise an issue](https://github.com/floraison/flor/issues) pointing at why the solution doesn't match and potentially include a better solution.


## index

### Basic Control Flow Patterns
* [Sequence](#bcf-sequence)
* [Parallel Split](#bcf-parallel-split)
* [Synchronization](#bcf-synchronization)
* [Exclusive Choice](#bcf-exclusive-choice)
* [Simple Merge](#bcf-simple-merge)

### Advanced Branching and Synchronization Patterns
* [Multi-Choice](#abs-multi-choice)
* [Structured Synchronizing Merge](#abs-structured-synchronizing-merge)
* Multi-Merge
* Structured Discriminator
* Blocking Discriminator
* Cancelling Discriminator
* Structured Partial Join
* Blocking Partial Join
* Cancelling Partial Join
* Generalised AND-Join
* Local Synchronizing Merge
* General Synchronizing Merge
* Thread Merge
* Thread Split

### Multiple Instance Patterns
* Multiple Instances without Synchronization
* Multiple Instances with a Priori Design-Time Knowledge
* Multiple Instances with a Priori Run-Time Knowledge
* Multiple Instances without a Priori Run-Time Knowledge
* Static Partial Join for Multiple Instances
* Cancelling Partial Join for Multiple Instances
* Dynamic Partial Join for Multiple Instances

### State-based Patterns
* Deferred Choice
* Interleaved Parallel Routing
* [Milestone](#sb-milestone)
* Critical Section
* Interleaved Routing

### Cancellation Patterns
* Cancel Task
* Cancel Case
* Cancel Region
* Cancel Multiple Instance Activity
* Complete Multiple Instance Activity

### Iteration Patterns
* Arbitrary Cycles
* Structured Loop
* Recursion

### Termination Patterns
* Implicit Termination
* Explicit Termination

### Trigger Patterns
* Transient Trigger
* Persistent Trigger

<!-- --------------------------------------------------------------------- -->
## Basic Control Flow Patterns

### Sequence
<a id="bcf-sequence" />Chaining activities in sequence.

Use the [sequence](procedures/sequence.md) or [cursor](procedures/cursor.md).

```python
sequence
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp1.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp1_animation.php) | [top](#top)

### Parallel Split
<a id="bcf-parallel-split" />The [concurrence](procedures/concurrence.md) is the main tool for the parallel split.

```python
concurrence
  #
  # alpha and bravo will be tasked concurrently
  #
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp2.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp2_animation.php) | [top](#top)

### Synchronization
<a id="bcf-synchronization" />The [concurrence](procedures/concurrence.md) by waiting (by default) for all its children to reply is the simplest flor synchronization tool.

```python
sequence
  task 'alpha'
  concurrence
    task 'bravo'
    task 'charly'
  task 'delta' # task 'delta' will be reached once 'bravo' and 'charly' both have replied
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp3.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp3_animation.php) | [top](#top)

### Exclusive Choice
<a id="bcf-exclusive-choice" />The simplest flor procedure to use to support this pattern is [if](procedures/if.md).

```python
  sequence

    # ...

    if
      f.customer.age > 21 # condition
      sequence # then
        set f.customer.type 'adult'
        order_kit _
      sequence # else
        set f.customer.type 'non-adult'
        order_teenager_kit _

    # ...
```

The [case](procedures/case.md) and [match](procedures/match.md) are the other two contenders for exclusive choice.

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp4.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp4_animation.php) | [top](#top)

### Simple Merge
<a id="bcf-simple-merge" />A simple merge occur when two (or more) exclusive branch converge. As seen in exclusive choice this pattern is implicitely supported. It simply occurs when the ‘then’ or the ‘else’ clause of an [if](procedures/if.md) terminates and the flow resumes.

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp5.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp5_animation.php) | [top](#top)

<!-- --------------------------------------------------------------------- -->
## Advanced Branching and Synchronization Patterns

### Multi-Choice
<a id="abs-multi-choice" />[concurrence](procedures/concurrence.md) and [if](procedures/if.md) can be combined to support this workflow control pattern.

```python
sequence
  # ...
  concurrence
    if f.traffic or f.crime
      task "despatch police"
    if f.fire
      task "despatch fire engine and ambulance"
    if f.wounded
      task "despatch ambulance"
  # ...
```

The concurrence may result in 0 to 3 tasks being "emitted", in case of 0, the flow will immediately resume after the concurrence. Else, the flow will wait until the 1 to 3 tasks have completed.

[wp/explanation](http://www.workflowpatterns.com/patterns/control/advanced_branching/wcp6.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/advanced_branching/wcp6_animation.php) | [top](#top)

### Structured Synchronizing Merge
<a id="abs-structured-synchronizing-merge" />The [explanation](http://www.workflowpatterns.com/patterns/control/advanced_branching/wcp7.php) for this pattern sports an example stating:

> Depending on the type of emergency, either or both of the despatch-police and despatch-ambulance tasks are initiated simultaneously. When all emergency vehicles arrive at the accident, the transfer-patient task commences.

Here is a naive flor translation (see previous pattern for its origin):
```python
sequence
  # ...
  concurrence
    task "despatch police" if f.traffic or f.crime
    task "despatch ambulance" if f.wounded
  task "transfer-patient"
  # ...
```
The [concurrence](procedures/concurrence.md) procedure, by default, waits for all its children to respond before ending and replying to its parent procedure (here a [sequence](procecures/sequence.md). The sequence then hands the flow to the `task "transfer-patient"` followup.

[wp/explanation](http://www.workflowpatterns.com/patterns/control/advanced_branching/wcp7.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/advanced_branching/wcp7_animation.php) | [top](#top)

<!-- --------------------------------------------------------------------- -->
## Multiple Instance Patterns

<!-- --------------------------------------------------------------------- -->
## State-based Patterns

### Milestone
<a id="sb-milestone" />A task is only enabled when in a specific state (typically a parallel branch).

Flor's workflow definition might be paraphrased as: "E is tasked only if the execution has the tag 'bravo'":
```python
concurrence
  sequence
    task 'A'
    task 'B' tag: 'bravo'
    task 'C'
  sequence
    task 'D'
    task 'E' if tag.bravo
    task 'F'
```

The predecessor to Flor (Ruote) was proposing a syntax a bit more [convoluted](http://ruote.io/patterns.html#sa_milestone).

[wp/explanation](http://www.workflowpatterns.com/patterns/control/state/wcp18.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/state/wcp18_animation.php) | [top](#top)

<!-- --------------------------------------------------------------------- -->
## Cancellation Patterns

<!-- --------------------------------------------------------------------- -->
## Iteration Patterns

<!-- --------------------------------------------------------------------- -->
## Termination Patterns

<!-- --------------------------------------------------------------------- -->
## Trigger Patterns

