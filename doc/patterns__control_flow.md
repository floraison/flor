
# patterns__control_flow.md

## introduction

This document describe Flor implementation for each of the [Control-Flow Patterns](http://www.workflowpatterns.com/patterns/control/) presented by the [Workflow Patterns](http://www.workflowpatterns.com/) website which catalog a comprehensive list of those workflow building blocks. Each implementation are provided with a link to the original pattern explanation and flash animation.

This is a self-evaluation. For an authoritative source, see the [workflow patterns website](http://www.workflowpatterns.com/) and its [mailing list](http://groups.google.com/group/workflow-patterns).

## index

### Basic Control Flow Patterns
* [Sequence](#bcf-sequence)
* [Parallel Split](#bcf-parallel-split)
* [Synchronization](#bcf-synchronization)
* [Exclusive Choice](#bcf-exclusive-choice)
* simple merge

### Advanced Branching and Synchronization Patterns
* multi choice
* structured synchronizing merge
* multi merge
* structured discriminator
* Structural Patterns
* arbitrary cycles
* implicit termination

### Multiple Instance Patterns
* multiple instances without synchronization
* multiple instances with a priori design time knowledge
* multiple instances with a priori run time knowledge
* multiple instances without a priori run time knowledge

### State-based Patterns
* deferred choice
* interleaved parallel routing
* [Milestone](#sb-milestone)

### Cancellation Patterns
* cancel task
* cancel case

### New Control Flow Patterns
(coming soon)

<!-- --------------------------------------------------------------------- -->
## Basic Control Flow Patterns

### Sequence
<a id="bcf-sequence" />Chaining activities in sequence.

Use the [sequence](procedures/sequence.md) or [cursor](procedures/cursor.md).

```
sequence
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp1.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp1_animation.php) | [top](#top)

### Parallel Split
<a id="bcf-parallel-split" />The [concurrence](procedures/concurrence.md) is the main tool for the parallel split.

```
concurrence
  #
  # alpha and bravo will be tasked concurrently
  #
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp2.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp2_animation.php) | [top](#top)

### Synchronization
<a id="bcf-synchronization" />The [concurrence](procedures/concurrence.md) by waiting (by default) for all its children to reply is usual flor synchronization tool.

```
sequence
  task 'alpha'
  concurrence
    task 'bravo'
    task 'charly'
    #
    # task 'delta' will be reached once 'bravo' and 'charly' have replied
    #
  task 'delta'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp3.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp3_animation.php) | [top](#top)

### Exclusive Choice
<a id="bcf-exclusive-choice" />The simplest flor procedure to use to support this pattern is [if](procedures/if.md)

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp4.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp4_animation.php) | [top](#top)

<!-- --------------------------------------------------------------------- -->
## Advanced Branching and Synchronization Patterns

<!-- --------------------------------------------------------------------- -->
## Multiple Instance Patterns

<!-- --------------------------------------------------------------------- -->
## State-based Patterns

### Milestone
A task is only enabled when in a specific state (typically a parallel branch).

Flor's workflow definition might be paraphrased as: "E is tasked only if the execution has the tag 'bravo'":
```
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
## New Control Flow Patterns

