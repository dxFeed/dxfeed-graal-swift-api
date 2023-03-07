//
//  NSString+CString.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import "NSString+CString.h"

@implementation NSString (CString)

- (nullable const char *)dxfCString {
    return [self cStringUsingEncoding:NSUTF8StringEncoding];
}

+ (instancetype)newWithCstring:(const char *)nullTerminatedCString {
    if (nullTerminatedCString) {
        return [[NSString alloc] initWithCString:nullTerminatedCString encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

@end
