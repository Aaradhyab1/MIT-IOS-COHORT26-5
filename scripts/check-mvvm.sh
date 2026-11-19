#!/usr/bin/env bash
# Run from anywhere before opening a PR:  ./scripts/check-mvvm.sh
# Any output other than "MVVM check passed." means the PR breaks the MVVM rules.

cd "$(dirname "$0")/.." || exit 1
status=0
screens="EchoProject/Features EchoProject/Shared"

report() {
    if [ -n "$2" ]; then
        echo "$1"
        echo "$2"
        echo
        status=1
    fi
}

# Screens get data only through repositories/services passed in by AppContainer.
report "These files reach data or services directly (use the protocol passed into the ViewModel):" \
    "$(grep -rlE "DummyData\.|import AVFoundation|InMemory[A-Za-z]+Repository\(|Dummy[A-Za-z]+Service\(" $screens --include="*.swift" 2>/dev/null)"

# ViewModels and Models stay UI-free.
report "These ViewModels or Models import SwiftUI:" \
    "$(grep -rl "import SwiftUI" $screens --include="*.swift" 2>/dev/null | grep -E "/(ViewModel|Model)/")"

# Folder rule: Views live in View/, ViewModels in ViewModel/.
report "These ViewModels are not in a ViewModel/ folder:" \
    "$(find $screens -name "*ViewModel.swift" | grep -v "/ViewModel/")"
report "These Views are not in a View/ folder:" \
    "$(find $screens -name "*View.swift" -o -name "*Overlay.swift" | grep -v "ViewModel.swift" | grep -v "/View/")"

if [ $status -eq 0 ]; then
    echo "MVVM check passed."
fi
exit $status
