#!/usr/bin/env bash
# Run from anywhere before opening a PR:  ./scripts/check-mvvm.sh
# Any output means the PR breaks the MVVM rules and should not be merged.

cd "$(dirname "$0")/.." || exit 1
status=0

# Screens get data only through repositories/services passed in by AppContainer.
direct_data=$(grep -rlE "DummyData\.|import AVFoundation|InMemory[A-Za-z]+Repository\(|Dummy[A-Za-z]+Service\(" EchoProject/Features --include="*.swift" 2>/dev/null)
if [ -n "$direct_data" ]; then
    echo "These files reach data or services directly (use the protocol passed into the ViewModel):"
    echo "$direct_data"
    status=1
fi

# ViewModels stay UI-free.
ui_in_viewmodels=$(grep -rl "import SwiftUI" EchoProject/Features --include="*ViewModel.swift" 2>/dev/null)
if [ -n "$ui_in_viewmodels" ]; then
    echo "These ViewModels import SwiftUI:"
    echo "$ui_in_viewmodels"
    status=1
fi

if [ $status -eq 0 ]; then
    echo "MVVM check passed."
fi
exit $status
