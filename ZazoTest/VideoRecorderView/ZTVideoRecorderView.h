//
//  ZTVideoRecorderView.h
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZTAVRecordingProtocol <NSObject>
@required
- (void) startRecording;
- (void) stopRecording;
@end

@interface ZTVideoRecorderView : UIView
@property (nonatomic) id<ZTAVRecordingProtocol> recordingDelegate;
- (void) setPlaybackURL:(NSURL *)url;
- (void) stopPlayback;
- (void) startPlayback;
- (BOOL) isPlaying;
@end
