//
//  NSString+CString.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CString)

- (nullable const char *)dxfCString;

+ (instancetype)newWithCstring:(const char *)nullTerminatedCString;

@end

NS_ASSUME_NONNULL_END
