//
//  WBSFantorangenEpisodeManager.m
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodeManager.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <hpple/TFHpple.h>

#import "WBSSeason.h"
#import "WBSEpisode.h"
#import "WBSFantorangenWebViewOperation.h"

static NSString *const kNRKBaseURLString = @"http://tv.nrk.no";
static NSString *const kFantorangenSeries = @"/serie/fantorangen";
static NSString *const kClientUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B554a";



@interface WBSFantorangenEpisodeManager () <WBSWebViewOperationDelegate>
@property (strong, nonatomic) NSURL *NRKTVURL;
@property (strong, nonatomic) NSMutableDictionary *mutableEpisodeURLToEpisode;
@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

@end



@implementation WBSFantorangenEpisodeManager

- (id)init
{
    self = [super init];
    if (self != nil) {
        _NRKTVURL = [NSURL URLWithString:kNRKBaseURLString];
        
        AFHTTPRequestOperationManager *requestOperationManager = [AFHTTPRequestOperationManager manager];
        
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:kClientUserAgent forHTTPHeaderField:@"User-Agent"];
        requestOperationManager.requestSerializer = requestSerializer;
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        requestOperationManager.responseSerializer = responseSerializer;
        self.requestOperationManager = requestOperationManager;
    }
    
    return self;
}

- (void)beginEpisodeUpdates
{
    NSURL *fantorangenURL = [NSURL URLWithString:[kNRKBaseURLString stringByAppendingString:kFantorangenSeries]];
    [self.requestOperationManager GET:[fantorangenURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *HTMLData = responseObject;
            TFHpple *document = [[TFHpple alloc] initWithHTMLData:HTMLData];
            NSArray *elements = [document searchWithXPathQuery:@"//a[contains(@class, 'season-link') and contains(@class, 'buttonbar-link')]"];
            
            [self processSeasonElements:elements];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

- (void)processSeasonElements:(NSArray *)elements
{
    for (TFHppleElement *element in elements) {
        NSString *episodesLink = [element objectForKey:@"href"];
        NSURL *FantorangenEpisodesURL = [NSURL URLWithString:[kNRKBaseURLString stringByAppendingString:episodesLink]];
        [self.requestOperationManager GET:[FantorangenEpisodesURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                NSData *HTMLData = responseObject;
                TFHpple *document = [[TFHpple alloc] initWithHTMLData:HTMLData];
                NSArray *episodeElements = [document searchWithXPathQuery:@"//ul[contains(@class, 'episode-list')]/li[contains(@class, 'episode-item')]"];
                for (TFHppleElement *episodeElement in episodeElements) {
                    NSDictionary *attributes = [episodeElement attributes];
                    NSString *episodeIdentifier = [attributes objectForKey:@"data-episode"];
                    TFHppleElement *episodeLinkTag = [episodeElement firstChildWithTagName:@"a"];
                    TFHppleElement *airElement = [episodeLinkTag firstChildWithClassName:@"air"];

                    TFHppleElement *headingElement = [airElement firstChildWithClassName:@"episode-list-title"];
                    NSString *title = [headingElement text];

                    TFHppleElement *seasonTag = [[headingElement childrenWithClassName:@"season-name"] firstObject];
                    NSString *episodeRelativeURLString = [episodeLinkTag objectForKey:@"href"];
                    
                    NSRange episodeNumberStartRange = [title rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:0];
                    NSRange episodeNumberEndRange = [title rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] options:0];
                    NSInteger length = episodeNumberEndRange.location - episodeNumberStartRange.location;
                    NSRange episodeNumberRange = NSMakeRange(episodeNumberStartRange.location, length);
                    
                    NSString *episodeNumber = [title substringWithRange:episodeNumberRange];
                    
                    NSRange seriesTitleRange = NSMakeRange(0, episodeNumberStartRange.location);
                    NSString *seriesTitle = [[title substringWithRange:seriesTitleRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *seasonString = [[seasonTag text] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
                    
                    NSArray *descriptionElements = [[airElement firstChildWithClassName:@"description"] children];
                    NSMutableArray *descriptionComponents = [[NSMutableArray alloc] initWithCapacity:[descriptionElements count]];
                    
                    for (TFHppleElement *descriptionElement in descriptionElements) {
                        [descriptionComponents addObject:[descriptionElement text]];
                    }
                    NSString *description = [descriptionComponents componentsJoinedByString:@" "];
                    
                    NSArray *divs = [airElement childrenWithTagName:@"div"];
                    NSString *transmissionInformation = nil;
                    WBSEpisodeAvailability availability = kWBSEpisodeAvailabilityUnavailable;
                    for (TFHppleElement *div in divs) {
                        NSString *class = [[div attributes] objectForKey:@"class"];
                        
                        if ([class rangeOfString:@"transmission-info"].location != NSNotFound) {
                            transmissionInformation = [div text];
                        } else if ([class rangeOfString:@"availability"].location != NSNotFound) {
                            if ([[div text] isEqualToString:@"Alltid på nett"]) {
                                availability = kWBSEpisodeAvailabilityAvailable;
                            }
                        }
                    }

                    WBSSeason *season = [[WBSSeason alloc] init];
                    season.identifier = seasonString;
                    season.seriesTitle = seriesTitle;
                    season.seasonDescription = seasonString;
                    
                    WBSEpisode *episode = [[WBSEpisode alloc] init];
                    episode.identifier = episodeIdentifier;
                    episode.episodeURL = [NSURL URLWithString:episodeRelativeURLString relativeToURL:self.NRKTVURL];
                    episode.season = season;
                    episode.episodeNumber = episodeNumber;
                    episode.seriesTitle = seriesTitle;
                    episode.episodeTitle = title;
                    episode.summary = description;
                    episode.transmissionInformation = transmissionInformation;
                    episode.availability = availability;
                    
                    NSURL *episodeURL = episode.episodeURL;
                    if (episodeURL != nil) {
                        [self.mutableEpisodeURLToEpisode setObject:episode forKey:episode.episodeURL];
                    }
                }
                
                [self fetchVideoURLs];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"%@", error);
        }];
    }
}

- (void)fetchVideoURLs
{
    NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
    for (WBSEpisode *episode in self.episodes) {
        WBSFantorangenWebViewOperation *webViewOperation = [[WBSFantorangenWebViewOperation alloc] initWithURL:episode.episodeURL];
        webViewOperation.delegate = self;
        [operationQueue addOperation:webViewOperation];
    }
}



#pragma mark - WBSWebViewOperationDelegate methods 

- (void)webViewOperationDidFinish:(WBSFantorangenWebViewOperation *)webViewOperation
{
    WBSEpisode *episode = [self.episodeURLToEpisode objectForKey:webViewOperation.episodeURL];
    episode.videoURL = webViewOperation.videoURL;
    episode.posterURL = webViewOperation.posterURL;

    if ([self.delegate respondsToSelector:@selector(episodeRefresh:)]) {
        [self.delegate episodeRefresh:webViewOperation.episodeURL];
    }
}



#pragma mark - Getters

- (NSArray *)episodes
{
    return [self.episodeURLToEpisode allValues];
}

- (NSMutableDictionary *)mutableEpisodeURLToEpisode
{
    if (_mutableEpisodeURLToEpisode == nil) {
        self.mutableEpisodeURLToEpisode = [[NSMutableDictionary alloc] init];
    }
    
    return _mutableEpisodeURLToEpisode;
}

- (NSDictionary *)episodeURLToEpisode
{
    return [self.mutableEpisodeURLToEpisode copy];
}

- (WBSEpisode *)episodeForURL:(NSURL *)episodeURL
{
    return [self.mutableEpisodeURLToEpisode objectForKey:episodeURL];
}

@end
