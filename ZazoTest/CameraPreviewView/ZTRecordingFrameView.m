//
//  ZTRecordingFrameView.m
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import "ZTRecordingFrameView.h"
#import "ZTVideoUtils.h"

@interface ZTRecordingFrameView()
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int totalSeconds;
@end

@implementation ZTRecordingFrameView

- (void) awakeFromNib {
    self.alpha = 0.0f;
    self.layer.borderColor = [[UIColor redColor] CGColor];
    self.layer.borderWidth = 5.0;
}

- (void) startShowingRecordingFrame {
    
    self.totalSeconds = 0;
    [self handleTimerUpdated];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0f;
    }];
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(handleTimerUpdated) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void) stopShowingRecordingFrame {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0f;
    }];
    
    [self.timer invalidate];
}

- (void) handleTimerUpdated {
    self.totalSeconds ++;
    self.timeLabel.text = [ZTVideoUtils timeFormatted:self.totalSeconds];
}

@end
