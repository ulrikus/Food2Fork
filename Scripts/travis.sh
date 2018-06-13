#!/bin/bash
set -o pipefail
xcodebuild test -project Food2Fork.xcodeproj -scheme Food2Fork -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO | xcpretty -c
