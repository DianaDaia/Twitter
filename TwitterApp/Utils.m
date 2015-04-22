//
//  Utils.m
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(UIColor *)colorFromHex:(NSString *)hex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIFont *)getMainFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AmericanTypewriter" size:size];
}

+(UIFont *)getMainFontBoldWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AmericanTypewriter-Bold" size:size];
}


@end
