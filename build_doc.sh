echo $1
xcodebuild docbuild -scheme DXFeedFramework -derivedDataPath documentations/

`(xcrun --find docc)` process-archive \
transform-for-static-hosting documentations/Build/Products/Debug/DXFeedFramework.doccarchive \
--output-path help \
--hosting-base-path $1

