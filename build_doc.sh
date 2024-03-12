xcodebuild docbuild -scheme DXFeedFramework -derivedDataPath documentations/

`(xcrun --find docc)` process-archive \
transform-for-static-hosting documentations/Build/Products/Debug/DXFeedFramework.doccarchive \
--output-path docs \
--hosting-base-path dxfeed-graal-swift-api

