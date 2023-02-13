//
//  DXFFeedListener.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#ifndef DXFFeedListener_h
#define DXFFeedListener_h

@class DXFEventQuote;

@protocol DXFEventListener

- (void)receivedEvents:(dxfg_event_type_list *)events;

@end
#endif /* DXFFeedListener_h */
