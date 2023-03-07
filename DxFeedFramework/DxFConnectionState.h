//
//  DxFConnectionState.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NotConnected = 0,
    Connecting,
    Connected,
    Disconnected,
} DxFConnectionState;
