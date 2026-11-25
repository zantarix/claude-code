---
paths:
  - "**/*.res"
  - "**/*.resi"
---

# Interfaces

An interface (`.resi` file) defines only the public interface of a module. It must not include internal details, such as whether a function is defined externally. It declares only the type of each item that other modules can use.

For example, take this `Timers.res`:

```rescript
type intervalId

@val external setInterval: (unit => unit, int) => intervalId = "setInterval"
@val external clearInterval: intervalId => unit = "clearInterval"
```

The appropriate `Timers.resi` is:

```rescript
type intervalId

let setInterval: (unit => unit, int) => intervalId
let clearInterval: intervalId => unit
```
