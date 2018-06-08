//
//  ViewController.m
//  PingTest
//
//  Created by Phineas.Huang on 2018/6/8.
//  Copyright © 2018 Phineas. All rights reserved.
//

#import "ViewController.h"

#import "PingService.h"

@interface ViewController ()

@property (strong, nonatomic) PingService *pingService;
@property (weak, nonatomic) IBOutlet UITextField *textFieldHost;
@property (weak, nonatomic) IBOutlet UILabel *labelResultContent;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.textFieldHost setText:@"www.google.com"];
}

- (IBAction)actionPing:(id)sender {
    NSString *host = [self.textFieldHost text];
    static NSString *resultContent;
    resultContent = @"";
    self.pingService = [PingService start:host
                                    count:6
                                    block:^(PingItem *result) {
                                        switch (result.status) {
                                            case didTimeout:
                                            case didError:
                                                [self.labelResultContent setText:@"Error"];
                                                break;
                                            case didFinished:
                                                [self.labelResultContent setText:resultContent];
                                                break;
                                            default: {
                                                resultContent = [NSString stringWithFormat:@"%@ [%lf]", resultContent, result.timeMilliseconds];
                                            }
                                                break;
                                        }
                                    }];
}

@end
