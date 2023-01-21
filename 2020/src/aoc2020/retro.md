# Advent of code 2020
## Intro
This year I took a different path than the last edition.
Instead of being ultra-competitive and hacking through crappy python code at 6am in the bed, I took the opportunity to relax a little bit and learn something new.

For quite some years the Clojure language has picked my interest and I have never stopped to learn past the tutorial/hello-word examples. This was the perfect ~~excuse~~ opportunity to justify why I wouldn't make it to the top of our private leaderboard.

I also promised to do a post mortem of the language. My disclaimer is that I have barely scratched the surface and have only used it to solve advent of code, no real-life comparable usage yet. Though I got a general feeling which I'll try to express here.

## Programming
I had some experience with the functional mindset of having data and applying transformations to it from Haskell, so it was not a first bloody battle. It did become challenging in some problems where my experience in Python/C++ solving similar puzzles would quickly give me a procedural/mutable idea that, even though possible to write in Clojure, would defeat my goal of learning the idiomatic way.

Once you master the `for` and `loop` form, you are pretty much good and they don't look that different. Plus they are very rich in functionality, `for` is close to python list comprehension and `loop` is recursion on steroids.

```Clojure
(for [x [0 1 2 3 4 5]
      :let [y (* x 3)]
      :when (even? y)]
  y)
;;=> (0 6 12)

(loop [n 5, acc 1]
  (if (zero? n)
    acc
    (recur (dec n) (* acc n))))
;;=> 120
```

### Speed
Clojure is not fast and runs in the JVM. I did not need to compile my code and generate production binaries with the REPL. Surely faster than Python (unless it's just C wrapped, looking at you Pypy). Impossible to beat C/C++/Rust and alike there, but I read multi-threading is much easier. There is a JS implementation (ClojureScript), and a Go runtime but I don't know of their relative performance.

### Dev env
The first thing that I noticed was how different the development experience was from my usual Java.
All the Clojure IDE integration I know integrate some kind of REPL that allows you to run any block of code and get the result. This allowed for smaller (quicker) iterations of write & check, that feels similar to what iPython offers.
On the same line I particularly enjoyed structure editting of code (I used https://calva.io/paredit/ with VScode) that basically let's you manipulate the code tree and avoid having to deal manually with parenthesis.

A common complaint/joke I hear about Lisps is the abundance of parenthesis. You might know the argument that you are just moving the first parenthesis before the function name. I guess more parenthesis comes from calling more functions.
I did have some moments where I felt I couldn't parse the nesting of things in my head; I first thanked the distinct coloring of the editor and then relied more on paredit to handle refactoring. At the end indentation and the shared style of things solves my issues.

## Language
And I really mean the "shared style", because all function calls are the same `(f arg1 arg2 ... argN)`. There is very little syntax in Clojure, almost just data literals and function calls, which creates a nice uniformity.

Taking about data literals, there are (my classification):
- numbers (multiple kinds) `42`, `-9`, `1.5e10`, `0x7F`, `2r01101`, `3.14`, `5/2`
- symbols `x`
- keywords `:something`
- strings `"hello world"`
- characters `\x`

And the general collections:
- lists `(1 2 3)`
- vectors `[1 2 3]`
- maps `{1 "one", 2 "two", 3 "three"}`
- sets `#{1 2 3}`

Other nice things:
- regex `#"[a-z]"`
- anonymous functions `#(+ 4 %)`

That's all I used and I don't think there is much more, I did not create any "class" or "type" during AoC, though I know `records` and others exist. I was please to discover commas (`,`) are whitespace which let's you put them when readibility demands. Collections can have multiple types of things in it, no "type" restrictions in the basic ones.

### Immutability
By default, everything is immutable. You change things by creating new ones and the persistent data structures make that efficient by sharing some internals (they basically are shallow trees)

### Lazyness
Lazyness is amazing, Clojure is different than Haskell as evaluation is not lazy but sequences can be. I would compare it to python generators or java streams, but implicit.

### Style
Clojure is just consistent. Data structures don't have methods, but functions take multiple data structure and do the similar operation. Destructuring a DS has the same syntax as creating it. Sequence mapping (map) and sequence side effect (foreach) have the same syntax:

```Clojure
(for [x [1 2 3] :when (odd? x)]
  x)
;;=> (1 3)
(doseq [x [1 2 3] :when (odd? x)]
  (prn x))
; 1
; 3
;;=> nil
```
And things oriented for side effect are prefixed with `do` and always return `nil`.

Falsity is very simple, everything is `true` but `false` and `nil`; empty collections, `0`, `""` all evaluate as `true` in conditions.

#### Pipelines
A thing I particularly dislike in Java is the need to convert to streams to be functional with collections

```Java
List<Integer> a;
List<Integer> b = a.stream()
  .map(x -> x+1)
  .filter(x -> x > 2)
  .collect(Collectors.toList())

// I would like
b = a.map(+ 1).filter(> 2)
```
Python does not have this issue but has the grow-to-the-left problem which makes you write in the opposite direction and makes reading harder.

```Python
a = []
b = filter(lambda x: x > 2, map(lambda x: x+1, a))
```

You can say Clojure is the same
```Clojure
(filter #(< 2 %) (map #(+ 1 %) a))
```
But that is where macros come from. Macros are basically Clojure code that gets executed at compile time and manipulates code. You can create your owns, but there are a few useful ones. The macro to handle the "pipeline" style are called threading macros

```Clojure
(->> a
  (map #(+ 1 %))
  (filter #(< 2 %)))
```
And this is very simple to understand, it will pass the result of the previous arg at the last position of the next form. There are variants to pass as first arg `->` or somewhere you mark `as->`. This works will any code, no need to fulfill some contract of any kind. Also this is not syntax.

Not everything is pretty though, I got confused a few times looking for the right way to combine `map` and `apply` to do what I wanted. You get used to the magic and expect all functions to work with 0 argument and when it doesn't...

#### Function calls
As I said earlier all functions calls are `(f arg1 arg2 ... argN)`. I like it a lot. If you compare with Java where you sometimes have to deal with a mix of static methods, instance methods, property access and fluent style:

```Java
var map = GridMap.make(5, 5).addRandom(e1).closed().create();
var pos = Algorithms.search(map, e1);
map.getAt(pos.get(0)).value + 1
```
IMO this gets messy easily, add the types, remove some intermediary variables and put longer names...

A similar thing in Clojure using `let` and destructuring might be:
```Clojure
(let [map (gridmap [5 5] :add-random e1 :closed true)
      [p & _] (algo/search map e1)]
  (inc (:value (get map p)))
```
Take into consideration the experience you have with each style before judging.

## TLDR
I like Clojure. I could get along without googling every 5min after 2-3 problems. Don't buy it looking for speed. Language is beautiful and fun, feels like Haskell mixed with Python. Functional style takes some time to get into and can slow you down compared to what you already know 
and master.

REPL and structural editing is AMAZING. I think a Lisp can give me the flexibility and expresiveness I sometimes lack in Java while keeping the line count low.

I will learn more about it (already half-way through a book). I want to try the concurrency model and make a project comparable to my day-to-day for a fair comparison. I would probably not use it again in AoC as the problems are too short/simple to make me learn more of the language now and I'll be faster in Python.

Would recommend to anyone looking for something new, clean and high-level.

