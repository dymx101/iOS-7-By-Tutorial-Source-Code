//
//  ViewController.m
//  iEffects
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

@import AudioToolbox;
@import AudioUnit;
@import AVFoundation;

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UISlider *wetDrySlider;
@property (nonatomic, weak) IBOutlet UISlider *gainSlider;
@property (nonatomic, weak) IBOutlet UISlider *minDelayTimeSlider;
@property (nonatomic, weak) IBOutlet UISlider *maxDelayTimeSlider;

@property (nonatomic, weak) IBOutlet UILabel *wetDryLabel;
@property (nonatomic, weak) IBOutlet UILabel *gainLabel;
@property (nonatomic, weak) IBOutlet UILabel *minDelayTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxDelayTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *connectionStateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *connectedAppIcon;

- (void)audioUnitPropertyChanged:(void *)object unit:(AudioUnit)unit propID:(AudioUnitPropertyID)propID scope:(AudioUnitScope)scope element:(AudioUnitElement)element;
@end

void AudioUnitPropertyChanged(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    ViewController *SELF = (__bridge ViewController *)inRefCon;
    [SELF audioUnitPropertyChanged:inRefCon unit:inUnit propID:inID scope:inScope element:inElement];
}

@implementation ViewController {
    AUGraph _audioGraph;
    AudioUnit _effectsUnit;
    AudioUnit _ioUnit;
    BOOL _graphStarted;
    BOOL _inForeground;
    BOOL _connected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inForeground = ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self createAUGraph];
    [self publishAsNode];
    [self startStopGraphAsRequired];
    [self updateLabels];
}


#pragma mark - Notifications

- (void)applicationDidEnterBackground:(NSNotification*)note {
    _inForeground = NO;
    [self startStopGraphAsRequired];
}

- (void)applicationWillEnterForeground:(NSNotification*)note {
    _inForeground = YES;
    [self startStopGraphAsRequired];
}


#pragma mark - Actions

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    
    AudioUnitParameterID parameter;
    
    if (0) {
    } else if (slider == _wetDrySlider) {
        parameter = kReverb2Param_DryWetMix;
    } else if (slider == _gainSlider) {
        parameter = kReverb2Param_Gain;
    } else if (slider == _minDelayTimeSlider) {
        parameter = kReverb2Param_MinDelayTime;
    } else if (slider == _maxDelayTimeSlider) {
        parameter = kReverb2Param_MaxDelayTime;
    } else {
        return;
    }
    
    AudioUnitParameterValue value = [self valueForSlider:slider];
    AudioUnitSetParameter(_effectsUnit, parameter, kAudioUnitScope_Global, 0, value, 0);
    
    [self updateLabels];
}

- (IBAction)openHostApp:(id)sender {
    if (_connected) {
        CFURLRef url;
        UInt32 size = sizeof(url);
        OSStatus result = AudioUnitGetProperty(_ioUnit, kAudioUnitProperty_PeerURL, kAudioUnitScope_Global, 0, &url, &size);
        if (result == noErr) {
            [[UIApplication sharedApplication] openURL:(__bridge NSURL*)url];
        }
    }
}

- (void)updateLabels {
    _wetDryLabel.text = [NSString stringWithFormat:@"%.0f", [self valueForSlider:_wetDrySlider]];
    _gainLabel.text = [NSString stringWithFormat:@"%.0f", [self valueForSlider:_gainSlider]];
    _minDelayTimeLabel.text = [NSString stringWithFormat:@"%.3f", [self valueForSlider:_minDelayTimeSlider]];
    _maxDelayTimeLabel.text = [NSString stringWithFormat:@"%.3f", [self valueForSlider:_maxDelayTimeSlider]];
}

- (float)valueForSlider:(UISlider*)slider {
    AudioUnitParameterValue minValue = 0.0f;
    AudioUnitParameterValue maxValue = 0.0f;
    
    BOOL log = NO;
    
    if (0) {
    } else if (slider == _wetDrySlider) {
        minValue = 0.0f;
        maxValue = 100.0f;
        log = NO;
    } else if (slider == _gainSlider) {
        minValue = -20.0f;
        maxValue = 20.0f;
        log = NO;
    } else if (slider == _minDelayTimeSlider) {
        minValue = 0.0001f;
        maxValue = 1.0f;
        log = YES;
    } else if (slider == _maxDelayTimeSlider) {
        minValue = 0.0001f;
        maxValue = 1.0f;
        log = YES;
    } else {
        return 0.0f;
    }
    
    float value;
    
    if (log) {
        value = expf(logf(minValue) + (logf(maxValue) - logf(minValue)) * slider.value);
    } else {
        value = minValue + (maxValue - minValue) * slider.value;
    }
    
    return value;
}

- (void)updateConnectedAppViews {
    if (_connected) {
        _connectionStateLabel.text = @"Connected";
        _connectedAppIcon.image = AudioOutputUnitGetHostIcon(_ioUnit, 44.0f);
    } else {
        _connectionStateLabel.text = @"Not connected";
        _connectedAppIcon.image = nil;
    }
}


#pragma mark - Audio stuff

- (void)startAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setPreferredSampleRate:[session sampleRate] error:nil];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

- (void)stopAudioSession {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)createAUGraph {
    NewAUGraph(&_audioGraph);
    
    AUNode effectsNode;
    AUNode ioNode;
    
    AudioComponentDescription effectUnitDescription;
    effectUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    effectUnitDescription.componentFlags = 0;
    effectUnitDescription.componentFlagsMask = 0;
    effectUnitDescription.componentType = kAudioUnitType_Effect;
    effectUnitDescription.componentSubType = kAudioUnitSubType_Reverb2;
	AUGraphAddNode(_audioGraph, &effectUnitDescription, &effectsNode);
    
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &iOUnitDescription, &ioNode);
    
	AUGraphOpen(_audioGraph);
    
	AUGraphNodeInfo(_audioGraph, effectsNode, NULL, &_effectsUnit);
    AUGraphNodeInfo(_audioGraph, ioNode, NULL, &_ioUnit);
    
    UInt32 flag = 1;
    AudioUnitSetProperty(_ioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1,
                         &flag,
                         sizeof(flag));
    
    AudioUnitSetProperty(_ioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         0,
                         &flag,
                         sizeof(flag));
    
    AudioUnitAddPropertyListener(_ioUnit,
                                 kAudioUnitProperty_IsInterAppConnected,
                                 AudioUnitPropertyChanged,
                                 (__bridge void*)self);
    
    AudioStreamBasicDescription format;
    format.mChannelsPerFrame = 2;
    format.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    format.mBytesPerFrame = sizeof(Float32);
    format.mBytesPerPacket = sizeof(Float32);
    format.mBitsPerChannel = 32;
    format.mFramesPerPacket = 1;
    
    AudioUnitSetProperty(_effectsUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         0,
                         &format,
                         sizeof(format));
    
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
    
    AUGraphConnectNodeInput(_audioGraph,
                            effectsNode,
                            0,
                            ioNode,
                            0);
    
    AUGraphConnectNodeInput(_audioGraph,
                            ioNode,
                            1,
                            effectsNode,
                            0);
    
	CAShow(_audioGraph);
}

- (void)startStopGraphAsRequired {
    if (_connected || _inForeground) {
        [self startAUGraph];
    } else if (!_inForeground) {
        [self stopAUGraph];
    }
    CAShow(_audioGraph);
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
        [self stopAudioSession];
        _graphStarted = NO;
    }
}

- (void)audioUnitPropertyChanged:(void *)object unit:(AudioUnit)unit propID:(AudioUnitPropertyID)propID scope:(AudioUnitScope)scope element:(AudioUnitElement)element {
    if (propID == kAudioUnitProperty_IsInterAppConnected) {
        UInt32 connected;
        UInt32 dataSize = sizeof(UInt32);
        AudioUnitGetProperty(_ioUnit, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize);
        
        _connected = (BOOL)connected;
        
        [self startStopGraphAsRequired];
        [self updateConnectedAppViews];
    }
}

- (void)publishAsNode {
    AudioComponentDescription desc = {
        kAudioUnitType_RemoteEffect,
        'iasp',
        'i7bt',
        0,
        0
    };
	AudioOutputUnitPublish(&desc, CFSTR("iEffects"), 1, _ioUnit);
}

@end
