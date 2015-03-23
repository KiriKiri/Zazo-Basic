//
//  ZTCameraPreviewView.m
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import "ZTCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZTCameraPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    CGRect bounds = self.layer.bounds;
    AVCaptureVideoPreviewLayer *videoLayer = (AVCaptureVideoPreviewLayer *)[self layer];
    [videoLayer setSession:session];
    [videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoLayer setBounds:bounds];
    [videoLayer setPosition:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
}

@end
