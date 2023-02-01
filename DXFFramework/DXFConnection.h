//
//  DXFConnection.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>
#import "DXFControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFConnection : NSObject <DXFControl>

- (BOOL)connect:(nonnull NSString *)address;

@end

NS_ASSUME_NONNULL_END
