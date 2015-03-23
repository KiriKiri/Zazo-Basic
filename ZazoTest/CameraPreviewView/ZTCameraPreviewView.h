//
//  ZTCameraPreviewView.h
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface ZTCameraPreviewView : UIView
@property (nonatomic) AVCaptureSession *session;
@end
