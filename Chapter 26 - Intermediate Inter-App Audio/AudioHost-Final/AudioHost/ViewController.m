//
//  ViewController.m
//  AudioHost
//
//  Created by Matt Galloway on 12/07/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

#import "SelectIAAUViewController.h"
#import "InterAppAudioUnit.h"

@import AudioToolbox;
@import AudioUnit;
@import AVFoundation;

@interface ViewController () <SelectIAAUViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *instrumentIconImagView;
@property (nonatomic, weak) IBOutlet UIImageView *effectIconImageView;
@end

@implementation ViewController {
    AUGraph _audioGraph;
    AudioUnit _ioUnit;
    AudioUnit _instrumentUnit;
    AudioUnit _effectUnit;
    AUNode _ioNode;
    AUNode _instrumentNode;
    AUNode _effectNode;
    BOOL _graphStarted;
    BOOL _connectedInstrument;
    BOOL _connectedEffect;
    
    SelectIAAUViewController *_instrumentSelectViewController;
    SelectIAAUViewController *_effectSelectViewController;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createAUGraph];
}


#pragma mark -

- (IBAction)selectInstrument:(id)sender {
    AudioComponentDescription description = { kAudioUnitType_RemoteInstrument, 0, 0, 0, 0 };
    _instrumentSelectViewController = [[SelectIAAUViewController alloc] initWithSearchDescription:description];
    _instrumentSelectViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_instrumentSelectViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)selectEffect:(id)sender {
    AudioComponentDescription description = { kAudioUnitType_RemoteEffect, 0, 0, 0, 0 };
    _effectSelectViewController = [[SelectIAAUViewController alloc] initWithSearchDescription:description];
    _effectSelectViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_effectSelectViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)playNote:(id)sender {
    if (_instrumentUnit) {
        UInt32 noteOnCommand = (0x9 << 4) | 0;
        MusicDeviceMIDIEvent(_instrumentUnit, noteOnCommand, 60, 100, 0);
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_instrumentUnit) {
                UInt32 noteOffCommand = (0x8 << 4) | 0;
                MusicDeviceMIDIEvent(_instrumentUnit, noteOffCommand, 60, 100, 0);
            }
        });
    }
}


#pragma mark - Audio stuff

- (void)startAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setPreferredSampleRate:[session sampleRate] error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [session setActive:YES error:nil];
}

- (void)createAUGraph {
    // 1
    NewAUGraph(&_audioGraph);
    
    // 2
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &iOUnitDescription, &_ioNode);
    
    // 3
    AUGraphOpen(_audioGraph);
    
    // 4
    AUGraphNodeInfo(_audioGraph, _ioNode, NULL, &_ioUnit);
    
    // 5
    AudioStreamBasicDescription format;
    format.mChannelsPerFrame = 2;
    format.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    format.mBytesPerFrame = sizeof(Float32);
    format.mBytesPerPacket = sizeof(Float32);
    format.mBitsPerChannel = 32;
    format.mFramesPerPacket = 1;
    
    AudioUnitSetProperty(_ioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         1,
                         &format,
                         sizeof(format));
    
    AudioUnitSetProperty(_ioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &format,
                         sizeof(format));
    
    // 6
    CAShow(_audioGraph);
}

- (void)startStopGraphAsRequired {
    if (_connectedInstrument) {
        [self startAUGraph];
    } else {
        [self stopAUGraph];
    }
}

- (void)startAUGraph {
    if (!_graphStarted && _audioGraph) {
        [self startAudioSession];
        
        Boolean outIsInitialized;
        AUGraphIsInitialized(_audioGraph, &outIsInitialized);
        if (!outIsInitialized) {
            AUGraphInitialize(_audioGraph);
        }
        
        AUGraphStart(_audioGraph);
        
        _graphStarted = YES;
    }
}

- (void)stopAUGraph {
    if (_graphStarted && _audioGraph) {
        AUGraphStop(_audioGraph);
        
        Boolean outIsInitialized;
        AUGraphIsInitialized(_audioGraph, &outIsInitialized);
        if (outIsInitialized) {
            AUGraphUninitialize(_audioGraph);
        }
        
        _graphStarted = NO;
    }
}

- (void)connectInstrument:(InterAppAudioUnit*)unit {
    // 1
    [self stopAUGraph];
    
    // 2
    AUNode newInstrumentNode;
    AudioComponentDescription desc = unit.componentDescription;
    AUGraphAddNode(_audioGraph, &desc, &newInstrumentNode);
    
    // 3
    if (newInstrumentNode) {
        // 4
        if (_instrumentNode) {
            AUGraphDisconnectNodeInput(_audioGraph, _instrumentNode, 0);
            AUGraphRemoveNode(_audioGraph, _instrumentNode);
            _instrumentIconImagView.image = nil;
            _instrumentUnit = NULL;
        }
        
        // 5
        _instrumentNode = newInstrumentNode;
        
        // 6
        AUGraphNodeInfo(_audioGraph, _instrumentNode, 0, &_instrumentUnit);
        
        // 7
        if (_effectNode) {
            AUGraphConnectNodeInput(_audioGraph,
                                    _instrumentNode,
                                    0,
                                    _effectNode,
                                    0);
        } else {
            AUGraphConnectNodeInput(_audioGraph,
                                    _instrumentNode,
                                    0,
                                    _ioNode,
                                    0);
        }
        
        // 8
        _connectedInstrument = YES;
        _instrumentIconImagView.image = unit.icon;
    } else {
        NSLog(@"Failed to obtain instrument audio unit.");
    }
    
    // 9
    [self startStopGraphAsRequired];
    CAShow(_audioGraph);
}

- (void)connectEffect:(InterAppAudioUnit*)unit {
    if (!_connectedInstrument) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"You need to select an instrument first!"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    [self stopAUGraph];
    
    AUNode newEffectNode;
    AudioComponentDescription desc = unit.componentDescription;
    AUGraphAddNode(_audioGraph, &desc, &newEffectNode);
    
    if (newEffectNode) {
        if (_effectNode) {
            AUGraphDisconnectNodeInput(_audioGraph, _effectNode, 0);
            AUGraphRemoveNode(_audioGraph, _effectNode);
            _effectIconImageView.image = nil;
            _effectUnit = NULL;
        }
        
        _effectNode = newEffectNode;
        
        AUGraphNodeInfo(_audioGraph, _effectNode, 0, &_effectUnit);
        
        AUGraphDisconnectNodeInput(_audioGraph, _ioNode, 0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _effectNode,
                                0,
                                _ioNode,
                                0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _instrumentNode,
                                0,
                                _effectNode,
                                0);
        
        _connectedEffect = YES;
        _effectIconImageView.image = unit.icon;
    } else {
        NSLog(@"Failed to obtain effect audio unit.");
    }
    
    [self startStopGraphAsRequired];
    CAShow(_audioGraph);
}


#pragma mark - SelectInterAppAudioUnitViewControllerDelegate

- (void)selectIAAUViewControllerWantsToClose:(SelectIAAUViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectIAAUViewController:(SelectIAAUViewController *)viewController didSelectUnit:(InterAppAudioUnit *)unit {
    if (viewController == _instrumentSelectViewController) {
        [self connectInstrument:unit];
    } else if (viewController == _effectSelectViewController) {
        [self connectEffect:unit];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
