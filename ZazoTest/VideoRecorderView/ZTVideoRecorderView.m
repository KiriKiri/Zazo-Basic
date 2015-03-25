//
//  ZTVideoRecorderView.m
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import "ZTVideoRecorderView.h"
#import "ZTVideoUtils.h"
#import "AudioSessionRouter.h"
#import <AVFoundation/AVFoundation.h>

@interface ZTVideoRecorderView()
@property (nonatomic) AVPlayer *player;
@property (nonatomic) NSTimer *timer;
@end

@implementation ZTVideoRecorderView

#pragma mark - Public

- (void) setPlaybackURL:(NSURL *)url
{
    self.player = [AVPlayer playerWithURL:url];
}

- (void) stopPlayback {
    if ([self isPlaying]) {
        [self.player pause];
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void) startPlayback {
    if (self.player) {
        [[AudioSessionRouter sharedInstance] setState:Playing];
        [self.player play];
        
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
}

- (BOOL) isPlaying {
    return self.player && self.player.rate > 0 && self.player.error == nil;
}

- (void) seekToZeroTime {
    [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - Observing

// Not used now
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        
        if (self.player.status == AVPlayerStatusReadyToPlay) {            
            //we can highlight view to inform user about playback is possible
        }
    }
}

- (void) handleAVPlayerItemDidPlayToEndNotification:(NSNotification *) notification
{
    [self seekToZeroTime];
}

#pragma mark - Overriden gettes/settes

- (void) setPlayer:(AVPlayer *)player
{
    _player = player;
    
    AVPlayerLayer *videoLayer = (AVPlayerLayer *)self.layer;
    [videoLayer setPlayer:self.player];
    [videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


#pragma mark - Init

- (void) awakeFromNib {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognized:)];
    [self addGestureRecognizer:tapRecognizer];
}

#pragma mark - UI

- (void) handleTapGestureRecognized:(UITapGestureRecognizer *)sender
{
    [self.timer invalidate];
    
    if ([self isPlaying]) {
        [self stopPlayback];
    } else {
        [self startPlayback];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if (self.recordingDelegate) {
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(startRecordingHandlePlayingState) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.timer invalidate];
    if (self.recordingDelegate) {
        [self.recordingDelegate stopRecording];
    }
}

- (void) startRecordingHandlePlayingState {
    
    if (self.recordingDelegate) {
        
        //If we're playing video now: stop it before starting recording.
        [self stopPlayback];
        [self.recordingDelegate startRecording];
    }
}

#pragma mark - Utils

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

@end
