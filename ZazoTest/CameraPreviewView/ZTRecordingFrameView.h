//
//  ZTRecordingFrameView.h
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTRecordingFrameView : UIView

- (void) startShowingRecordingFrame;
- (void) stopShowingRecordingFrame;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
