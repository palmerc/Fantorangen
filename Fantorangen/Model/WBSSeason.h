//
//  WBSSeason.h
//  Fantorangen
//
//  Created by Cameron Palmer on 08.06.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface WBSSeason : NSObject <NSCoding>

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *seasonDescription;

@end
