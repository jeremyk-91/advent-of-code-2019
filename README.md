# advent-of-code-2019
I'm working on the [Advent of Code](https://adventofcode.com/) problems for 2019 in this repository.
The goal is to solve as many of the problems as possible, if not all of them, using Haskell. I first learned about it during
my degree at Imperial College, but haven't used it much since besides occasionally doing the
[January tests](http://wp.doc.ic.ac.uk/ajf/haskell-tests/) for fun. Nonetheless, I thoroughly enjoyed learning about Haskell
and working with it - I'm not sure how much can be attributed to the, in my opinion, excellent Tony Field.

I'm most familiar with Java (with C++ a distant second and probably Python third), so working with Haskell can be quite
frustrating in that I'm taking a long time for something I could conceivably implement in under 5 minutes.

I'll write up some of the thinking behind my solutions, as well as what I thought part 2 was going to be when I looked at the
part 1 spec for some of the problems.

## Day 1
Time taken: 25 minutes | Time I'd expect in Java: 3 minutes

Not much to say here, just a question of following the instructions. I think a good chunk of time here was just trying to
remember how to do IO. Part 2 had a fun solution of generating a lazily-evaluated infinite list of weight computations,
and then [applying takeWhile and sum](https://github.com/jeremyk-91/advent-of-code-2019/blob/master/1/problem-1.hs#L14) on it.

## Day 2
Time taken: 30 minutes | Time I'd expect in Java: 10 minutes

We had a number of questions on custom interpreters back in uni. I used to find the syntactic sugar of having types
pointless, though I guess some experience in industry has made me value it more. Again, this felt like just a task of
following instructions. Some of the dereferencing code like `intCode!!(intCode!!(pointer + 1))` seemed horrible.

## Day 3
Time taken: 45 minutes | Time I'd expect in Java: 10 minutes

I went for the obvious solution of enumerating all points along the wires, taking the intersection of these points, and then
mapping Manhattan distance onto that. The first complexity issue popped out here: `List.intersect` is, of course, O(N^2) and
the wires covered around 10^5 points. I simply did a sort-and-merge based algorithm for an O(N log N) solution, which was
good enough; of course I would have just gone with `HashMap` and Immutables in Java to knock this out in linear time.

The real Part 2 was pretty easy, though it made me realise how much I missed things like `Maps.transformValues()` or
`foo.stream().map(function1).sorted(Comparator.comparingLong(longExtractor))`. In the end I decided to look at Haskell's
map library rather than messing around with sorted lists of key-value pairs.

### Jeremy's part 2 idea

> In part 1, the length of each segment of wire was bounded by 2<sup>10</sup>, and the length of each wire was bounded by
  2<sup>18</sup>. What happens if we changed these limits to 2<sup>63</sup> and 2<sup>63</sup> respectively? The number
  of components of each wire is bounded by 2<sup>10</sup>, still.

> Bonus: The number of components of each wire is bounded by 2<sup>20</sup>, not 2<sup>10</sup>: your algorithm
  cannot be quadratic in this.

I originally thought Part 2 would have forced you to do a more elegant geometry-based attack on this problem. Instead of
generating the full footprint of each wire, it would have been sufficient to generate a series of line segments, and then
test these for intersection. A naïve approach here of simply comparing each pair of segments would be quadratic in the
number of segments, but independent of the magnitude of the vectors.

An additional tricky bit here would be what to do with lines that are part of both wires. However, these can be handled
in constant time for each wire: if you have an axis-aligned line segment, the minimised Manhattan distance occurs either at
the end of the segment nearest to the origin on the axis it's parallel to, or in the middle if it crosses zero in the axis.

The bonus version probably can be done with a sweep line style algorithm, which should be log-linear in the number of
components.

## Day 4
Time taken: 10 minutes | Time I'd expect in Java: 8 minutes

Finally, a puzzle without needing input parsing. There are elegant ways of extracting the digits from a number... and then
there is `show` and `read`; as it turned out I didn't even need to convert back to integers, since you only need ordering
and equality on the items bearing the restrictions in mind.

For part 2, I went with a simple approach of condensing each string into a run-length encoded format, e.g. `111122` would
become `[(1, 4), (2, 2)]` and then simply checking if any pair had a second element of 2. Pretty straightforward.

### Jeremy's part 2 idea

> The elves made a mistake and the range of the password was not 248345-746315, but 248345-746315 **centi-millillion**.
  That is, there are 300,003 digits after the first six.
  How many passwords are possible? (Only the part 1 restrictions apply; you can have more than doubled digits.)

Again, I thought Part 2 may have involved a more elegant attack, this time based on combinatorics. For this version of the
puzzle, you'll probably want to begin with each of the six-digit numbers from 248345 to 746314 (note: 746315 followed by
all zeroes is not valid since the numbers decrease), and consider how many ways there are to extend them into a valid
password. While some of these numbers are immediately not extensible, others including non-passwords could be if they were
increasing (e.g. while `234567` is not a valid password, `234567` followed by all 8s is valid).

Walking down all of the possible passwords, even accounting for pruning of decreasing passwords is likely to be a no-go.
The trick here involves what's known as *memoisation*: for example, 223348 and 223358 can extend to the same number of
passwords, because we already have a double *and* the remaining digits must not decrease from 8, so the ways in which they
can be validly extended to form a full password must have the same suffix. Once we figure this out once, we can re-use
the number without computing it again. The "state" we are looking at here would be the number of digits to fill in,
our last digit, and whether we've had a double yet or not.

## Day 5
Time taken: 75 minutes | Time I'd expect in Java: 20 minutes

Probably could have done this faster, but I ended up reimplementing quite a good chunk of the intcode interpreter so
I at least have types to work with. Again, there wasn't very much here other than following the instructions.

There was a bit of slightly dodgy code to parse the digits of a number, with possible leading zeroes. I had

```
normaliseInstruction x = normaliseInstruction' ((map (read . return) $ (reverse $ show x)) ++ (repeat 0))
```

where I basically converted an integer to digits, converted those digits back to numbers, reversed it and added
infinite leading zeroes, then processed it in terms of creating an instruction.

I did struggle with getting the right answer to Part 1 at first, because I didn't initially realise that the output
instruction could take immediate mode arguments. I also lost some time debugging as well because I set input to 55 as
part of testing out the sample programs, and then was wondering why I was having unexpected opcodes of 55. I even
opened up the GHCI debugger for possibly the first time (definitely the first time in years).

## Day 6
Time taken: 25 minutes | Time I'd expect in Java: 10 minutes

In the first part, the number of things that something is orbiting is given by their distance from the root node,
`COM`, and a way to find this is by breadth-first search. I used the Map interface again to store the graph as,
effectively, an adjacency list. We can just compute this across the tree and then take the sum.

For the second part, I added the reverse edges to the graph, and then found the distance from `YOU` to `SAN`.
My BFS already had a visited set to avoid cycles (even though this probably wasn't needed in part 1). One last trick
here was that the number of *transfers* is of course the distance minus 2.
