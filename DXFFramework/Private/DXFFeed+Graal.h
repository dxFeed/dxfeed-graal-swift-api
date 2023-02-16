//
//  DXFFeed+Graal.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 13.02.2023.
//

#import <DXFFramework/DXFFramework.h>
#import "dxfg_api.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFFeed (Graal)

@property (nonatomic, readonly) dxfg_feed_t* feed;

@end

NS_ASSUME_NONNULL_END
