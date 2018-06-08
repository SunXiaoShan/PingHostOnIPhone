//
//  PingItem.m
//
//
//  Created by Phineas.Huang on 2018/6/7.
//  Copyright © 2018 sunxiaoshan. All rights reserved.
//

#import "PingItem.h"

@implementation PingItem

+ (NSString *)parseStatus:(PingStatus)status {
    switch (status) {
        case didStart:
            return @"didStart";
        case didFailToSendPacket:
            return @"didFailToSendPacket";
        case didReceivePacket:
            return @"didReceivePacket";
        case didReceiveUnexpectedPacket:
            return @"didReceiveUnexpectedPacket";
        case didTimeout:
            return @"didTimeout";
        case didError:
            return @"didError";
        case didFinished:
            return @"didFinished";
        default:
            return @"";
    }
}

@end
