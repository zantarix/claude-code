# Implementation plans

* The final step of an implementation plan should be verification of the changes using the `/verify-code` skill.
* After verification, a plan should explicitly specify to use the `/review` skill in order to do a self-review before returning control to the user.
* When executing an implementation plan, you should never automatically commit the results unless the user explicitly asks for it, for instance in a multi-phase implementation plan.
