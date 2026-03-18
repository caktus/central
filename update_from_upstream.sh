#!/usr/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <tag> [--continue]"
    echo "Example: $0 v2025.4.2"
    echo "         $0 v2025.4.2 --continue  (after resolving merge conflicts)"
    exit 1
fi

TAG="$1"
CONTINUE=false

if [ "${2:-}" = "--continue" ]; then
    CONTINUE=true
elif [ -n "${2:-}" ]; then
    echo "Unknown flag: $2"
    exit 1
fi

if [ "$CONTINUE" = true ]; then
    echo "Continuing after conflict resolution for tag: $TAG"
    git merge --continue
else
    echo "Updating fork from upstream tag: $TAG"

    # Add upstream remote if it doesn't already exist
    if ! git remote get-url upstream &>/dev/null; then
        echo "Adding upstream remote..."
        git remote add upstream git@github.com:getodk/central.git
    fi

    # Fetch the upstream tag we want to update from
    git fetch upstream tag "$TAG" --force

    # Check out the master branch and make sure it's up to date with our fork
    git checkout master
    git pull origin master

    echo "Merging upstream tag $TAG into master..."
    if ! git merge "$TAG" -m "Merge upstream tag $TAG"; then
        echo ""
        if [ -f .git/MERGE_HEAD ]; then
            echo "Merge conflicts detected. To continue:"
            echo "  1. Resolve the conflicts"
            echo "  2. git add -u"
            echo "  3. $0 $TAG --continue"
        else
            echo "Merge failed (not a conflict). Please check the error above."
        fi
        exit 1
    fi
fi

# Recreate the tag pointing at our merge commit
git tag --force "$TAG"

# Push the updated master branch and the tag (+ force-pushes only the tag)
git push origin master +"$TAG"

echo "Done! Branch 'master' and tag '$TAG' pushed to origin."
