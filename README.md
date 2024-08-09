# kanren

An implemenation of minikanren plus some arithmetic-related kanren stuff. Very much inspired by [this js implementatio](https://github.com/shd101wyy/logic.js). This lib relies on my [dynamic_value lib](https://github.com/theSherwood/dynamic_value) for the dynamic value that the various kanren operators operate on. If any kanren fans read this code, I apologize for getting some of the naming conventions wrong.

**Disclaimer**: This was written using the Nimskull compiler, which has not reached a stable version and, as of the time of this writing, continues to see rapid changes. There are already several differences between the Nimskull and Nim compilers. As such, if you wish to use any of this code... good luck!

**Disclaimer 2** As of the time of this writing, Nimskull did not have a package manager. So dependencies are handled through git submodules, which are a bit annoying to use.

## Usage

Some core operators in action.

```nim
doAssert run(10, [x, y], conde(
  @[eqo(x, y), eqo(x, 1)],
  @[eqo(x, y), eqo(x, 2)],
  @[eqo(x, y), eqo(x, 1), eqo(y, 2)],
)) == @[V {x: 1, y: 1}, V {x: 2, y: 2}]
```

An array operator.

```nim
doAssert run(10, [x, y], appendo(x, y, [1, 2, 3])) == @[
  V {x: [],        y: [1, 2, 3]},
  V {x: [1],       y: [2, 3]   },
  V {x: [1, 2],    y: [3]      },
  V {x: [1, 2, 3], y: []       },
]
```

Some core operators, array operators, negation operators, the `fresh` operator for introducing variables, and a predicate operator that can be used as a flexible fallback if no built-in operator does the job. Be aware that `predo` does not support any bidirectional logic.

```nim
##
##    EF
## +  FD
## -----
##   FDF
## 
let
  D = Var D
  E = Var E
  F = Var F
var res = run(10, [D, E, F], fresh([digits],
  ando(
    eqo(digits, V [0,1,2,3,4,5,6,7,8,9]),
    membero(F, digits),
    neqo(F, 0),
    membero(D, digits),
    predo(proc(smap: Val, walk: proc(key, smap: Val): Val): bool =
      let f = walk(F, smap)
      if ((walk(D, smap) + f) mod 10) == f: return true 
    ),
    membero(E, digits),
    predo(proc(smap: Val, walk: proc(key, smap: Val): Val): bool =
      let e = walk(E, smap)
      if e == 0: return false
      let d = walk(D, smap)
      let f = walk(F, smap)
      let lhs = (e * 10) + f + (f * 10) + d
      let rhs = (f * 100) + (d * 10) + f
      if lhs == rhs: return true
    )
  )
))
doAssert res == @[V {D: 0, E: 9, F: 1}]
```

Some rule-based logic with `facts`.

```nim
let parent = facts(@[
  V ["Steve", "Bob"],
  V ["Steve", "Henry"],
  V ["Henry", "Alice"],
])

let x = Var x
var res = run(10, [x], parent(@[x, V "Alice"]))
doAssert res == @[V {x: "Henry"}]
res = run(10, [x], parent(@[V "Steve", x]))
doAssert res == @[V {x: "Bob"}, V {x: "Henry"}]

proc grandparent(x, y: Val): GenStream =
  result = fresh([z], ando(parent(@[x, z]), parent(@[z, y])))

res = run(10, [x], grandparent(x, V "Alice"))
doAssert res == @[V {x: "Steve"}]
```

Refer to the test code for examples of several more operators.

## Scripts and commands

### Build Native

```sh
./run.sh -tu native
```

### Test Native

```sh
./run.sh -tur native
```

### Test Wasm in Node

```sh
./run.sh -tur node32
```

### Test Wasm in Browser

Compile wasm:

```sh
./run.sh -tur browser32
```

Start the server:

```sh
dev start
```

Go to http://localhost:3000/

## State

In addition to the core logic of minikanren, this implementation supports some arithmetic operators, some comparison operators, some array operators, some negation operators, and a bit of support for basic rule programming. The implementation pulls from lazy streams in a cycle to avoid getting stuck on a stream that cannot make progress.

Supported operators:

- core
  - `fresh`
    - introduces more variables
  - `ando`
  - `oro`
  - `eqo`
  - `conde`
- negation (negation-as-failure)
  - `noto`
    - basic `not`
  - `nando`
    - negate `ando`
  - `noro`
    - negate `oro`
  - `neqo`
    - negate `eqo`
- array
  - `conso`
  - `firsto`
  - `resto`
  - `emptyo`
  - `membero`
  - `appendo`
- type assertions
  - `stringo`
  - `numbero`
  - `arrayo`
- arithmetic
  - `add`
  - `sub`
  - `mul`
  - `dis`
    - division operator (`div` is a Nimskull keyword)
- comparison
  - `lt`
  - `gt`
  - `le`
  - `ge`
- misc
  - `predo`
    - arbitrary predicate
  - `succeedo`
    - always succeed
  - `failo`
    - always fail
  - `anyo`
    - repeat infinitely
  - `facts`
    - for an array of rules
