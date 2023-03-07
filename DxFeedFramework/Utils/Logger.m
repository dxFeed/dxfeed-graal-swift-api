//
//  Logger.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import "Logger.h"

@implementation Logger

+ (void)print:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

@end
