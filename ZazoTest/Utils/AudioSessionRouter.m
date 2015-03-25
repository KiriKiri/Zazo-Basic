//
//  AudioSessionRouter.m
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import "AudioSessionRouter.h"
#import <UIKit/UIKit.h>

@implementation AudioSessionRouter

#pragma mark - Singleton

+ (AudioSessionRouter * ) sharedInstance {
    
    static dispatch_once_t pred;
    static AudioSessionRouter *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[AudioSessionRouter alloc] init];
    });
    
    return shared;
}

#pragma mark - Initialization methods

- (instancetype) init {
    self = [super init];
    if (self) {
        [self initAudioSessionRouting];
        [self subscribeToNotifications];
    }
    
    return self;
}

- (void)initAudioSessionRouting
{
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    [self updateAudioSessionParams];
    BOOL success = [self.session setActive:YES error:&error];
    
    if (success) {
        NSLog(@"AudioSession is set to active");
    }
    
    NSLog(@"Default mode is: %@", self.session.mode);
}

- (void) subscribeToNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveProximityChangedNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionRoutChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - Notifications handling

- (void) didReceiveAudioSessionInterruptionNotification:(NSNotification *)notification {
    NSLog(@"didReceiveAudioSessionInterruptionNotification");
}

- (void) didReceiveAudioSessionRoutChangeNotification:(NSNotification *)notification {
    NSLog(@"didReceiveAudioSessionRoutChangeNotification");
    AVAudioSessionRouteChangeReason reason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self updateAudioSessionParams];
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"Awaking from sleep");
            break;
        default:
            break;
    }
    

}

- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    NSLog(@"didReceiveProximityChangedNotification");
    [self updateAudioSessionParams];
}

#pragma mark - Audio managing

- (void) setState:(AudioSessionState)state {
    _state = state;
    [self updateAudioSessionParams];
}

- (void) updateAudioSessionParams {
    NSError *error;
    BOOL success;
    NSString *mode;
    NSString *category;
    int options = AVAudioSessionCategoryOptionMixWithOthers;
    
    switch (self.state) {
        case Recording:
            //VideoChat because we need to use external BT mic (maybe)
            mode = AVAudioSessionModeVideoChat;
            //Record because we do recording
            category = AVAudioSessionCategoryRecord;
            //Allow bluetooth because we don't need bluetooth system to disconnect
            //And maybe we can use external mic
            options = AVAudioSessionCategoryOptionAllowBluetooth;

            break;
        case Playing:
        default:
            if ([UIDevice currentDevice].proximityState) {
                //Voice chat because we need to use earpiece
                mode = AVAudioSessionModeVoiceChat;
                //PlayAndRecord because we don't need another sounds playing in the background
                category = AVAudioSessionCategoryPlayAndRecord;
            } else {
                //Video Chat because we need to play video on external BT device
                mode = AVAudioSessionModeVideoChat;
                //Playback not playAndRecord because we need to play music from other apps
                category = AVAudioSessionCategoryPlayback;
                options = AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetooth;
            }
            break;
    }
    
    if (![[self.session mode] isEqualToString:mode]) {
        success = [self.session setMode:mode error:&error];
        NSLog(@"AudioSessionRouter::updateAudioSessionParams Mode: %@. Success: %d. Error:%@", mode, success, error);
    }
    
    if (![[self.session category] isEqualToString:category]) {
        success = [self.session setCategory:category withOptions:options error:&error];
        NSLog(@"AudioSessionRouter::updateAudioSessionParams Category:%@ Options:%d Success: %d. Error:%@", category, options, success, error);
    }
}
#pragma mark - Debug

- (void) printOutputDataSources {
    NSLog(@"Current OutputDataSource: %@", [[self.session outputDataSource] description]);
    for (AVAudioSessionDataSourceDescription *dataSource in [self.session outputDataSources]) {
        NSLog(@"DataSource: %@", [dataSource description]);
    }
}

- (void) printInputDataSources {
    NSLog(@"Current InputDataSource: %@", [[self.session inputDataSource] description]);
    for (AVAudioSessionDataSourceDescription *dataSource in [self.session inputDataSources]) {
        NSLog(@"DataSource: %@", [dataSource description]);
    }
}

@end
