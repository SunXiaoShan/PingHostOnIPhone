//
//  PingService.m
//  
//
//  Created by Phineas.Huang on 2018/6/7.
//  Copyright © 2018 sunxiaoshan. All rights reserved.
//

#import "PingService.h"
#import "SimplePing.h"

#define TAG @"PingService"

@interface PingService()<SimplePingDelegate>

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) NSInteger count;
@property (nonatomic, strong) PingBlock block;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_source_t queueTimer;

@end

@implementation PingService

#pragma mark - public function

+ (PingService *)start:(NSString *)hostName
                 count:(NSInteger)count
                 block:(PingBlock)block {
    return [[PingService alloc] initWithHostName:hostName
                                           count:count
                                           block:block];
}

#pragma mark - private function

- (instancetype)initWithHostName:(NSString *)hostName
                           count:(NSInteger)count
                           block:(PingBlock)block {
    self = [super init];
    if (self) {
        self.hostName = hostName;
        self.count = count;
        self.pinger = [[SimplePing alloc] initWithHostName:hostName];
        self.pinger.delegate = self;
        [self.pinger start];
        self.block = block;

        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (void)stop {
    NSLog(@"%@ - stop", TAG);
    [self clean:didFinished];
}

- (void)timeout {
    NSLog(@"%@ - timeout", TAG);
    [self clean:didTimeout];
}

- (void)failed {
    NSLog(@"%@ - failed", TAG);
    [self clean:didError];
}

- (void)clean:(PingStatus)status {
    PingItem *result = [self getResultItem:status];
    NSLog(@"%@ - clean : [%d] %@", TAG, status, [PingItem parseStatus:status]);
    if (self.block) {
        __weak PingService *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.block(result);
        });
    }

    if (self.pinger) {
        [self.pinger stop];
        self.pinger = nil;
    }

    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }

    [self cancelQueueTimer];

    self.hostName = nil;
    self.startDate = nil;
}

- (PingItem *)getResultItem:(PingStatus)status {
    PingItem *item = [PingItem new];
    [item setHostName:self.hostName];
    [item setStatus:status];
    return item;
}

- (void)sendPing {
    __weak PingService *weakSelf = self;
    dispatch_async(self.queue, ^{
        if (weakSelf.count < 1) {
            [weakSelf stop];
            return;
        }
        weakSelf.count -= 1;
        weakSelf.startDate = [NSDate new];
        [weakSelf.pinger sendPingWithData:nil];

        [weakSelf setupTimeoutTimer];
    });
}

- (void)cancelQueueTimer {
    if (self.queueTimer) {
        dispatch_source_cancel(self.queueTimer);
        self.queueTimer = nil;
    }
}

- (void)setupTimeoutTimer {
    if (self.queueTimer == nil) {
        double timeout = 1.0f;
        self.queueTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        dispatch_source_set_timer(self.queueTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC),
                                  DISPATCH_TIME_FOREVER, 0);

        __weak PingService *weakSelf = self;
        dispatch_source_set_event_handler(self.queueTimer, ^{
            [weakSelf timeout];
            [weakSelf cancelQueueTimer];
        });
        dispatch_resume(self.queueTimer);
    }
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger
didStartWithAddress:(NSData *)address {
    NSLog(@"%@ - start ping : %@", TAG, self.hostName);
    [self sendPing];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4f
                                           target:self
                                          selector:@selector(sendPing)
                                           userInfo:nil
                                             repeats:YES];

    PingItem *result = [self getResultItem:didStart];
    if (self.block) {
        __weak PingService *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.block(result);
        });
    }
}

- (void)simplePing:(SimplePing *)pinger
  didFailWithError:(NSError *)error {
    [self cancelQueueTimer];
    [self failed];
}

- (void)simplePing:(SimplePing *)pinger
didFailToSendPacket:(NSData *)packet
    sequenceNumber:(uint16_t)sequenceNumber
             error:(NSError *)error {
    [self cancelQueueTimer];
    NSLog(@"%@ - %@ %d send failed : %@",
          TAG,
          self.hostName,
          sequenceNumber,
          error .description
          );
    [self failed];
}

- (void)simplePing:(SimplePing *)pinger
didReceivePingResponsePacket:(NSData *)packet
    sequenceNumber:(uint16_t)sequenceNumber {
    [self cancelQueueTimer];

    double timeMilliseconds = [[NSDate new] timeIntervalSinceDate:self.startDate] * 1000;
    NSLog(@"%@ - timeMilliseconds : %lf", TAG, timeMilliseconds);

    PingItem *result = [self getResultItem:didReceivePacket];
    [result setTimeMilliseconds:timeMilliseconds];
    if (self.block) {
        __weak PingService *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.block(result);
        });
    }
}

- (void)simplePing:(SimplePing *)pinger
didReceiveUnexpectedPacket:(NSData *)packet {
    [self cancelQueueTimer];
}

@end
