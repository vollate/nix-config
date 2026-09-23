#!/usr/bin/env bash
set -euo pipefail

# Run as root: querying and modifying the system profile requires its lock.
profile=/nix/var/nix/profiles/system
cutoff=$(date --date='7 days ago' +%s)
generations=$(nix-env --profile "$profile" --list-generations)
# Generation numbers increase monotonically; newest first.
mapfile -t rows < <(printf '%s\n' "$generations" | sort -k1,1nr)
delete=()

for i in "${!rows[@]}"; do
    # Keep the newest three, regardless of age.
    if (( i < 3 )); then
        continue
    fi
    read -r generation day time marker <<< "${rows[$i]}"
    [[ -n "$generation" ]] || continue
    [[ "$generation" =~ ^[0-9]+$ ]] || { echo 'Unexpected generation listing' >&2; exit 1; }
    # Protect the active generation even after a rollback.
    [[ "$marker" != *current* ]] || continue
    created=$(date --date="$day $time" +%s)
    if (( created < cutoff )); then
        delete+=("$generation")
    fi
done

if (( ${#delete[@]} )); then
    printf 'Deleting system generations: %s\n' "${delete[*]}"
    nix-env --profile "$profile" --delete-generations "${delete[@]}"
else
    echo 'No system generations meet both retention conditions.'
fi

# Unlike nix-collect-garbage -d, this does not delete other profile generations.
nix-store --gc
