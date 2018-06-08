//
//  PingItem.h
//  
//
//  Created by Phineas.Huang on 2018/6/7.
//  Copyright © 2018 sunxiaoshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PingDefine.h"

@interface PingItem : NSObject

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic) double timeMilliseconds;
@property (nonatomic) PingStatus status;

+ (NSString *)parseStatus:(PingStatus)status;

@end
