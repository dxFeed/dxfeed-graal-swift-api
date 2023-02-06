//
//  DXFEventQuote+Graal.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import "DXFEventQuote+Graal.h"
#import "DXFEventQuote+Private.h"
#import "DXFEvent+Private.h"

@implementation DXFEventQuote (Graal)

- (instancetype)initWithQuote:(dxfg_quote_t *)dxf_item {
    if (self = [super init]) {        
        self.event_symbol = @"adsas";
        self.ask_time = @"asd";
    }
    return self;
}
@end
