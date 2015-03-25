//
//  AudioSessionRouter.h
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    Playing,
    Recording
} AudioSessionState;

@interface AudioSessionRouter : NSObject
@property (nonatomic) AVAudioSession *session;
@property (nonatomic) AudioSessionState state;
+ (AudioSessionRouter * ) sharedInstance;
@end
