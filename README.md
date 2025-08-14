# Exam05 – Level 00 & Level 01 Comprehensive README

This repository contains two levels (level00, level01) grouping four independent exercises:

| Level | Exercise | Lang | Focus (Goal) |
|:-----:|:---------|:----:|:-------------|
| 00 | vect2  | C++ | 2D vector class, operators, canonical form |
| 00 | polyset| C++ | Bag hierarchy, searchable adapters, set wrapper |
| 01 | life   |  C  | Game of Life: input drawing + evolution output |
| 01 | bsq    |  C  | Largest square detection in map (DP) |

Each exercise is self‑contained; you can build and test them separately.

---
## Global Requirements & Conventions
- Compilers: `g++` (C++11 used in polyset due to `nullptr`), `gcc` for C parts.
- Warning discipline: treat warnings as errors (`-Wall -Wextra -Werror`) where practical.
- Memory: All dynamic allocations freed; no leaks expected for normal paths.
- Style: Orthodox canonical form (default ctor, copy ctor, assignment operator, destructor) where specified.
- Scripts: Some exercises provide a `grademe_*` style script; these generate ephemeral test harnesses.

---
## 1. vect2 (level00/vect2)
### Overview
Implements a lightweight 2D integer vector `vect2` supporting:
- Construction (default, parameterized, copy)
- Element access via `operator[]` (mutable & const)
- Arithmetic: `+`, `-`, scalar multiplication both sides, component‑wise compound ops (`+=`, `-=`, `*=scalar`, `*=vector`)
- Unary `+` (identity) & unary `-` (negation)
- Increment / decrement (pre & post, incrementing both coordinates)
- Comparison `==`, `!=`
- Stream output as `{x, y}`

### Key Design Points
- Stored as two `int` members (no heap usage – trivially copyable semantics).
- `operator+=` returns reference enabling chaining (`a += a += b`).
- Pre/post increment semantics match built‑in integral types (post returns old value).
- `operator[]` chooses `x` for index 0, `y` otherwise (input assumed 0 or 1).

### Potential Edge Considerations
- No bounds checking on `operator[]` (could be extended to throw on invalid index).
- Overflow not handled (uses native `int` wrap‑around semantics).

### Building
```
cd level00/vect2
g++ -Wall -Wextra -Werror -std=c++98 -O2 vect2.cpp -c
```
(Only header‑inline implementation is used; `vect2.cpp` may be empty or contain future tests.)

### Test Script
`grademe_vect2.sh` auto‑generates a test harness exercising constructors, indexing, arithmetic, chaining, streaming, expression precedence, and equality. Run:
```
cd level00/vect2
bash grademe_vect2.sh
```
Exit code non‑zero signals below‑threshold grade.

---
## 2. polyset (level00/polyset)
### Objective
Introduce polymorphism & composition with a hierarchy of *bag* containers and a *set* wrapper that enforces uniqueness over an underlying searchable bag implementation.

### Provided Abstract Layers
| Class | Role / Description | Key API (public) |
|:------|:--------------------|:-----------------|
| `bag` | Abstract base bag (insertion + traversal printing) | `insert(int)`, `insert(int*,int)`, `print()`, `clear()` |
| `searchable_bag` | Extends bag with membership query | `has(int)` (+ inherited) |

### Concrete Implementations
| Class | Storage / Strategy | Duplicate Handling | Complexity (lookup)* |
|:------|:-------------------|:-------------------|:--------------------|
| `array_bag` | Resizable raw array (reallocate on each insert) | Allows duplicates | O(n) (no search method here) |
| `tree_bag` | Unbalanced BST | Rejects duplicates (node freed) | O(h) (no search method here) |
| `searchable_array_bag` | Adds linear scan membership | Accepts base duplicates | O(n) |
| `searchable_tree_bag` | BST membership traversal | BST duplicate prevention | O(h) (worst O(n)) |
| `set` | Wrapper around any `searchable_bag` | Filters duplicates at wrapper level | Depends on underlying |
*h = height of BST.

### Responsibilities
1. Implement searchable adapters (`searchable_array_bag`, `searchable_tree_bag`).
2. Provide `set` wrapper enforcing semantic uniqueness.
3. Preserve orthodox canonical form in derived classes.

### Memory & Ownership
- Each concrete bag manages its own dynamic memory (array or nodes).
- `set` does **not** own the underlying bag (holds a reference); lifetime must outlive the set.

### Known Simplifications / Gaps
- No `size()` interface exposed publicly.
- `tree_bag` prints debug messages (e.g., node creation & destruction) – could be toggled behind a debug flag.
- No iterator abstraction.

### Building & Running
```bash
cd level00/polyset
g++ -Wall -Wextra -Werror -std=c++11 -O2 -g \
  main.cpp array_bag.cpp tree_bag.cpp \
  searchable_array_bag.cpp searchable_tree_bag.cpp set.cpp \
  -o polyset_demo
./polyset_demo 5 2 9 2 7
```
`main.cpp` demonstrates insertion, duplicate handling, search queries, clearing, and composite operations.

### Test Harness Script
A script `test_grademe.sh` (iteratively improved) generates a focused tester verifying basic set behaviors (insertion uniqueness, clear, bulk insert, print).
Run:
```
cd level00/polyset
bash test_grademe.sh
```

---
## 3. life (level01/life)
### Goal
Simplified terminal Game of Life tool combining:
1. An input drawing phase using `w a s d` movement and `x` toggle pen to mark live cells on a blank grid read from stdin (terminates on EOF / end of piped input).
2. Evolution for a fixed number of iterations using standard Conway rules.
3. Final board snapshot printed as an ASCII grid (`O` for live, space for dead).

### Invocation
```
./life <width> <height> <iterations> < pattern_input.txt
```
Returns `1` on invalid args or allocation failure.

### Core Logic
- Board stored as 1D array with macro `DX(y,x,w)` for indexing.
- Evolution: counts 8 neighbors for each cell; uses double buffering (`board`/`next`).
- Rule: alive next = (alive && (n==2 || n==3)) || (!alive && n==3).

### Performance Notes
- Neighbor counting naive (O(w*h*8)); adequate for small academic grids.
- Could be optimized with bitsets or region trimming.

### Potential Extensions
- Interactive real‑time mode (ncurses).
- RLE pattern import/export.

### Testing
`grademe_test.sh` (if provided) can be adapted to feed scripted patterns and diff expected outputs.

---
## 4. bsq (level01/bsq)
### Purpose
Classic “Biggest Square” problem: given a map with empty + obstacle characters, find largest obstacle‑free square and mark it with a fill character.

### Input Format
First line: `<lines><empty><obstacle><full>\n`
- `<lines>`: decimal positive integer (number of map rows)
- Single characters define semantics of cells.
Following lines: exactly `<lines>` lines of equal width containing only `empty` or `obstacle` characters (validated unless last line handling differs—current code tolerates final line length equal to width).

### Validation Performed
- File open success (or stdin).
- Parse header (4 items).
- Distinctness of the three symbols.
- Positive `lines`.
- Row count matching header.
- Consistent width across rows (except final newline nuances).
- Allowed characters only.

### Algorithm
Dynamic programming (DP) table `dp[i][j]` storing size of largest square ending at `(i,j)`.
Transition:
```
if obstacle => 0
else if first row/col => 1
else => 1 + min( top, left, top-left )
```
Track maximum value & coordinates; fill square region with `full` char after DP.

### Complexity
- Time: O(lines * width)
- Space: O(lines * width) (stack array VLA usage – relies on compiler extension for variable length array; could be replaced by heap allocation for strict portability).

### Building & Running
```
cd level01/bsq
gcc -Wall -Wextra -Werror -O2 bsq.c -o bsq
./bsq < map.txt
# or
./bsq map.txt
```
Exit codes: `1` on error; prints `map error` (with trailing space + newline) on invalid input.

### Edge Cases
- Single row / column maps.
- Entirely obstacles (largest square size = 0 → no fill performed; current code leaves map unchanged).
- Multiple equally large squares: chooses the one whose bottom/rightmost occurrence is last updated (standard DP tie behavior).

### Potential Improvements
- Replace VLA with dynamic allocation for strict C standard compliance (C90/C99 portability).
- Stream processing to reduce memory (two-row DP buffering).
- More descriptive error messages.

---
## Build Matrix Summary
| Component | Build / Run Command |
|:----------|:--------------------|
| vect2 tests | `cd level00/vect2 && bash grademe_vect2.sh` |
| polyset demo | `cd level00/polyset && g++ -std=c++11 -Wall -Wextra -Werror -O2 *.cpp -o polyset_demo && ./polyset_demo 1 2 3` |
| polyset tests | `cd level00/polyset && bash test_grademe.sh` |
| life | `cd level01/life && gcc -Wall -Wextra -Werror life.c -o life && ./life 5 5 3 < pattern.txt` |
| bsq | `cd level01/bsq && gcc -Wall -Wextra -Werror bsq.c -o bsq && ./bsq map.txt` |

---
## Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| `nullptr` errors under `-std=c++98` | polyset uses C++11 feature | Compile with `-std=c++11` or replace with `NULL` |
| Script hangs after `=== COMPILATION ===` | Here‑doc or wrap issue in script | Ensure EOF delimiter unindented & file generated (`ls`) |
| Duplicate values appear in set output | Underlying bag allows duplicates | Wrapper only prevents additional insertions via `set::insert`; direct bag access circumvents uniqueness |
| `map error` in bsq | Input validation failed | Verify header & symbol distinctness; line widths consistent |
| Segfault in bsq large map | Stack DP VLA too large | Convert DP to heap allocation |

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
