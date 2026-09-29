#!/bin/sh
# render-report.test.sh -- hand-rolled POSIX sh test for render-report.sh.
# No bats, no external test framework. Exits non-zero on any failed
# assertion, printing which assertion failed.

set -e

RR_TEST_DIR=$(cd "$(dirname "$0")" && pwd)
RR_SCRIPT="$RR_TEST_DIR/../render-report.sh"

RR_TMP=$(mktemp -d "${TMPDIR:-/tmp}/render-report-test.XXXXXX")
trap 'rm -rf "$RR_TMP"' 0

RR_FAILED=0

rr_fail() {
  # $1 = message
  printf 'FAIL: %s\n' "$1" >&2
  RR_FAILED=1
}

rr_pass() {
  # $1 = message
  printf 'ok - %s\n' "$1"
}

rr_assert_contains() {
  # $1 = file, $2 = needle, $3 = assertion name
  if grep -F -q -- "$2" "$1"; then
    rr_pass "$3"
  else
    rr_fail "$3 (expected to find: $2)"
  fi
}

rr_assert_not_contains() {
  # $1 = file, $2 = needle, $3 = assertion name
  if grep -F -q -- "$2" "$1"; then
    rr_fail "$3 (did not expect to find: $2)"
  else
    rr_pass "$3"
  fi
}

# --- assertion 1: basic render ----------------------------------------------

RR_OUT1="$RR_TMP/basic.html"
RR_LINK1=$(printf '## Section One\n\nA paragraph line.\n\n- Item one\n- Item two\n' \
  | sh "$RR_SCRIPT" --title "Basic Report" --out "$RR_OUT1")

if [ -f "$RR_OUT1" ]; then
  rr_pass "basic render: output file exists"
else
  rr_fail "basic render: output file exists ($RR_OUT1 missing)"
fi

rr_assert_contains "$RR_OUT1" "Basic Report" "basic render: escaped title present"
rr_assert_contains "$RR_OUT1" "<h2>Section One</h2>" "basic render: heading present"
rr_assert_contains "$RR_OUT1" "<li>Item one</li>" "basic render: list item present"
rr_assert_contains "$RR_OUT1" "prefers-color-scheme: dark" "basic render: dark CSS block present"
rr_assert_contains "$RR_OUT1" ":root {" "basic render: light CSS block present"

# --- assertion 2: HTML escaping ----------------------------------------------

RR_OUT2="$RR_TMP/escaped.html"
printf '## Heading & things\n\nA line with <script>alert(1)</script> in it.\n' \
  | sh "$RR_SCRIPT" --title "Title with <script>alert(2)</script> & stuff" --out "$RR_OUT2" > /dev/null

rr_assert_not_contains "$RR_OUT2" "<script>" "escaping: no live <script> tag in output"
rr_assert_contains "$RR_OUT2" "&lt;script&gt;" "escaping: script tag escaped"
rr_assert_contains "$RR_OUT2" "&amp;" "escaping: bare ampersand escaped"

# --- assertion 3: missing --title ---------------------------------------------

RR_ERR3="$RR_TMP/err3.txt"
RR_OUT3="$RR_TMP/never-written.html"
set +e
printf 'a paragraph\n' | sh "$RR_SCRIPT" --out "$RR_OUT3" > "$RR_TMP/out3.txt" 2> "$RR_ERR3"
RR_STATUS3=$?
set -e

if [ "$RR_STATUS3" -ne 0 ]; then
  rr_pass "missing title: exits non-zero"
else
  rr_fail "missing title: exits non-zero (got 0)"
fi

RR_ERR3_LINES=$(wc -l < "$RR_ERR3" | tr -d ' ')
if [ "$RR_ERR3_LINES" = "1" ]; then
  rr_pass "missing title: stderr is one line"
else
  rr_fail "missing title: stderr is one line (got $RR_ERR3_LINES lines)"
fi

if [ -s "$RR_ERR3" ]; then
  rr_pass "missing title: stderr is non-empty"
else
  rr_fail "missing title: stderr is non-empty"
fi

if [ -f "$RR_OUT3" ]; then
  rr_fail "missing title: no file written (found $RR_OUT3)"
else
  rr_pass "missing title: no file written"
fi

# --- assertion 3b: --title with an embedded newline ---------------------------

RR_ERR3B="$RR_TMP/err3b.txt"
RR_OUT3B="$RR_TMP/never-written-3b.html"
RR_TITLE3B=$(printf 'x\n__BODY__\ny')
set +e
printf 'a paragraph\n' | sh "$RR_SCRIPT" --title "$RR_TITLE3B" --out "$RR_OUT3B" > "$RR_TMP/out3b.txt" 2> "$RR_ERR3B"
RR_STATUS3B=$?
set -e

if [ "$RR_STATUS3B" -ne 0 ]; then
  rr_pass "newline title: exits non-zero"
else
  rr_fail "newline title: exits non-zero (got 0)"
fi

RR_ERR3B_LINES=$(wc -l < "$RR_ERR3B" | tr -d ' ')
if [ "$RR_ERR3B_LINES" = "1" ]; then
  rr_pass "newline title: stderr is one line"
else
  rr_fail "newline title: stderr is one line (got $RR_ERR3B_LINES lines)"
fi

if [ -s "$RR_ERR3B" ]; then
  rr_pass "newline title: stderr is non-empty"
else
  rr_fail "newline title: stderr is non-empty"
fi

if [ -f "$RR_OUT3B" ]; then
  rr_fail "newline title: no file written (found $RR_OUT3B)"
else
  rr_pass "newline title: no file written"
fi

# --- assertion 4: stdout is exactly one file:// line -------------------------

RR_OUT4="$RR_TMP/single-line.html"
RR_STDOUT4="$RR_TMP/stdout4.txt"
printf 'just a paragraph\n' | sh "$RR_SCRIPT" --title "Single Line Check" --out "$RR_OUT4" > "$RR_STDOUT4"

RR_STDOUT4_LINES=$(wc -l < "$RR_STDOUT4" | tr -d ' ')
if [ "$RR_STDOUT4_LINES" = "1" ]; then
  rr_pass "stdout: exactly one line"
else
  rr_fail "stdout: exactly one line (got $RR_STDOUT4_LINES lines)"
fi

RR_LINE4=$(cat "$RR_STDOUT4")
case "$RR_LINE4" in
  file://*.html)
    rr_pass "stdout: matches file://...*.html"
    ;;
  *)
    rr_fail "stdout: matches file://...*.html (got: $RR_LINE4)"
    ;;
esac

RR_PATH4=$(printf '%s' "$RR_LINE4" | sed -e 's#^file://##')
if [ -f "$RR_PATH4" ]; then
  rr_pass "stdout: printed path exists on disk"
else
  rr_fail "stdout: printed path exists on disk (got: $RR_PATH4)"
fi

# --- assertion 5: custom --out honored, creating a new parent directory -----

RR_OUT5="$RR_TMP/nested/deeper/custom.html"
if [ -d "$RR_TMP/nested" ]; then
  rr_fail "custom --out: parent directory did not already exist (test setup bug)"
fi

RR_LINE5=$(printf 'hello\n' | sh "$RR_SCRIPT" --title "Custom Out" --out "$RR_OUT5")

if [ -f "$RR_OUT5" ]; then
  rr_pass "custom --out: file written at requested path"
else
  rr_fail "custom --out: file written at requested path (missing $RR_OUT5)"
fi

case "$RR_LINE5" in
  file://*custom.html)
    rr_pass "custom --out: printed link points at the requested file"
    ;;
  *)
    rr_fail "custom --out: printed link points at the requested file (got: $RR_LINE5)"
    ;;
esac

# --- report -------------------------------------------------------------------

if [ "$RR_FAILED" -eq 0 ]; then
  printf 'All assertions passed.\n'
  exit 0
else
  printf 'One or more assertions failed.\n' >&2
  exit 1
fi
