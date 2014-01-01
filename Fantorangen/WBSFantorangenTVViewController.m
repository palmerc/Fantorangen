//
//  WBSViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenTVViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "WBSFantorangenEpisodeManager.h"
#import "WBSEpisode.h"
#import "NSMutableArray+WBSQueue.h"



@interface WBSFantorangenTVViewController () <WBSFantorangenEpisodeManagerDelegate>

@property (assign, nonatomic, getter = isFirstRun) BOOL firstRun;
@property (strong, nonatomic) WBSFantorangenEpisodeManager *episodeManager;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:@"MPMoviePlayerLoadStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:@"MPMoviePlayerPlaybackDidFinishNotification" object:nil];
    
    MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] init];
    moviePlayerController.allowsAirPlay = YES;
    moviePlayerController.movieSourceType = MPMovieSourceTypeStreaming;
    moviePlayerController.view.frame = self.view.bounds;
    [self.view addSubview:moviePlayerController.view];
    self.moviePlayerController = moviePlayerController;
    
    WBSFantorangenEpisodeManager *episodeManager = [[WBSFantorangenEpisodeManager alloc] init];
    episodeManager.delegate = self;
    [episodeManager beginEpisodeUpdates];
    self.episodeManager = episodeManager;
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
    [self.moviePlayerController stop];
    WBSEpisode *episode = [self.episodeQueue dequeue];
    NSString *episodeTitle = episode.title;
    self.title = episodeTitle;
    
    NSURL *videoURL = episode.videoURL;
    self.moviePlayerController.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayerController.contentURL = videoURL;
    [self.moviePlayerController prepareToPlay];
    
    NSLog(@"%@ - %@", episodeTitle, videoURL);
}



- (void)loadStateDidChange:(id)sender
{
    if ((self.moviePlayerController.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable ||
        (self.moviePlayerController.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK) {
        [self.moviePlayerController play];
    }
}



#pragma mark - MPMoviePlayerPlaybackDidFinishNotification callback

- (void)playbackStateDidChange:(id)sender
{
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSNotification *concreteNotification = sender;
        NSDictionary *userInfo = [concreteNotification userInfo];
        NSInteger finishReason = [[userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
        if (finishReason == MPMovieFinishReasonPlaybackEnded) {
            if ([self.episodeQueue count] > 0) {
                [self startPlaying];
            }
        }
    }
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
