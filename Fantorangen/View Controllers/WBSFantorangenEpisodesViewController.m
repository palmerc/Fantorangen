//
//  WBSFantorangenEpisodesViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodesViewController.h"

#import "WBSFantorangenEpisodeManager.h"
#import "WBSEpisode.h"
#import "WBSFantorangenEpisodeTableViewCell.h"

static NSString *const kFantorangenEpisodeViewControllerSegue = @"FantorangenEpisodeViewControllerSegue";


@interface WBSFantorangenEpisodesViewController () <WBSFantorangenEpisodeManagerDelegate>

@property (strong, nonatomic) WBSFantorangenEpisodeManager *episodeManager;

@property (assign, nonatomic, getter = isFirstRun) BOOL firstRun;
@property (strong, nonatomic) NSMutableDictionary *mutableEpisodeURLToEpisode;
@property (strong, nonatomic) NSMutableArray *episodeQueue;

@property (strong, nonatomic, readonly) NSArray *seasons;
@property (strong, nonatomic, readonly) NSArray *episodes;

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



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.seasons count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodes count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.seasons objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    
    WBSFantorangenEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    cell.episode = episode;
        
    return cell;
}



#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlightRow = NO;

    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        shouldHighlightRow = YES;
    }
    
    return shouldHighlightRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        // segue here
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    
    WBSFantorangenEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    cell.episode = episode;

    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;    
}



#pragma mark - WBSFantorangenEpisodeManagerDelegate

- (void)episodeRefresh:(NSURL *)episodeURL
{
    WBSEpisode *episode = [self.episodeManager episodeForURL:episodeURL];
    [self.mutableEpisodeURLToEpisode setObject:episode forKey:episodeURL];
    [self.tableView reloadData];
}



#pragma mark - Getters

- (NSMutableDictionary *)mutableEpisodeURLToEpisode
{
    if (_mutableEpisodeURLToEpisode == nil) {
        self.mutableEpisodeURLToEpisode = [[NSMutableDictionary alloc] init];
    }
    
    return _mutableEpisodeURLToEpisode;
}

- (NSArray *)seasons
{
    NSMutableSet *mutableSeasons = [[NSMutableSet alloc] init];
    for (WBSEpisode *episode in self.episodes) {
        [mutableSeasons addObject:episode.season];
    }
    
    NSArray *seasons = [[mutableSeasons allObjects] sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *season1 = obj1;
        NSString *season2 = obj2;
        return [season1 compare:season2 options:NSCaseInsensitiveSearch|NSNumericSearch];
    }];
    
    return seasons;
}

- (NSArray *)episodes
{
    NSArray *episodes = [[self.mutableEpisodeURLToEpisode allValues] sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        WBSEpisode *episode1 = obj1;
        WBSEpisode *episode2 = obj2;
        return [episode1.title compare:episode2.title options:NSCaseInsensitiveSearch|NSNumericSearch];
    }];
    
    return episodes;
}

- (NSMutableArray *)episodeQueue
{
    if (_episodeQueue == nil) {
        self.episodeQueue = [[NSMutableArray alloc] init];
    }
    
    return _episodeQueue;
}

@end
