//
//  WBSWebViewOperation.m
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenWebViewOperation.h"



@interface WBSFantorangenWebViewOperation () <UIWebViewDelegate>
@property (strong, nonatomic) NSDate *startTime;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (copy, nonatomic, readwrite) NSURL *videoURL;
@property (copy, nonatomic, readwrite) NSURL *posterURL;

@property (strong, nonatomic) UIWebView *webView;

@end



@implementation WBSFantorangenWebViewOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (id)init
{
    self = [super init];
    if (self) {
        _finished = NO;
        _executing = NO;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)episodeURL
{
    self = [self init];
    if (self != nil) {
        _episodeURL = episodeURL;
    }
    
    return self;
}

- (void)start
{
    if (![self isCancelled]) {
        self.executing = YES;
        
        [self performSelector:@selector(main) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    } else {
        self.finished = YES;
    }
}

- (void)main
{
    if (self.episodeURL != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.episodeURL];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView.delegate = self;
        [webView loadRequest:request];
        
        self.webView = webView;
    }
}



#pragma mark - NSOperation methods

- (BOOL)isConcurrent
{
    return YES;
}

- (void)setExecuting:(BOOL)executing
{
    NSString *isExecuting = NSStringFromSelector(@selector(isExecuting));
    [self willChangeValueForKey:isExecuting];
    _executing = executing;
    [self didChangeValueForKey:isExecuting];
}

- (void)setFinished:(BOOL)finished
{
    NSString *isFinished = NSStringFromSelector(@selector(isFinished));
    [self willChangeValueForKey:isFinished];
    _finished = finished;
    [self didChangeValueForKey:isFinished];
}

- (void)completeOperation
{
    NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:self.startTime];
    DDLogDebug(@"Download complete in %f seconds - %@", executionTime, self.episodeURL);

    self.webView = nil;
    self.executing = NO;
    self.finished = YES;
}

- (void)cancel
{
    [self.webView stopLoading];
    [super cancel];
    [self completeOperation];
}



#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLogDebug(@"Download start - %@", self.episodeURL);
    self.startTime = [NSDate date];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogDebug(@"%s - %@", __PRETTY_FUNCTION__, self.episodeURL);
    NSString *episodeVideoURLString = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('playerelement').getAttribute('data-media')"];
    NSURL *episodeVideoURL = [NSURL URLWithString:episodeVideoURLString];
    if (episodeVideoURL == nil) {
        DDLogError(@"Episode video URL is nil, %@", self.episodeURL);
    }
    self.videoURL = episodeVideoURL;
    
    NSString *episodePosterURLString = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('html5-video').getAttribute('poster')"];
    NSURL *episodePosterURL = [NSURL URLWithString:episodePosterURLString];
    if (episodePosterURL == nil) {
        DDLogError(@"Episode poster URL is nil, %@", self.episodeURL);
    }
    self.posterURL = episodePosterURL;
    
    if ([self.delegate respondsToSelector:@selector(webViewOperationDidFinish:)]) {
        [self.delegate webViewOperationDidFinish:self];
    }

    [self completeOperation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogError(@"%@", error);
    [self cancel];
}

@end
