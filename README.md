# PingHostOnIPhone
Step 1: Add all of file in ./Service/Ping

Step 2: #import "PingService.h"

Step 3: Add code
```
self.pingService = [PingService start:host // host name
                                count:6 // ping count
                                block:^(PingItem *result) {
                         // call back result
                   }];
```

Check Status
```
typedef enum {
		didStart,
		didFailToSendPacket,
		didReceivePacket,
		didReceiveUnexpectedPacket,
		didTimeout,
		didError,
		didFinished,
} PingStatus;
```
