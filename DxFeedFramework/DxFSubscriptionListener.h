//
//  DXFSubscriptionListener.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 13.02.2023.
//

#ifndef DXFSubscriptionListener_h
#define DXFSubscriptionListener_h

@class DXFEVent;
@protocol DXFSubscriptionListener

- (void)receivedEvents:(NSArray<DXFEvent *> *)events;

@end

#endif /* DXFSubscriptionListener_h */
