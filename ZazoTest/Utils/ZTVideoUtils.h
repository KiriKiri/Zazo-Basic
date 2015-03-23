//
//  ZTVideoUtils.h
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface ZTVideoUtils : NSObject
+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position;
+ (UIAlertView *)alertWithTitle:(NSString*)title message:(NSString*)message;
+ (NSString *)timeFormatted:(int)totalSeconds;
@end
