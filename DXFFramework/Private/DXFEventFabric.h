//
//  DXFEventFabric.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import "dxfg_events.h"

NS_ASSUME_NONNULL_BEGIN

@class DXFEvent;
@interface DXFEventFabric : NSObject

- (instancetype)init:(NSDictionary *)events;
- (DXFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent;

@end

NS_ASSUME_NONNULL_END
