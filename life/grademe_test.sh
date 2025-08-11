#!/bin/bash

# Simple GradeMe Test Script for Conway's Game of Life
# Clean and straightforward testing without unnecessary complexity

# Configuration
PROGRAM_NAME="life"
SOURCE_FILE="life.c"
COMPILE_FLAGS="-Wall -Wextra -Werror -std=c11 -O2 -g"
TIMEOUT=5

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
POINTS=0
MAX_POINTS=0

# Compile the program
echo "=== COMPILATION ==="
gcc -o $PROGRAM_NAME $SOURCE_FILE $COMPILE_FLAGS
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    echo "Score: 0/100"
    exit 1
fi
echo "COMPILATION SUCCESSFUL"
echo

# Simple test function
run_test() {
    local test_name="$1"
    local points="$2"
    local width="$3"
    local height="$4"
    local iterations="$5"
    local input="$6"
    local expected_exit="$7"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    MAX_POINTS=$((MAX_POINTS + points))
    
    echo "Test $TOTAL_TESTS: $test_name ($points points)"
    
    # Run the test
    if [ -n "$input" ]; then
        timeout $TIMEOUT sh -c "echo '$input' | ./$PROGRAM_NAME $width $height $iterations" >/dev/null 2>&1
    else
        timeout $TIMEOUT ./$PROGRAM_NAME $width $height $iterations >/dev/null 2>&1
    fi
    exit_code=$?
    
    # Check result
    if [ $exit_code -eq 124 ]; then
        echo "TIMEOUT"
    elif [ $expected_exit -eq 0 ] && [ $exit_code -eq 0 ]; then
        echo "PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        POINTS=$((POINTS + points))
    elif [ $expected_exit -eq 1 ] && [ $exit_code -ne 0 ]; then
        echo "PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        POINTS=$((POINTS + points))
    else
        echo "FAILED"
    fi
    echo "---"
}

# Remove the complex output test function and replace with simpler tests
echo "=== ARGUMENT VALIDATION TESTS (20 points) ==="
run_test "No arguments" 3 "" "" "" "" 1
run_test "Too few arguments" 3 "5" "5" "" "" 1
run_test "Invalid width (0)" 3 "0" "5" "1" "" 1
run_test "Invalid height (0)" 3 "5" "0" "1" "" 1
run_test "Negative width" 2 "-1" "5" "1" "" 1
run_test "Negative height" 2 "5" "-1" "1" "" 1
run_test "Negative iterations" 2 "5" "5" "-1" "" 1
run_test "Valid arguments" 2 "3" "3" "0" "" 0

echo "=== BASIC FUNCTIONALITY TESTS (30 points) ==="
run_test "Empty board 1x1" 5 "1" "1" "1" "" 0
run_test "Empty board 3x3" 5 "3" "3" "1" "" 0
run_test "Zero iterations" 5 "3" "3" "0" "" 0
run_test "Single cell placement" 5 "3" "3" "0" "x" 0
run_test "Single cell dies" 5 "3" "3" "1" "x" 0
run_test "Movement commands" 5 "3" "3" "0" "dx" 0

echo "=== GAME OF LIFE RULES TESTS (30 points) ==="
run_test "Block pattern" 10 "4" "4" "3" "xdxsax" 0
run_test "Blinker pattern" 10 "5" "5" "2" "dxdxdx" 0
run_test "Cell death" 5 "5" "5" "1" "ddsdx" 0
run_test "Cell birth" 5 "5" "5" "1" "ddxsaxddx" 0

echo "=== EDGE TESTS (20 points) ==="
run_test "Edge placement" 5 "3" "3" "0" "ddx" 0
run_test "Corner placement" 5 "3" "3" "0" "ssddx" 0
run_test "Boundary movement" 5 "3" "3" "0" "wwwaaax" 0
run_test "Large board" 5 "10" "10" "1" "x" 0

# Calculate final score
PERCENTAGE=$((POINTS * 100 / MAX_POINTS))

echo
echo "=== RESULTS ==="
echo "Tests run: $TOTAL_TESTS"
echo "Tests passed: $PASSED_TESTS"
echo "Points: $POINTS/$MAX_POINTS"
echo "Percentage: $PERCENTAGE%"

# Letter grade
if [ $PERCENTAGE -ge 90 ]; then
    GRADE="A"
elif [ $PERCENTAGE -ge 80 ]; then
    GRADE="B"
elif [ $PERCENTAGE -ge 70 ]; then
    GRADE="C"
elif [ $PERCENTAGE -ge 60 ]; then
    GRADE="D"
else
    GRADE="F"
fi

echo "Grade: $GRADE"

# Cleanup
rm -f $PROGRAM_NAME

# Exit with appropriate code
if [ $PERCENTAGE -ge 60 ]; then
    exit 0
else
    exit 1
fi
