//
//  DXFConnection+Graal.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <DXFFramework/DXFFramework.h>
#import "dxfg_api.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFConnection ()

@property (nonatomic, readonly) dxfg_endpoint_t* endpoint;

@end

NS_ASSUME_NONNULL_END
