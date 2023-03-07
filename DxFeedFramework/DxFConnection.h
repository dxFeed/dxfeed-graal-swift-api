//
//  DxFConnection.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DxFConnectionState.h>

NS_ASSUME_NONNULL_BEGIN

@class DxFEnvironment;
@interface DxFConnection : NSObject

@property (nonatomic) DxFConnectionState state;

- (nonnull instancetype)init:(nonnull DxFEnvironment *)env address:(NSString *)address;

- (BOOL)connect;

@end

NS_ASSUME_NONNULL_END
