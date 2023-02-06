//
//  DXFEventQuote+Graal.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import <DXFFramework/DXFFramework.h>
#import "dxfg_events.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFEventQuote (Graal)

- (instancetype)initWithQuote:(dxfg_quote_t *)pEvent;

@end

NS_ASSUME_NONNULL_END
