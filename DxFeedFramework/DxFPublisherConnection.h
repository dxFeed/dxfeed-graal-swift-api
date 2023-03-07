//
//  DxFPublisherConnection.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DxFEnvironment;
@interface DxFPublisherConnection : NSObject

- (nonnull instancetype)init:(nonnull DxFEnvironment *)env port:(NSString *)port;

- (BOOL)connect;

@end

NS_ASSUME_NONNULL_END
