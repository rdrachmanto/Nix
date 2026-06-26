#!/bin/sh

for dir in containers/*; do
    [ -f "$dir/compose.yaml" ] || continue

    echo "Starting $(basename "$dir")"
    (cd "$dir" && podman compose up -d)
done
