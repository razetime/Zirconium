# Zirconium
[Zirconium](https://esolangs.org/wiki/Zirconium) is an two-dimensional esoteric programming language which functions akin to a space strategy game.

Zirconium does not fare very well for array languages due to its requirement for parsing ASCII graphs and
generally complicated special cases. However, it is still worth seeing how
expressive BQN can be under these constraints, since running the parsed program is very clean.

This interpreter takes some liberties with interpreting the spec, and hence you may find some results strange.
My main goal here is to make sure I can at the very least run the examples correctly. It may be more liberal than
expected, and useful errors will be sparse.

## Running
Cloning and installing [CBQN](https://github.com/dzaima/CBQN/) will let you run the current commit.

```
cbqn Zirconium.bqn file.zc [header.zch]
```

Heder functionality is coming soon.

## Ideas
It works on the basis of creating and manipulating stations to dispatch drones via tunnels during every tick of time, which corresponds to a move.

Some documentation is written in `Zirconium.bqn`, however a full specification can be seen on the esolangs wiki: https://esolangs.org/wiki/Zirconium
