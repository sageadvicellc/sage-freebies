#!/bin/sh
# render-report.sh -- turns a small structured input into a self-contained
# responsive HTML report, and prints its file:// link.
#
# Usage:
#   render-report.sh --title "<text>" [--out <path>] [<input-file>]
#   ... or pipe the input on stdin, with no <input-file> argument.
#
# Input format, one line at a time:
#   "## text"   a section heading
#   "- text"    a list item; consecutive "- " lines group into one list
#   blank line  ends the current list, if one is open
#   any other non-blank line is a paragraph
#
# POSIX sh only. No bash-isms, no Node, no external services.

set -e

RR_SELF_DIR=$(cd "$(dirname "$0")" && pwd)
RR_TEMPLATE="$RR_SELF_DIR/../templates/report.html"

RR_TITLE=""
RR_OUT=""
RR_INPUT_FILE=""

rr_die() {
  # $1 = one-line message for the operator
  printf 'render-report: %s\n' "$1" >&2
  exit 1
}

rr_html_escape() {
  # $1 = raw text; prints HTML-escaped text (& first, then < and >)
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

# --- parse arguments -------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --title)
      [ $# -ge 2 ] || rr_die "--title needs a value"
      RR_TITLE="$2"
      shift 2
      ;;
    --title=*)
      RR_TITLE="${1#--title=}"
      shift
      ;;
    --out)
      [ $# -ge 2 ] || rr_die "--out needs a value"
      RR_OUT="$2"
      shift 2
      ;;
    --out=*)
      RR_OUT="${1#--out=}"
      shift
      ;;
    --)
      shift
      ;;
    -*)
      rr_die "unknown option: $1"
      ;;
    *)
      [ -z "$RR_INPUT_FILE" ] || rr_die "too many arguments: $1"
      RR_INPUT_FILE="$1"
      shift
      ;;
  esac
done

[ -n "$RR_TITLE" ] || rr_die "--title is required"
RR_TITLE_LINES=$(printf '%s\n' "$RR_TITLE" | wc -l | tr -d ' ')
[ "$RR_TITLE_LINES" = "1" ] || rr_die "--title must not contain a newline"
[ -f "$RR_TEMPLATE" ] || rr_die "report template is missing: $RR_TEMPLATE"

if [ -n "$RR_INPUT_FILE" ]; then
  [ -r "$RR_INPUT_FILE" ] || rr_die "cannot read input file: $RR_INPUT_FILE"
fi

# --- working directory ------------------------------------------------------

RR_WORK=$(mktemp -d "${TMPDIR:-/tmp}/render-report.XXXXXX") || rr_die "cannot create a temporary directory"
trap 'rm -rf "$RR_WORK"' 0

RR_INPUT_SOURCE="$RR_WORK/input.txt"
if [ -n "$RR_INPUT_FILE" ]; then
  cat "$RR_INPUT_FILE" > "$RR_INPUT_SOURCE" 2>/dev/null || rr_die "cannot read input file: $RR_INPUT_FILE"
else
  cat > "$RR_INPUT_SOURCE" 2>/dev/null || rr_die "cannot read input from stdin"
fi

# --- build the body HTML ----------------------------------------------------

RR_BODY_FILE="$RR_WORK/body.html"

rr_in_list=0
: > "$RR_BODY_FILE"
while IFS= read -r rr_line || [ -n "$rr_line" ]; do
  case "$rr_line" in
    "## "*)
      if [ "$rr_in_list" -eq 1 ]; then
        printf '</ul>\n' >> "$RR_BODY_FILE"
        rr_in_list=0
      fi
      rr_heading="${rr_line#"## "}"
      printf '<h2>%s</h2>\n' "$(rr_html_escape "$rr_heading")" >> "$RR_BODY_FILE"
      ;;
    "- "*)
      if [ "$rr_in_list" -eq 0 ]; then
        printf '<ul>\n' >> "$RR_BODY_FILE"
        rr_in_list=1
      fi
      rr_item="${rr_line#"- "}"
      printf '<li>%s</li>\n' "$(rr_html_escape "$rr_item")" >> "$RR_BODY_FILE"
      ;;
    "")
      if [ "$rr_in_list" -eq 1 ]; then
        printf '</ul>\n' >> "$RR_BODY_FILE"
        rr_in_list=0
      fi
      ;;
    *)
      if [ "$rr_in_list" -eq 1 ]; then
        printf '</ul>\n' >> "$RR_BODY_FILE"
        rr_in_list=0
      fi
      printf '<p>%s</p>\n' "$(rr_html_escape "$rr_line")" >> "$RR_BODY_FILE"
      ;;
  esac
done < "$RR_INPUT_SOURCE"

if [ "$rr_in_list" -eq 1 ]; then
  printf '</ul>\n' >> "$RR_BODY_FILE"
fi

# --- build the title and timestamp fragments --------------------------------

RR_TITLE_FILE="$RR_WORK/title.html"
rr_html_escape "$RR_TITLE" > "$RR_TITLE_FILE"

RR_GEN_FILE="$RR_WORK/generated-at.html"
RR_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ") || rr_die "cannot read the clock"
printf 'Generated at %s' "$RR_NOW" > "$RR_GEN_FILE"

# --- assemble the report -----------------------------------------------------

RR_STEP1="$RR_WORK/step1.html"
RR_STEP2="$RR_WORK/step2.html"
RR_FINAL="$RR_WORK/final.html"

sed -e '/^__TITLE__$/{' -e "r $RR_TITLE_FILE" -e 'd' -e '}' "$RR_TEMPLATE" > "$RR_STEP1" \
  || rr_die "cannot build the report from the template"
sed -e '/^__GENERATED_AT__$/{' -e "r $RR_GEN_FILE" -e 'd' -e '}' "$RR_STEP1" > "$RR_STEP2" \
  || rr_die "cannot build the report from the template"
sed -e '/^__BODY__$/{' -e "r $RR_BODY_FILE" -e 'd' -e '}' "$RR_STEP2" > "$RR_FINAL" \
  || rr_die "cannot build the report from the template"

# --- resolve the output path -------------------------------------------------

if [ -n "$RR_OUT" ]; then
  RR_TARGET="$RR_OUT"
else
  RR_SLUG=$(printf '%s' "$RR_TITLE" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/-\{2,\}/-/g' -e 's/^-//' -e 's/-$//')
  [ -n "$RR_SLUG" ] || RR_SLUG="report"
  RR_STAMP=$(date -u +"%Y%m%dT%H%M%SZ") || rr_die "cannot read the clock"
  RR_TARGET="./.sage-crew/reports/${RR_SLUG}-${RR_STAMP}.html"
fi

RR_TARGET_DIR=$(dirname "$RR_TARGET")
RR_TARGET_BASE=$(basename "$RR_TARGET")

mkdir -p "$RR_TARGET_DIR" || rr_die "cannot create the output directory: $RR_TARGET_DIR"

RR_ABS_DIR=$(cd "$RR_TARGET_DIR" 2>/dev/null && pwd) || rr_die "cannot resolve the output directory: $RR_TARGET_DIR"
RR_ABS_PATH="$RR_ABS_DIR/$RR_TARGET_BASE"

mv "$RR_FINAL" "$RR_ABS_PATH" || rr_die "cannot write the output file: $RR_ABS_PATH"

printf 'file://%s\n' "$RR_ABS_PATH"
