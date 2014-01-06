//
//  WBSViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodeViewController.h"

#import "WBSFantorangenEpisodeManager.h"
#import "WBSEpisode.h"
#import "NSMutableArray+WBSQueue.h"

static NSString *const kWBSAVPlayerViewControllerSegue = @"WBSAVPlayerViewControllerSegue";



@interface WBSFantorangenEpisodeViewController () <WBSFantorangenEpisodeManagerDelegate>

@end



@implementation WBSFantorangenEpisodeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.AVPlayerViewController.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kWBSAVPlayerViewControllerSegue]) {
        self.AVPlayerViewController = segue.destinationViewController;

        [self addChildViewController:self.AVPlayerViewController];
        ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
        [segue.destinationViewController didMoveToParentViewController:self];
        
    }
}



- (void)startPlaying
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

//    WBSEpisode *episode = [self.episodeQueue dequeue];
//    NSString *episodeTitle = episode.title;
//    self.title = episodeTitle;
//    
//    NSURL *videoURL = episode.videoURL;
//    self.AVPlayerViewController.URL = videoURL;
    
//    NSLog(@"%@ - %@", episodeTitle, videoURL);
}



#pragma mark - WBSAVPlayerViewControllerDelegate
- (void)playerItemReadyToPlay:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [self.AVPlayerViewController play:self];
}

- (void)playerItemDidReachEnd:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [self startPlaying];
}

@end
