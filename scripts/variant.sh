#!/bin/bash
# Check, snapshot or render an A/B variant (variants/variant-<x>.html).
# HyperFrames reads only index.html, so each variant runs in a temporary
# copy of the project with the variant as its index.html.
#   scripts/variant.sh b check
#   scripts/variant.sh b snapshot --at 1.2,5,9,13
#   scripts/variant.sh b render
set -euo pipefail
v="$1"; cmd="$2"; shift 2
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -r "$root"/{assets,compositions,hyperframes.json,meta.json,package.json} "$work/"
cp "$root/variants/variant-$v.html" "$work/index.html"
cd "$work"
case "$cmd" in
  render)
    mkdir -p "$root/deliverables"
    npx hyperframes render -o "$root/deliverables/china-village-reel-15s-$v.mp4" "$@" ;;
  snapshot)
    npx hyperframes snapshot -o "$root/snapshots/variant-$v" "$@" ;;
  *)
    npx hyperframes "$cmd" "$@" ;;
esac
