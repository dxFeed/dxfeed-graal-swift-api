//
//  DxFEventFabric.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import "dxfg_events.h"
#import "DxFEventType.h"

NS_ASSUME_NONNULL_BEGIN

@class DxFEvent;
@interface DxFEventFabric : NSObject

- (DxFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent;

@end

NS_ASSUME_NONNULL_END
