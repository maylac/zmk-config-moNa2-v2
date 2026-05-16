#!/bin/sh
set -eu

if ! test -x scripts/check_all.sh; then
  echo "missing executable scripts/check_all.sh" >&2
  exit 1
fi

if ! test -x .githooks/pre-commit; then
  echo "missing executable .githooks/pre-commit hook" >&2
  exit 1
fi

if ! rg -q 'tests/check_git_hooks\.sh' scripts/check_all.sh; then
  echo "scripts/check_all.sh must include the git hook check" >&2
  exit 1
fi

if ! rg -q 'git diff --check --cached' scripts/check_all.sh; then
  echo "scripts/check_all.sh must check staged whitespace before commit" >&2
  exit 1
fi

if ! rg -q 'scripts/check_all\.sh' .githooks/pre-commit; then
  echo ".githooks/pre-commit must run scripts/check_all.sh" >&2
  exit 1
fi

echo "Git hook wiring looks consistent."
