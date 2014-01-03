//
//  WBSViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenTVViewController.h"

#import "WBSFantorangenEpisodeManager.h"
#import "WBSEpisode.h"
#import "NSMutableArray+WBSQueue.h"

static NSString *const kWBSAVPlayerViewControllerSegue = @"WBSAVPlayerViewControllerSegue";



@interface WBSFantorangenTVViewController () <WBSFantorangenEpisodeManagerDelegate>

@property (assign, nonatomic, getter = isFirstRun) BOOL firstRun;
@property (strong, nonatomic) WBSFantorangenEpisodeManager *episodeManager;
@property (strong, nonatomic) NSArray *episodes;
@property (strong, nonatomic) NSMutableDictionary *mutableEpisodeURLToEpisode;
@property (strong, nonatomic) NSMutableArray *episodeQueue;

@end



@implementation WBSFantorangenTVViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstRun = YES;
    self.AVPlayerViewController.delegate = self;
       
    WBSFantorangenEpisodeManager *episodeManager = [[WBSFantorangenEpisodeManager alloc] init];
    episodeManager.delegate = self;
    [episodeManager beginEpisodeUpdates];
    self.episodeManager = episodeManager;
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



- (void)episodeRefresh:(NSURL *)episodeURL
{
    WBSEpisode *episode = [self.episodeManager episodeForURL:episodeURL];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        [self.mutableEpisodeURLToEpisode setObject:episode forKey:episodeURL];
        
        [self.episodeQueue addObject:episode];
        if (self.isFirstRun) {
            [self startPlaying];
            self.firstRun = NO;
        }
    }
}

- (void)startPlaying
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    WBSEpisode *episode = [self.episodeQueue dequeue];
    NSString *episodeTitle = episode.title;
    self.title = episodeTitle;
    
    NSURL *videoURL = episode.videoURL;
    self.AVPlayerViewController.URL = videoURL;
    
    NSLog(@"%@ - %@", episodeTitle, videoURL);
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



#pragma mark - Getters

- (NSMutableArray *)episodeQueue
{
    if (_episodeQueue == nil) {
        self.episodeQueue = [[NSMutableArray alloc] init];
    }
    
    return _episodeQueue;
}

@end
