//
//  Utils.h
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+(UIColor *)colorFromHex:(NSString *)hex;
+(UIFont *)getMainFontWithSize:(CGFloat)size;
+(UIFont *)getMainFontBoldWithSize:(CGFloat)size;

@end
