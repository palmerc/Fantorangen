//
//  NSMutableArray+WBSQueue.h
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSMutableArray (WBSFIFOQueue)

- (void)enqueue:(id)object;
- (id)dequeue;

@end
