# Generator

The following is a proposal for a new command generator:

```plain
What type of command is this?
normal: process arguments, execute something
echo-*: transform input (args/stdin) into modified output
setup-util-*: cross-platform installer for a package or application

What to name the command?
What to name the transformation?
echo-

---

Should it transform arguments? [Y/n]
Should it transform stdin? [Y/n]
Should it distinguish between arguments and stdin? [y/N]
Should it do something custom upon finishing? [Y/n]

---

Does the utility have a CLI? If so, what is its name?

Does the utility have an Application? If so, what is its name?

Does the utility have a user friendly name? If so, what is it?
$app, or $cli

Which ecosystems does $name have a package on?

For each ecosystem:
What name does $name for its $ecosystem package?

Asked as soon as we have a CLI or App or Name:
What to name the utility installer?
setup-util-$cli

---

Asked as soon as we have a command name (as we want to make sure we aren't overwriting something already)
Where should the command go?
user/commands
user/commands.local
core

Will it need to process custom arguments/flags? [Y is command, N if echo or utility]

What are the names of boolean flags (if any) that it accept? Separate by space or comma.

What are the names of string flags (if any) that it will accept? Separate by space or comma.

Will it accept arguments that aren't flags?

---

Describe what the command should do briefly:


If command:
What is an example invocation?
$cli $flags -- $args
What would be its example stdout result output?
...

If echo:
What is an example input?
hello world
What is an example output?
HELLO WORLD

Use AI to generate the help text.
```

Currently in progress at `commands.beta/dorothy-new`
