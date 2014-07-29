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
@property (nonatomic, weak) IBOutlet UISegmentedControl *effectSelector;

@property (nonatomic, weak) IBOutlet UISlider *sliderA;
@property (nonatomic, weak) IBOutlet UISlider *sliderB;
@property (nonatomic, weak) IBOutlet UISlider *sliderC;
@property (nonatomic, weak) IBOutlet UISlider *sliderD;

@property (nonatomic, weak) IBOutlet UILabel *leftLabelA;
@property (nonatomic, weak) IBOutlet UILabel *leftLabelB;
@property (nonatomic, weak) IBOutlet UILabel *leftLabelC;
@property (nonatomic, weak) IBOutlet UILabel *leftLabelD;

@property (nonatomic, weak) IBOutlet UILabel *rightLabelA;
@property (nonatomic, weak) IBOutlet UILabel *rightLabelB;
@property (nonatomic, weak) IBOutlet UILabel *rightLabelC;
@property (nonatomic, weak) IBOutlet UILabel *rightLabelD;

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
    AudioUnit _reverbEffectsUnit;
    AudioUnit _delayEffectsUnit;
    AudioUnit _ioUnit;
    AUNode _reverbEffectsNode;
    AUNode _delayEffectsNode;
    AUNode _ioNode;
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

- (IBAction)effectSelectorChanged:(id)sender {
    [self stopAUGraph];
    
    AUGraphDisconnectNodeInput(_audioGraph,
                               _ioNode,
                               0);
    
    if (_effectSelector.selectedSegmentIndex == 0) {
        _leftLabelA.text = @"Amount";
        _leftLabelB.text = @"Gain";
        _leftLabelC.text = @"Min. Delay";
        _leftLabelD.text = @"Max. Delay";
        
        AUGraphDisconnectNodeInput(_audioGraph,
                                   _delayEffectsNode,
                                   0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _reverbEffectsNode,
                                0,
                                _ioNode,
                                0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _ioNode,
                                1,
                                _reverbEffectsNode,
                                0);
    } else {
        _leftLabelA.text = @"Amount";
        _leftLabelB.text = @"Time";
        _leftLabelC.text = @"Feedback";
        _leftLabelD.text = @"Low-pass Cutoff";
        
        AUGraphDisconnectNodeInput(_audioGraph,
                                   _reverbEffectsNode,
                                   0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _delayEffectsNode,
                                0,
                                _ioNode,
                                0);
        
        AUGraphConnectNodeInput(_audioGraph,
                                _ioNode,
                                1,
                                _delayEffectsNode,
                                0);
    }
    
    CAShow(_audioGraph);
    
    [self updateLabels];
    
    [self startStopGraphAsRequired];
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    
    AudioUnitParameterID parameter;
    AudioUnit audioUnit;
    
    if (_effectSelector.selectedSegmentIndex == 0) {
        audioUnit = _reverbEffectsUnit;
        if (0) {
        } else if (slider == _sliderA) {
            parameter = kReverb2Param_DryWetMix;
        } else if (slider == _sliderB) {
            parameter = kReverb2Param_Gain;
        } else if (slider == _sliderC) {
            parameter = kReverb2Param_MinDelayTime;
        } else if (slider == _sliderD) {
            parameter = kReverb2Param_MaxDelayTime;
        } else {
            return;
        }
    } else {
        audioUnit = _delayEffectsUnit;
        if (0) {
        } else if (slider == _sliderA) {
            parameter = kDelayParam_WetDryMix;
        } else if (slider == _sliderB) {
            parameter = kDelayParam_DelayTime;
        } else if (slider == _sliderC) {
            parameter = kDelayParam_Feedback;
        } else if (slider == _sliderD) {
            parameter = kDelayParam_LopassCutoff;
        } else {
            return;
        }
    }
    
    AudioUnitParameterValue value = [self valueForSlider:slider];
    AudioUnitSetParameter(audioUnit, parameter, kAudioUnitScope_Global, 0, value, 0);
    
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
    _rightLabelA.text = [NSString stringWithFormat:@"%.2f", [self valueForSlider:_sliderA]];
    _rightLabelB.text = [NSString stringWithFormat:@"%.2f", [self valueForSlider:_sliderB]];
    _rightLabelC.text = [NSString stringWithFormat:@"%.2f", [self valueForSlider:_sliderC]];
    _rightLabelD.text = [NSString stringWithFormat:@"%.2f", [self valueForSlider:_sliderD]];
}

- (float)valueForSlider:(UISlider*)slider {
    AudioUnitParameterValue minValue = 0.0f;
    AudioUnitParameterValue maxValue = 0.0f;
    
    BOOL log = NO;
    
    if (_effectSelector.selectedSegmentIndex == 0) {
        if (0) {
        } else if (slider == _sliderA) {
            minValue = 0.0f;
            maxValue = 100.0f;
            log = NO;
        } else if (slider == _sliderB) {
            minValue = -20.0f;
            maxValue = 20.0f;
            log = NO;
        } else if (slider == _sliderC) {
            minValue = 0.0001f;
            maxValue = 1.0f;
            log = YES;
        } else if (slider == _sliderD) {
            minValue = 0.0001f;
            maxValue = 1.0f;
            log = YES;
        } else {
            return 0.0f;
        }
    } else {
        if (0) {
        } else if (slider == _sliderA) {
            minValue = 0.0f;
            maxValue = 100.0f;
            log = NO;
        } else if (slider == _sliderB) {
            minValue = 0.0f;
            maxValue = 2.0f;
            log = NO;
        } else if (slider == _sliderC) {
            minValue = -100.0f;
            maxValue = 100.0f;
            log = NO;
        } else if (slider == _sliderD) {
            minValue = 10.0f;
            maxValue = 22000.0f;
            log = NO;
        } else {
            return 0.0f;
        }
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
    
    AudioComponentDescription reverbEffectUnitDescription;
    reverbEffectUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    reverbEffectUnitDescription.componentFlags = 0;
    reverbEffectUnitDescription.componentFlagsMask = 0;
    reverbEffectUnitDescription.componentType = kAudioUnitType_Effect;
    reverbEffectUnitDescription.componentSubType = kAudioUnitSubType_Reverb2;
	AUGraphAddNode(_audioGraph, &reverbEffectUnitDescription, &_reverbEffectsNode);
    
    AudioComponentDescription delayEffectUnitDescription;
    delayEffectUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    delayEffectUnitDescription.componentFlags = 0;
    delayEffectUnitDescription.componentFlagsMask = 0;
    delayEffectUnitDescription.componentType = kAudioUnitType_Effect;
    delayEffectUnitDescription.componentSubType = kAudioUnitSubType_Delay;
	AUGraphAddNode(_audioGraph, &delayEffectUnitDescription, &_delayEffectsNode);
    
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &iOUnitDescription, &_ioNode);
    
	AUGraphOpen(_audioGraph);
    
	AUGraphNodeInfo(_audioGraph, _reverbEffectsNode, NULL, &_reverbEffectsUnit);
	AUGraphNodeInfo(_audioGraph, _delayEffectsNode, NULL, &_delayEffectsUnit);
    AUGraphNodeInfo(_audioGraph, _ioNode, NULL, &_ioUnit);
    
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
    
    AudioUnitSetProperty(_reverbEffectsUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         0,
                         &format,
                         sizeof(format));
    
    AudioUnitSetProperty(_delayEffectsUnit,
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
                            _reverbEffectsNode,
                            0,
                            _ioNode,
                            0);
    
    AUGraphConnectNodeInput(_audioGraph,
                            _ioNode,
                            1,
                            _reverbEffectsNode,
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
