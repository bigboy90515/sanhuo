#!/bin/bash

xcodebuild clean
#xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest build
xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' test | xcpretty -s


#xcodebuild -project Carthage-Realm.xcodeproj -scheme Carthage-Realm -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' clean build test | tee $CIRCLE_ARTIFACTS/xcode_raw.log | xcpretty --color --report junit --output $CIRCLE_TEST_REPORTS/xcode/results.xml

#xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest test | tee xcodebuild.log | xcpretty -t -r html --output ~/Desktop/aaaaaaaa.html


