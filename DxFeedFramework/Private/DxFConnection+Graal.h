//
//  DxFConnection+Graal.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <DxFeedFramework/DxFeedFramework.h>
#import "dxfg_api.h"

NS_ASSUME_NONNULL_BEGIN

@interface DxFConnection (Graal)

@property (nonatomic, readonly) dxfg_endpoint_t* endpoint;

@end

NS_ASSUME_NONNULL_END
