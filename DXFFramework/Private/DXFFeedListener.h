//
//  DXFFeedListener.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#ifndef DXFFeedListener_h
#define DXFFeedListener_h

@class DXFEventQuote;

@protocol DXFFeedListener

- (void)receivedEventQuote:(DXFEventQuote *)event;

@end
#endif /* DXFFeedListener_h */
