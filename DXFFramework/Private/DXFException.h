//
//  DXFException.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>
#import <DXFFramework/DXFControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFException : NSObject <DXFControl>

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *stackTrace;

@end

NS_ASSUME_NONNULL_END
