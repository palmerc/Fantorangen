//
//  WBSWebViewOperation.h
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBSWebViewOperationDelegate;



@interface WBSFantorangenWebViewOperation : NSOperation

@property (weak, nonatomic) id <WBSWebViewOperationDelegate> delegate;
@property (copy, nonatomic) NSURL *episodeURL;
@property (copy, nonatomic, readonly) NSURL *videoURL;

- (id)initWithURL:(NSURL *)episodeURL;

@end



@protocol WBSWebViewOperationDelegate <NSObject>
@optional
- (void)webViewOperationDidFinish:(WBSFantorangenWebViewOperation *)webViewOperation;

@end