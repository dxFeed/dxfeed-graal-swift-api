//
//  DXFConnection.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>
#import <DXFFramework/DXFControl.h>
#import <DXFFramework/DXFConnectionState.h>

NS_ASSUME_NONNULL_BEGIN


@interface DXFConnection : NSObject <DXFControl>

@property (nonatomic) DXFConnectionState state;

- (nonnull instancetype)init:(nonnull DXFEnvironment *)env address:(NSString *)address;

- (BOOL)connect;

@end

NS_ASSUME_NONNULL_END
