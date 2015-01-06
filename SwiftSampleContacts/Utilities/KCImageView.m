//
//  KCImageView.m
//  SwiftSampleContacts
//
//  Created by Dexter Kim on 2014-12-22.
//  Copyright (c) 2014 DexMobile. All rights reserved.
//

#import "KCImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation KCImageView

- (void)basicSetting
{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = true;
    self.layer.borderWidth = 0;
}

- (void)setImageWithString:(NSString *)string {
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 8.0f / 65.0f;
    label.font = [UIFont systemFontOfSize:CGRectGetWidth(self.bounds) * 0.5];
    [view addSubview:label];
    
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    
    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([words count]) {
        NSString *firstWord = words[0];
        if ([firstWord length]) {
            [displayString appendString:[firstWord substringWithRange:NSMakeRange(0, 1)]];
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = words[[words count] - 1];
            if ([lastWord length]) {
                [displayString appendString:[lastWord substringWithRange:NSMakeRange(0, 1)]];
            }
        }
    }
    label.text = [displayString uppercaseString];
    
    view.backgroundColor = [UIColor darkGrayColor];
    
    self.image = [self imageSnapshotFromView:view];
}

- (UIImage *)imageSnapshotFromView:(UIView *)inputView {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = self.bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw)
    {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -self.bounds.origin.x, -self.bounds.origin.y);
    
    [inputView.layer renderInContext:context];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

@end
