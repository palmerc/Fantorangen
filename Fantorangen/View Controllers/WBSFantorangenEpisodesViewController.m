//
//  WBSFantorangenEpisodesViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodesViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "WBSFantorangenEpisodeManager.h"
#import "WBSProgramStorage.h"
#import "WBSSeason.h"
#import "WBSEpisode.h"
#import "WBSFantorangenEpisodesSectionTableViewCell+WBSSeason.h"
#import "WBSFantorangenEpisodeTableViewCell+WBSEpisode.h"
#import "WBSFantorangenEpisodeViewController.h"
#import "NSArray+RandomOrder.h"

static NSString *const kFantorangenEpisodeViewControllerSegue = @"FantorangenEpisodeViewControllerSegue";



@interface WBSFantorangenEpisodesViewController () <WBSFantorangenEpisodeManagerDelegate>

@property (strong, nonatomic) WBSFantorangenEpisodeManager *episodeManager;
@property (strong, nonatomic) WBSProgramStorage *programStorage;

@property (assign, nonatomic, getter = isFirstRun) BOOL firstRun;

@property (strong, nonatomic) NSDictionary *seasonsToEpisodes;
@property (strong, nonatomic) NSTimer *tableReloadTimer;

@end



@implementation WBSFantorangenEpisodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    self.title = NSLocalizedString(@"Episodes", @"Episodes");
    
    WBSFantorangenEpisodeManager *episodeManager = [[WBSFantorangenEpisodeManager alloc] init];
    episodeManager.delegate = self;
    [episodeManager beginEpisodeUpdates];
    self.episodeManager = episodeManager;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kFantorangenEpisodeViewControllerSegue]) {
        WBSFantorangenEpisodeViewController *fantorangenEpisodeViewController = segue.destinationViewController;

        NSArray *episodeQueue = nil;
        if ([sender isKindOfClass:[WBSEpisode class]]) {
            WBSEpisode *episode = sender;
            episodeQueue = [self episodeQueueFromEpisode:episode randomized:NO];
        } else if ([sender isKindOfClass:[NSArray class]]) {
            episodeQueue = sender;
        }
        
        fantorangenEpisodeViewController.episodeQueue = episodeQueue;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sectionCount = [self.programStorage.seasons count];

    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WBSSeason *season = [self.programStorage.seasons objectAtIndex:section];
    NSUInteger rowCount = [[self.programStorage episodesForSeason:season] count];

    return rowCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WBSEpisode *episode = [self.programStorage.episodes firstObject];

    WBSFantorangenEpisodesSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWBSFantorangenEpisodesSectionTableViewCellReuseIdentifier];
    [cell setSeason:episode.season];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBSEpisode *episode = [self episodeForIndexPath:indexPath];
    
    WBSFantorangenEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    [cell setEpisode:episode visibility:YES];
        
    return cell;
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath
{
    WBSFantorangenEpisodeTableViewCell *episodeTableViewCell = (WBSFantorangenEpisodeTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (episodeTableViewCell == nil) {
        if (self.tableReloadTimer == nil || [self.tableReloadTimer isValid]) {
            [self.tableReloadTimer invalidate];
            self.tableReloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(forceTableViewReload) userInfo:nil repeats:NO];
        }
    }
}

- (void)forceTableViewReload
{
    self.tableReloadTimer = nil;
    [self.tableView reloadData];
}



#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlightRow = NO;

    WBSEpisode *episode = [self episodeForIndexPath:indexPath];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        shouldHighlightRow = YES;
    }
    
    return shouldHighlightRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WBSEpisode *episode = [self episodeForIndexPath:indexPath];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        [self performSegueWithIdentifier:kFantorangenEpisodeViewControllerSegue sender:episode];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    WBSEpisode *episode = [self.programStorage.episodes firstObject];
    
    WBSFantorangenEpisodesSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWBSFantorangenEpisodesSectionTableViewCellReuseIdentifier];
    [cell setSeason:episode.season];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBSEpisode *episode = [self episodeForIndexPath:indexPath];
    
    WBSFantorangenEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    [cell setEpisode:episode visibility:NO];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;    
}



#pragma mark - WBSFantorangenEpisodeManagerDelegate

- (void)episodeRefresh:(NSURL *)episodeURL
{
    WBSEpisode *episode = [self.episodeManager episodeForURL:episodeURL];

    [self.programStorage addEpisode:episode];
    [self.tableView reloadData];
}



#pragma mark - IBActions

- (IBAction)didPressShuffleButton:(id)sender
{
//    NSArray *randomizedEpisodes = [[self episodes] randomOrder]
//    ;
//    [self performSegueWithIdentifier:kFantorangenEpisodeViewControllerSegue sender:randomizedEpisodes];
}



#pragma mark - Getters

- (WBSProgramStorage *)programStorage
{
    if (_programStorage == nil) {
        self.programStorage = [[WBSProgramStorage alloc] init];
    }

    return _programStorage;
}

- (NSIndexPath *)indexPathForEpisode:(WBSEpisode *)episode
{
    NSIndexPath *indexPath = nil;

    WBSSeason *season = episode.season;
    NSInteger section = [self.programStorage.seasons indexOfObject:season];
    NSArray *episodes = [self.programStorage episodesForSeason:season];
    NSInteger row = [episodes indexOfObject:episode];

    if (section != NSNotFound && row != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    }
    
    return indexPath;
}

- (WBSEpisode *)episodeForIndexPath:(NSIndexPath *)indexPath
{
    WBSSeason *season = [self.programStorage.seasons objectAtIndex:indexPath.section];
    WBSEpisode *episode = [[self.programStorage episodesForSeason:season] objectAtIndex:indexPath.row];

    return episode;
}

- (NSArray *)episodeQueueFromEpisode:(WBSEpisode *)episode randomized:(BOOL)shuffle
{
    NSArray *episodes = nil; //[self episodes];
    NSUInteger index = [episodes indexOfObject:episode];
    NSRange range = NSMakeRange(index, [episodes count] - index);
    return [episodes subarrayWithRange:range];
}


@end
