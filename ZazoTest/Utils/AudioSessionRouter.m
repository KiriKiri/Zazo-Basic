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
        [self initProximityMonitoring];
    }
    
    return self;
}

- (void)initAudioSessionRouting
{
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    
    BOOL success = [self.session setActive:YES error:&error];
    if (success) {
        NSLog(@"AudioSession is set to active");
    }
    
    NSLog(@"Default mode is: %@", self.session.mode);
}

- (void) initProximityMonitoring {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveProximityChangedNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
}

#pragma mark - Notifications handling

- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    if ([UIDevice currentDevice].proximityState) {
        [self changeRouteToReceiver];
    } else {
        [self changeRouteToVideoRecording];
    }
}

#pragma mark - Audio managing

- (void) changeRouteToReceiver {
    NSError *error;
    
    BOOL success = [self.session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (success) NSLog(@"Session Mode changed to voice chat");
}

- (void) changeRouteToVideoRecording {
    NSError *error;
    BOOL success = [self.session setMode:AVAudioSessionModeVideoRecording error:&error];
    if (success) NSLog(@"Session Mode changed to video recording");
}


#pragma mark - Tests
/*
- (void) overrideOutput {
    NSError *error;

    BOOL success = [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (success) {
        NSLog(@"Overriding output is success");
    }
    
    success = [self.session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (success) {
        NSLog(@"Session Mode changed to voice chat");
    }

    for (id dataSource in self.session.outputDataSources) {
        NSLog(@"Output dataSource: %@", dataSource);
    }
    
    for (AVAudioSessionPortDescription* port in self.session.currentRoute.outputs) {
        NSLog(@"Output port: %@", port);
    }
}
*/

@end
