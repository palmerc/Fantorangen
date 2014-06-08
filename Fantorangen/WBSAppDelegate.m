//
//  WBSAppDelegate.m
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <HockeySDK/HockeySDK.h>
#import <NewRelicAgent/NewRelic.h>

static NSString *const kHockeySDKBetaKey = @"960b7c9d44b074ccb2b518fe87a8f5b7";
static NSString *const kNewRelicSDKKey = @"AAc5e4ecfc6e24d94b50e23eba991902aa6df41435";



@implementation WBSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [application beginReceivingRemoteControlEvents];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeySDKBetaKey];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [NewRelicAgent startWithApplicationToken:kNewRelicSDKKey];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    DDLogVerbose(@"%s - %@", __PRETTY_FUNCTION__, event);
    if ( event.type == UIEventTypeRemoteControl ) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
//                [[NSBPPlayer sharedPlayer] resume];
                break;
            case UIEventSubtypeRemoteControlPause:
//                [[NSBPPlayer sharedPlayer] pause];
                break;
            case UIEventSubtypeRemoteControlStop:
//                [[NSBPPlayer sharedPlayer] stop];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [[NSBPPlayer sharedPlayer] playOrPause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
//                [[NSBPPlayer sharedPlayer] skipToNextTrack];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
//                [[NSBPPlayer sharedPlayer] skipToPreviousTrack];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
//                [[NSBPPlayer sharedPlayer] beginSeekReverse];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
//                [[NSBPPlayer sharedPlayer] endSeekReverse];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
//                [[NSBPPlayer sharedPlayer] beginSeekForward];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
//                [[NSBPPlayer sharedPlayer] endSeekForward];
                break;
            default:
                break;
        }
    }
}


#pragma mark - Appearance Proxy Setup

- (void)appearanceProxySetup
{
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : titleFont}];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}



#pragma mark - Update the Settings Bundle

- (void)updateVersionBuildStringInSettingsBundle
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}


@end
