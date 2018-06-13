#!/bin/bash
set -o pipefail
xcodebuild test -project Food2Fork.xcodeproj -scheme "Food2Fork" -sdk iphonesimulator11.3 -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.3' ENABLE_TESTABILITY=YES | xcpretty --color
