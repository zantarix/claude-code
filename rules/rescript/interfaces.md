# Interfaces

Interfaces (`.resi` files) define just the public interface of a module. This shouldn't include internal details like whether a function is externally defined or not, it should simply declare the type of the things which other modules can interact with.

For example, given the following `Timers.res`:

```rescript
type intervalId

@val external setInterval: (unit => unit, int) => intervalId = "setInterval"
@val external clearInterval: intervalId => unit = "clearInterval"
```

The appropriate `Timers.resi` would be:

```rescript
type intervalId

let setInterval: (unit => unit, int) => intervalId
let clearInterval: intervalId => unit
```
