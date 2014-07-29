//
//  ViewController.m
//  ColloQR
//
//  Created by Matt Galloway on 20/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

@import AVFoundation;

@interface Barcode : NSObject
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;
@end

@implementation Barcode
@end

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIView *rectOfInterestView;
@property (nonatomic, weak) IBOutlet UISlider *zoomSlider;
@end

@implementation ViewController {
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureMetadataOutput *_metadataOutput;
    BOOL _running;
    
    AVSpeechSynthesizer *_speechSynthesizer;
    
    NSMutableDictionary *_barcodes;
    CGFloat _initialPinchZoom;
//    Barcode *_zoomBarcode;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCaptureSession];
    
    _previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_previewLayer];
    
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    _barcodes = [NSMutableDictionary new];
    
    [_previewView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
    _metadataOutput.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:_rectOfInterestView.frame];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}


#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}

- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}


#pragma mark - Actions

CGFloat ZoomFactorCalc(CGFloat maxZoomFactor, CGFloat sliderValue) {
    CGFloat factor = pow(maxZoomFactor, sliderValue);
    return MIN(10.0f, factor);
}

- (IBAction)zoomSliderChanged:(id)sender {
    if (!_videoDevice) return;
    
    NSError *error = nil;
    [_videoDevice lockForConfiguration:&error];
    if (!error) {
        CGFloat zoomFactor = ZoomFactorCalc(_videoDevice.activeFormat.videoMaxZoomFactor, _zoomSlider.value);
        _videoDevice.videoZoomFactor = zoomFactor;
        [_videoDevice unlockForConfiguration];
    }
}

- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser {
    // 1
    if (!_videoDevice) return;
    
    // 2
    if (recogniser.state == UIGestureRecognizerStateBegan) {
        _initialPinchZoom = _videoDevice.videoZoomFactor;
    }
    
    // 3
    NSError *error = nil;
    [_videoDevice lockForConfiguration:&error];
    
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = recogniser.scale;
        if (scale < 1.0f) {
            // 4
            zoomFactor = _initialPinchZoom - pow(_videoDevice.activeFormat.videoMaxZoomFactor, 1.0f - recogniser.scale);
        } else {
            // 5
            zoomFactor = _initialPinchZoom + pow(_videoDevice.activeFormat.videoMaxZoomFactor, (recogniser.scale - 1.0f) / 2.0f);
        }
        
        // 6
        zoomFactor = MIN(10.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        
        // 7
        _videoDevice.videoZoomFactor = zoomFactor;
        
        // 8
        [_videoDevice unlockForConfiguration];
    }
}


#pragma mark - Video stuff

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _running = YES;
}

- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    _running = NO;
}

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    
    // 2
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }
    
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    dispatch_queue_t metadataQueue = dispatch_queue_create("com.razeware.ColloQR.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}


#pragma mark -

- (Barcode*)processMetadataObject:(AVMetadataMachineReadableCodeObject*)code {
    // 1
    Barcode *barcode = _barcodes[code.stringValue];
    
    // 2
    if (!barcode) {
        barcode = [Barcode new];
        _barcodes[code.stringValue] = barcode;
    }
    
    // 3
    barcode.metadataObject = code;
    
    // Create the path joining code's corners
    
    // 4
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    // 5
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
    
    // 6
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    
    // 7
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    // 8
    CGPathCloseSubpath(cornersPath);
    
    // 9
    barcode.cornersPath = [UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    // Create the path for the code's bounding box
    
    // 10
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    
    // 11
    return barcode;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSSet *originalBarcodes = [NSSet setWithArray:_barcodes.allValues];
    NSMutableSet *foundBarcodes = [NSMutableSet new];
    
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Metadata: %@", obj);
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
            Barcode *barcode = [self processMetadataObject:code];
            [foundBarcodes addObject:barcode];
        }
    }];
    
    NSMutableSet *newBarcodes = [foundBarcodes mutableCopy];
    [newBarcodes minusSet:originalBarcodes];
    
    NSMutableSet *goneBarcodes = [originalBarcodes mutableCopy];
    [goneBarcodes minusSet:foundBarcodes];
    
    [goneBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
        [_barcodes removeObjectForKey:barcode.metadataObject.stringValue];
    }];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
//        Barcode *zoomBarcode = [newBarcodes anyObject];
//        if (zoomBarcode && zoomBarcode != _zoomBarcode) {
//            _zoomBarcode = zoomBarcode;
//            
//            CGSize targetSize = CGSizeMake(_previewView.frame.size.width / 2.0f, _previewView.frame.size.height / 2.0f);
//            CGSize barcodeSize = CGSizeMake(zoomBarcode.metadataObject.bounds.size.width * _videoDevice.videoZoomFactor, zoomBarcode.metadataObject.bounds.size.height * _videoDevice.videoZoomFactor);
//            
//            CGFloat requiredZoom = MIN(targetSize.width / barcodeSize.width, targetSize.height / barcodeSize.height);
//            
//            if (requiredZoom > 1.0f) {
//                CGFloat maximumZoom = _videoDevice.activeFormat.videoMaxZoomFactor;
//                CGFloat currentZoom = _videoDevice.videoZoomFactor;
//                CGFloat zoom = MIN(requiredZoom, maximumZoom);
//                
//                if (fabsf(zoom - currentZoom) > 0.2f) {
//                    NSError *error = nil;
//                    [_videoDevice lockForConfiguration:&error];
//                    if (!error) {
//                        [_videoDevice rampToVideoZoomFactor:zoom withRate:1.0f];
//                        [_videoDevice unlockForConfiguration];
//                    }
//                    
//                    _zoomSlider.value = log2f(zoom) / log2f(maximumZoom);
//                }
//            }
//        }
        
        // Remove all old layers
        NSArray *allSublayers = [_previewView.layer.sublayers copy];
        [allSublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
            if (layer != _previewLayer) {
                [layer removeFromSuperlayer];
            }
        }];
        
        // Add new layers
        [foundBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
            CAShapeLayer *boundingBoxLayer = [CAShapeLayer new];
            boundingBoxLayer.path = barcode.boundingBoxPath.CGPath;
            boundingBoxLayer.lineWidth = 2.0f;
            boundingBoxLayer.strokeColor = [UIColor greenColor].CGColor;
            boundingBoxLayer.fillColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f].CGColor;
            [_previewView.layer addSublayer:boundingBoxLayer];
            
            CAShapeLayer *cornersPathLayer = [CAShapeLayer new];
            cornersPathLayer.path = barcode.cornersPath.CGPath;
            cornersPathLayer.lineWidth = 2.0f;
            cornersPathLayer.strokeColor = [UIColor blueColor].CGColor;
            cornersPathLayer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f].CGColor;
            [_previewView.layer addSublayer:cornersPathLayer];
        }];
        
        // Speak the new barcodes
        [newBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:barcode.metadataObject.stringValue];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            utterance.rate = AVSpeechUtteranceMinimumSpeechRate + ((AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate) * [defaults floatForKey:@"Speed"]);
            utterance.volume = [defaults floatForKey:@"Volume"];
            utterance.pitchMultiplier = [defaults floatForKey:@"Pitch"];
            
            [_speechSynthesizer speakUtterance:utterance];
        }];
    });
}

@end
