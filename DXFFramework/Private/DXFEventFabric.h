//
//  DXFEventFabric.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import "dxfg_events.h"
#import "DXFEventType.h"

NS_ASSUME_NONNULL_BEGIN

@class DXFEvent;
@interface DXFEventFabric : NSObject

- (instancetype)init:(NSDictionary *)events;
- (DXFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent;
- (BOOL)isSupport:(dxfg_event_clazz_t)type;

@end

NS_ASSUME_NONNULL_END
