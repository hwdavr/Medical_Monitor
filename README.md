# Medical Monitor


## Compilation Issues
Thhere is a dependency library "Charts" is used. It may have some compilation issue.
The version used is 3.1.0, and you should set the swift compiler above than 4.0.

There may be some other compilation issues, 
>Cannot use instance member 'bounds' within property initializer; property initializers run before 'self' is available

According the suggestion, add 'self.' before the variable, if there is '_' before the variable and not working, try to remove the underscore.


