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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static NSString *const kHockeySDKBetaKey = @"960b7c9d44b074ccb2b518fe87a8f5b7";
static NSString *const kNewRelicSDKKey = @"AAec230ed311d007bb190cb88a5e5ab2afcbff61e5";



@implementation WBSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [Fabric with:@[CrashlyticsKit]];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
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

@end
