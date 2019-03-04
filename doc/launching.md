
# launching

This piece of documentation looks at how flor execution are launched from Ruby code.

One can launch a flor execution from any SQL-able language by placing a well-formed `flor_messages` row within the database used by flor. See [below](#launching-manually).

Here is an example of execution "launching" taken from the [quickstart](../quickstart):
```ruby
msg =
  FLOR.launch(
    %q{
      concurrence     #
        alice _       # the "workflow definition",
        bob _         # the 'program' that flor interprets
    },
    domain: 'org.example',
    wait: true)
```

In the quickstart, the flor instance is pointed at by a constant `FLOR` (like a project using [Sequel](https://sequel.jeremyevans.net) tends to point to its (usually) single database via the constant `DB`.

Here is another example of execution launching:
```ruby
data = { client: {} }
data[:client][:nick] = 'Taiwan Plastic'
# ...

msg =
  FLOR.launch(
    'iwm.asia.pfs.aws.onboarding',
    vars: { launcher: user.id },
    payload: data,
    wait: 'task; task', # wait until flow reaches first human task
    timeout: 14,
    on_timeout: 'shutup')
exid = msg['exid']
```
It sets initial variables, an non-empty initial payload and it's told to wait before returning until the execution has seen 2 "task" messages. This wait will timeout silently (shutup) after 14 seconds.

This launch happens in a layer of code just behind a controller. Hence the wait, it's supposed to block the `#launch` call until a workitem appears in the launchcher's group inbox.

The `#launch` options are:
* [domain:](#domain:) xxx
* [payload:](#payload--fields:) xxx
* [timeout:](#timeouts:) xxx
* [on_timeout:](#on_timeout:) xxx
* [vars:](#vars:) xxx
* [wait:](#wait:) xxx

## domain:
## payload: / fields:
## timeout:
## on_timeout:
## vars:
## wait:

## other wait techniques

## launching manually

