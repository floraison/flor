
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

In the quickstart, the flor instance is pointed at by a constant `FLOR` (like a project using [Sequel](https://sequel.jeremyevans.net) tends to point to its (usually) single database via the constant `DB`).

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
* [domain:](#domain) - indicates which domain the execution will belong to
* [payload:](#payload--fields) - the initial payload
* [timeout:](#timeouts) - if a `wait:` is set, how long should it be waited for?
* [on_timeout:](#on_timeout) - in case of `timeout:`, what should happen when it triggers?
* [vars:](#vars) - the initial variable hash to use in the execution
* [wait:](#wait) - wait for certain events before allowing the `#launch` method to return

## domain:

A string like `"org.example.accounting"` indicating which domain / subdomain the execution about to be launched should be belong to.

The domain choice has an impact how what taskers / subflows / variables / hooks the execution interacts with. See [domains.md](domains.md) for more information.

Defaults to `""`.

## payload: / fields:

The initial payload / fields for the execution. Default to `{}`. Must be set to a Ruby hash that is JSON serializable. Symbol keys are OK, Ruby's JSON library turns them to string keys anyway.

Do not attempt to pass ActiveRecord model instances or things like that here, the JSON dumper would choke. Pass ids and let taskers fetch the data as they see fit.

## timeout:
## on_timeout:
## vars:

The initial variables for the execution.

Follow the same "must be JSON serializable" command as given above for the initial payload / fields.

There is another way to set initial variables for an execution. That's via domain variables. See [domains.md](domains.md) for more information.

## wait:

## other wait techniques

## launching manually

