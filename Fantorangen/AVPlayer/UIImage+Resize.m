//
//  UIImage+Resize.m
//  Fantorangen
//
//  Created by Cameron Palmer on 14.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "UIImage+Resize.h"



@implementation UIImage (Resize)

- (UIImage *)imageScaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
