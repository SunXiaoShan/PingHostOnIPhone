//
//  PingService.h
//
//
//  Created by Phineas.Huang on 2018/6/7.
//  Copyright © 2018 sunxiaoshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PingItem.h"

typedef void (^PingBlock)(PingItem *);

@interface PingService : NSObject

+ (PingService *)start:(NSString *)hostName
                 count:(NSInteger)count
                 block:(PingBlock)block;

@end
