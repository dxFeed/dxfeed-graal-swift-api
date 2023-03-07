//
//  DxFSubscriptionListener.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 13.02.2023.
//

#ifndef DxFSubscriptionListener_h
#define DxFSubscriptionListener_h

@class DxFEVent;
@protocol DxFSubscriptionListener

- (void)receivedEvents:(NSArray<DxFEvent *> *)events;

@end

#endif /* DxFSubscriptionListener_h */
