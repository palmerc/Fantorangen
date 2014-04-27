//
//  Fantorangen_Tests.m
//  Fantorangen Tests
//
//  Created by Cameron Palmer on 23.02.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WBSAVPlayer.h"

static NSString *const kTestVideo = @"http://samples.mplayerhq.hu/MPEG-4/video.mp4";



@interface WBSAVPlayerTests : XCTestCase
@property (assign, nonatomic, getter = isBlocking) BOOL block;
@property (strong, nonatomic) WBSAVPlayer *AVPlayer;
@end



@implementation WBSAVPlayerTests

- (void)setUp
{
    [super setUp];

    WBSAVPlayer *AVPlayer = [[WBSAVPlayer alloc] init];
    [AVPlayer setMediaURL:[NSURL URLWithString:kTestVideo]];
    self.AVPlayer = AVPlayer;
}

- (void)tearDown
{
    [super tearDown];

    [self.AVPlayer stop];
    self.AVPlayer = nil;
}

- (void)testDuration
{
    self.block = YES;
    [self.AVPlayer play];

    NSTimeInterval duration = [self.AVPlayer duration];
    NSLog(@"Duration %f", duration);

    NSRunLoop *theRL = [NSRunLoop currentRunLoop];

    while (self.isBlocking && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        NSLog(@"Blocking.");
    }

}

@end
