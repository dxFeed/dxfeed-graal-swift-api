//
//  DXFFeed.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFConnection, DXFEnvironment, DXFEventQuote;

@interface DXFFeed : NSObject

@property (nonatomic, retain, readonly) id values;

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env;

- (BOOL)load;

- (void)getFeedForSymbol:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
