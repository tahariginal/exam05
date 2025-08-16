#!/bin/bash

# GradeMe-style test script for vect2 (C++)
# Clean scoring harness similar to the provided life script

PROGRAM_NAME="vect2_tests"
TEST_CPP="vect2_tests.cpp"
EXEC="${PROGRAM_NAME}.out"
SOURCE_CPP="vect2.cpp"
HEADER_HPP="vect2.hpp"
CXX=g++
CXXFLAGS="-Wall -Wextra -Werror -std=c++98 -O2 -g"
TIMEOUT=5

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
POINTS=0
MAX_POINTS=0

die() { echo "$@" 1>&2; exit 1; }

cd "$(dirname "$0")" || die "Cannot cd to script directory"

echo "=== COMPILATION ==="

# Generate a compact test runner (selects tests by name via argv[1])
cat > "$TEST_CPP" << 'EOF'
#include <iostream>
#include <sstream>
#include <string>
#include "vect2.hpp"

static bool expect_eq_int(const char* what, int got, int want) {
    if (got != want) {
        std::cerr << what << " expected=" << want << " got=" << got << "\n";
        return false;
    }
    return true;
}

static bool expect_eq_str(const char* what, const std::string& got, const std::string& want) {
    if (got != want) {
        std::cerr << what << " expected='" << want << "' got='" << got << "'\n";
        return false;
    }
    return true;
}

static bool test_default_ctor() {
    vect2 v;
    return expect_eq_int("x", v[0], 0) && expect_eq_int("y", v[1], 0);
}

static bool test_param_ctor() {
    vect2 v(2,7);
    return expect_eq_int("x", v[0], 2) && expect_eq_int("y", v[1], 7);
}

static bool test_copy_and_assign() {
    vect2 v(3,4);
    const vect2 c(v);
    if (!(c == v)) return false;
    vect2 a; a = v;
    return (a == v) && !(a != v);
}

static bool test_index_read_write() {
    vect2 v; v[0] = 10; v[1] = 20;
    if (!expect_eq_int("x", v[0], 10)) return false;
    if (!expect_eq_int("y", v[1], 20)) return false;
    const vect2 c(v);
    return expect_eq_int("const y", c[1], 20);
}

static bool test_addition() {
    vect2 a(1,2), b(3,4);
    vect2 c = a + b;
    return expect_eq_int("x", c[0], 4) && expect_eq_int("y", c[1], 6);
}

static bool test_subtraction() {
    vect2 a(5,7), b(2,3);
    vect2 c = a - b;
    return expect_eq_int("x", c[0], 3) && expect_eq_int("y", c[1], 4);
}

static bool test_scalar_mul_right() {
    vect2 a(2,3);
    vect2 c = a * 2;
    return expect_eq_int("x", c[0], 4) && expect_eq_int("y", c[1], 6);
}

static bool test_scalar_mul_left() {
    vect2 a(2,3);
    vect2 c = 3 * a;
    return expect_eq_int("x", c[0], 6) && expect_eq_int("y", c[1], 9);
}

static bool test_compound_mul_scalar() {
    vect2 a(2,3);
    a *= 4;
    return expect_eq_int("x", a[0], 8) && expect_eq_int("y", a[1], 12);
}

static bool test_scalar_mul_zero_neg() {
    vect2 a(2,-3);
    vect2 z = a * 0;
    if (!(z[0]==0 && z[1]==0)) return false;
    vect2 n = a * -1;
    return (n[0]==-2 && n[1]==3);
}

static bool test_equality_ops() {
    vect2 a(1,1), b(1,1), c(0,1);
    return (a == b) && !(a != b) && (a != c) && !(a == c);
}

static bool test_inc_dec() {
    vect2 v(2,7);
    vect2 post = v++;
    if (!((post[0]==2)&&(post[1]==7))) return false;
    if (!((v[0]==3)&&(v[1]==8))) return false;
    vect2 pre = ++v;
    if (!((pre[0]==4)&&(pre[1]==9))) return false;
    if (!((v[0]==4)&&(v[1]==9))) return false;
    vect2 postd = v--;
    if (!((postd[0]==4)&&(postd[1]==9))) return false;
    if (!((v[0]==3)&&(v[1]==8))) return false;
    vect2 pred = --v;
    if (!((pred[0]==2)&&(pred[1]==7))) return false;
    if (!((v[0]==2)&&(v[1]==7))) return false;
    return true;
}

static bool test_stream_output() {
    vect2 v(2,7);
    std::ostringstream oss; oss << v;
    return expect_eq_str("ostream", oss.str(), "{2, 7}");
}

static bool test_chained_plus_equal() {
    vect2 a(1,2), b(3,4);
    a += a += b; // a = (a += b) + a_initial
    // After inner (a += b): a = (1+3,2+4)=(4,6)
    // outer: a = a + a_initial? Actually operator+= returns reference to a, so expression is equivalent to a += (a += b)
    // After inner, a == (4,6); then a += (4,6) => (8,12)
    return expect_eq_int("x", a[0], 8) && expect_eq_int("y", a[1], 12);
}

static bool test_unary() {
    vect2 v(2,-3);
    vect2 p = +v;
    vect2 n = -v;
    return (p[0]==2 && p[1]==-3 && n[0]==-2 && n[1]==3);
}

static bool test_expr_precedence() {
    vect2 v(2,7);
    vect2 r = v + v * 2; // expect v + (v*2)
    return (r[0]==6 && r[1]==21);
}

static bool test_self_assignment() {
    vect2 v(5,-4);
    v = v;
    return (v[0]==5 && v[1]==-4);
}

static bool test_minus_equal() {
    vect2 a(5,7), b(2,3);
    a -= b;
    return (a[0]==3 && a[1]==4);
}

static bool test_component_mul_vector() {
    vect2 a(2,3), b(-4,5);
    a *= b; // component-wise multiply per implementation
    return (a[0]==-8 && a[1]==15);
}

static bool test_stream_sequence() {
    vect2 v(1,2);
    std::ostringstream oss;
    oss << v << ' ' << -v;
    return expect_eq_str("ostream sequence", oss.str(), "{1, 2} {-1, -2}");
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0] << " <test-name>\n";
        return 2;
    }
    std::string t(argv[1]);
    bool ok = false;
    if (t == "default_ctor") ok = test_default_ctor();
    else if (t == "param_ctor") ok = test_param_ctor();
    else if (t == "copy_assign") ok = test_copy_and_assign();
    else if (t == "index_rw") ok = test_index_read_write();
    else if (t == "add") ok = test_addition();
    else if (t == "sub") ok = test_subtraction();
    else if (t == "mul_right") ok = test_scalar_mul_right();
    else if (t == "mul_left") ok = test_scalar_mul_left();
    else if (t == "mul_compound") ok = test_compound_mul_scalar();
    else if (t == "mul_zero_neg") ok = test_scalar_mul_zero_neg();
    else if (t == "eq_ops") ok = test_equality_ops();
    else if (t == "inc_dec") ok = test_inc_dec();
    else if (t == "ostream") ok = test_stream_output();
    else if (t == "plus_equal_chain") ok = test_chained_plus_equal();
    else if (t == "unary") ok = test_unary();
    else if (t == "expr_precedence") ok = test_expr_precedence();
    else if (t == "self_assign") ok = test_self_assignment();
    else if (t == "minus_equal") ok = test_minus_equal();
    else if (t == "component_mul_vector") ok = test_component_mul_vector();
    else if (t == "ostream_seq") ok = test_stream_sequence();
    else {
        std::cerr << "unknown test: " << t << "\n";
        return 2;
    }
    return ok ? 0 : 1;
}
EOF

# Compile
$CXX $CXXFLAGS "$SOURCE_CPP" "$TEST_CPP" -o "$EXEC"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    echo "Score: 0/100"
    rm -f "$TEST_CPP" "$EXEC"
    exit 1
fi
echo "COMPILATION SUCCESSFUL"
echo

# Simple test runner
run_test() {
    local name="$1"
    local points="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    MAX_POINTS=$((MAX_POINTS + points))
    echo "Test $TOTAL_TESTS: $name ($points points)"
    timeout $TIMEOUT ./$EXEC "$name" >/dev/null 2>&1
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo "TIMEOUT"
    elif [ $exit_code -eq 0 ]; then
        echo "PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        POINTS=$((POINTS + points))
    else
        echo "FAILED"
    fi
    echo "---"
}

echo "=== CONSTRUCTORS & INDEXING (20 points) ==="
run_test default_ctor 5
run_test param_ctor 5
run_test copy_assign 5
run_test index_rw 5

echo "=== OPERATORS (35 points) ==="
run_test add 5
run_test sub 5
run_test mul_right 5
run_test mul_left 5
run_test mul_compound 5
run_test unary 5
run_test mul_zero_neg 5

echo "=== COMPARISON (10 points) ==="
run_test eq_ops 10

echo "=== INC/DEC (15 points) ==="
run_test inc_dec 15

echo "=== STREAM OUTPUT (10 points) ==="
run_test ostream 10
run_test ostream_seq 5

echo "=== CHAINING (10 points) ==="
run_test plus_equal_chain 10

echo "=== EXTRA EXPRESSIONS (25 points) ==="
run_test expr_precedence 10
run_test self_assign 5
run_test minus_equal 5
run_test component_mul_vector 5

PERCENTAGE=$((POINTS * 100 / MAX_POINTS))

echo
echo "=== RESULTS ==="
echo "Tests run: $TOTAL_TESTS"
echo "Tests passed: $PASSED_TESTS"
echo "Points: $POINTS/$MAX_POINTS"
echo "Percentage: $PERCENTAGE%"

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
rm -f "$EXEC" "$TEST_CPP"

# Exit code based on threshold (60%)
if [ $PERCENTAGE -ge 60 ]; then
    exit 0
else
    exit 1
fi
