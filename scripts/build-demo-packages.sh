#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${1:-$repo_dir/dist}"
stage_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$stage_dir"
}
trap cleanup EXIT

mkdir -p "$dist_dir"
rm -f "$dist_dir/ml-system-hld-claude.zip" "$dist_dir/hld-codex-plugin.zip"

mkdir -p "$stage_dir/claude/ml-system-hld"
cp -R "$repo_dir/skills/ml-system-hld/." "$stage_dir/claude/ml-system-hld/"
(
  cd "$stage_dir/claude"
  zip -qr "$dist_dir/ml-system-hld-claude.zip" ml-system-hld
)

mkdir -p "$stage_dir/codex/hld/.codex-plugin" "$stage_dir/codex/hld/skills"
cp "$repo_dir/.codex-plugin/plugin.json" "$stage_dir/codex/hld/.codex-plugin/plugin.json"
cp -R "$repo_dir/skills/ml-system-hld" "$stage_dir/codex/hld/skills/"
(
  cd "$stage_dir/codex"
  zip -qr "$dist_dir/hld-codex-plugin.zip" hld
)

printf 'Created:\n%s\n%s\n' \
  "$dist_dir/ml-system-hld-claude.zip" \
  "$dist_dir/hld-codex-plugin.zip"
