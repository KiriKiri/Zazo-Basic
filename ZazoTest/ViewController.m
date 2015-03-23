//
//  ViewController.m
//  ZazoTest
//
//  Created by Kirill Kirikov on 23.03.15.
//  Copyright (c) 2015 Seductive LLC. All rights reserved.
//

#import "ViewController.h"
#import "ZTCameraPreviewView.h"
#import "ZTVideoRecorderView.h"
#import "ZTRecordingFrameView.h"
#import "ZTVideoUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <ZTAVRecordingProtocol, AVCaptureFileOutputRecordingDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet ZTCameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet ZTVideoRecorderView *videoRecorderView;
@property (weak, nonatomic) IBOutlet ZTRecordingFrameView *recordingFrameView; //: Just for fun

//AVFoundation fields
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) BOOL deviceAuthStatus;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initAVCamera];
    [self initNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCaptureSessionRuntimeErrorNotification) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    
    [[self session] startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notifications

- (void) initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotificaion:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) didReceiveApplicationDidBecomeActiveNotificaion:(NSNotification *)notification {
    for (AVCaptureInput *input in [self.session inputs]) {
        NSLog(@"Input: %@", [input description]);
    }
}

#pragma mark -
#pragma mark UI

- (void) initViews
{
    self.videoRecorderView.recordingDelegate = self;
}

#pragma mark -
#pragma mark ZTAVRecordingProtocol

- (void) startRecording {
    NSLog(@"startRecording");
    
    NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
    
    [self createAudioInput];
    
    [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
    
    [self.recordingFrameView startShowingRecordingFrame];
}

- (void) stopRecording {
    NSLog(@"stopRecording");
    [[self movieFileOutput] stopRecording];
    [self.recordingFrameView stopShowingRecordingFrame];
}

#pragma mark AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    NSLog(@"Recording was finished");
    
    self.videoRecorderView.playbackURL = outputFileURL;
    [self removeAudioInput];
    
    /*
    // If we want to save to Assets Library
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [ZTVideoUtils alertWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error]];
        }
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    }];
     */
}

#pragma mark Errors Handling

-(void) didReceiveCaptureSessionRuntimeErrorNotification {
    [self.session startRunning];
}

#pragma mark -

#pragma mark AVFoundation initialization methods

- (void) initAVCamera {
    [self createAVSession];
    [self checkDeviceAuthStatus];
    [self initSessionInputsOutputs];
}

- (void) createAVSession {
    self.session = [[AVCaptureSession alloc] init];
    self.previewView.session = self.session;
}

- (void) checkDeviceAuthStatus {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        self.deviceAuthStatus = granted;
        
        if (!self.deviceAuthStatus) {
            [ZTVideoUtils alertWithTitle:@"Error" message:@"Application doesn't have permission to use Camera, please open Settings -> ZazoTest to enable the Camera."];
        }
    }];
}

- (void) initSessionInputsOutputs {
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(sessionQueue, ^{
        [self createVideoInput];
        [self createMovieFileOutput];
    });
}

- (void) createVideoInput {
    
    NSError *error = nil;
    AVCaptureDevice *videoDevice = [ZTVideoUtils deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error) {
        [ZTVideoUtils alertWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error]];
    }
    
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        [self setVideoDeviceInput:videoDeviceInput];
    }
}

- (void) createAudioInput {

    NSError *error = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    for (AVCaptureDevice* device in devices) {
        NSLog(@"Device: %@", device);
    }
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (error) {
        [ZTVideoUtils alertWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error]];
    }
    
    if ([self.session canAddInput:audioDeviceInput]) {
        [self.session addInput:audioDeviceInput];
    }
}

- (void) removeAudioInput {

    for (AVCaptureInput* input in self.session.inputs) {
        for (AVCaptureInputPort* port in input.ports) {
            if ([port.mediaType isEqualToString:AVMediaTypeAudio]) {
                NSLog(@"Mic input found. Removing it");
                [self.session removeInput:input];
                return;
            }
        }
    }
}

- (void) createMovieFileOutput {
    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:movieFileOutput])
    {
        [self.session addOutput:movieFileOutput];
        AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported])
            [connection setEnablesVideoStabilizationWhenAvailable:YES];
        [self setMovieFileOutput:movieFileOutput];
    }
}

#pragma mark -

@end
