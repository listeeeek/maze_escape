
# About

Simple terminal maze escape game.

# Installation

Clone.

`zig build`

`cd zig-out/bin`

Start with:
```
./maze_escape -h
```

# Stage description

1st line → stage name

2nd+ lines → maze

## Characters

P → player 

E → exit

S → starting point

X → wall

space → non-bloking way

## Example

```
Small One - Warmup
XXXXXXXXXX
XXXXXXE XX
XXX   X XX
X   X X XX
X XXX X XX
XSX     XX
XXXXXXXXXX
```


# TODO

+ ascii maze (done)
+ custom stages via command args (next)
+ keys / doors
+ teleports
+ generate levels
+ run out of food?
+ monsters?
+ chests / items?
