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
@property (strong, nonatomic) NSMutableArray *mutableEpisodeQueue;

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
    [self startPlaying];
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

    WBSEpisode *episode = [self.mutableEpisodeQueue dequeue];
    if (episode == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (episode.availability == kWBSEpisodeAvailabilityUnavailable) {
        [self startPlaying];
    } else {
        NSString *episodeTitle = episode.episodeTitle;
        self.title = episodeTitle;
        
        NSURL *videoURL = episode.videoURL;
        self.AVPlayerViewController.URL = videoURL;
        
        NSLog(@"%@ - %@", episodeTitle, videoURL);
    }
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



#pragma mark - Getters/Setters

- (NSArray *)episodeQueue
{
    return [self.mutableEpisodeQueue copy];
}

- (void)setEpisodeQueue:(NSArray *)episodeQueue
{
    _mutableEpisodeQueue = [episodeQueue mutableCopy];
}

@end
