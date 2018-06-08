//
//  PingDefine.h
//  
//
//  Created by Phineas.Huang on 2018/6/7.
//  Copyright © 2018 sunxiaoshan. All rights reserved.
//

#ifndef PingDefine_h
#define PingDefine_h

typedef enum {
    didStart,
    didFailToSendPacket,
    didReceivePacket,
    didReceiveUnexpectedPacket,
    didTimeout,
    didError,
    didFinished,
} PingStatus;

#endif /* PingDefine_h */
