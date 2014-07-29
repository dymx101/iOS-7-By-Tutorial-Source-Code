//
//  ViewController.m
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

#import "GuitarNeck.h"
#import "SelectEffectViewController.h"
#import "Effect.h"

@import AudioToolbox;
@import AudioUnit;
@import AVFoundation;

@interface ViewController () <GuitarNeckDelegate, SelectEffectViewControllerDelegate>
@property (nonatomic, weak) IBOutlet GuitarNeck *guitarNeck;
@property (nonatomic, weak) IBOutlet UIImageView *effectIconImageView;

- (void)audioUnitPropertyChanged:(void *)object unit:(AudioUnit)unit propID:(AudioUnitPropertyID)propID scope:(AudioUnitScope)scope element:(AudioUnitElement)element;
- (void)audioUnitMIDIEvent:(void *)object status:(UInt32)status data1:(UInt32)data1 data2:(UInt32)data2 offsetSampleFrame:(UInt32)offsetSampleFrame;
@end

void AudioUnitPropertyChanged(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    ViewController *SELF = (__bridge ViewController *)inRefCon;
    [SELF audioUnitPropertyChanged:inRefCon unit:inUnit propID:inID scope:inScope element:inElement];
}

void AudioUnitMIDIEvent(void *userData, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame) {
    ViewController *SELF = (__bridge ViewController *)userData;
    [SELF audioUnitMIDIEvent:userData status:inStatus data1:inData1 data2:inData2 offsetSampleFrame:inOffsetSampleFrame];
}

@implementation ViewController {
    AUGraph _audioGraph;
    AudioUnit _synthUnit;
    AudioUnit _ioUnit;
    AudioUnit _effectUnit;
    AUNode _synthNode;
    AUNode _ioNode;
    AUNode _effectNode;
    BOOL _graphStarted;
    BOOL _inForeground;
    BOOL _connected;
}

#pragma mark -

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
    
    _guitarNeck.delegate = self;
    
    [self createAUGraph];
    [self publishAsNode];
    [self startStopGraphAsRequired];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EffectSegue"]) {
        UINavigationController *navigationController = ((UINavigationController *)segue.destinationViewController);
        SelectEffectViewController *selectEffectViewController = (SelectEffectViewController*)navigationController.topViewController;
        selectEffectViewController.delegate = self;
    }
}


#pragma mark - Actions

- (IBAction)aChordTapped:(id)sender {
    [_guitarNeck playChord:@"A"];
}

- (IBAction)bChordTapped:(id)sender {
    [_guitarNeck playChord:@"B"];
}

- (IBAction)cChordTapped:(id)sender {
    [_guitarNeck playChord:@"C"];
}

- (IBAction)dChordTapped:(id)sender {
    [_guitarNeck playChord:@"D"];
}

- (IBAction)eChordTapped:(id)sender {
    [_guitarNeck playChord:@"E"];
}

- (IBAction)fChordTapped:(id)sender {
    [_guitarNeck playChord:@"F"];
}

- (IBAction)gChordTapped:(id)sender {
    [_guitarNeck playChord:@"G"];
}

- (IBAction)openEffectApp:(id)sender {
    if (_effectUnit) {
        CFURLRef url;
        UInt32 size = sizeof(url);
        OSStatus result = AudioUnitGetProperty(_effectUnit, kAudioUnitProperty_PeerURL, kAudioUnitScope_Global, 0, &url, &size);
        if (result == noErr) {
            [[UIApplication sharedApplication] openURL:(__bridge NSURL*)url];
        }
    }
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
    AudioComponentDescription synthUnitDescription;
    synthUnitDescription.componentType = kAudioUnitType_MusicDevice;
    synthUnitDescription.componentSubType = kAudioUnitSubType_Sampler;
    synthUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    synthUnitDescription.componentFlags = 0;
    synthUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &synthUnitDescription, &_synthNode);
    
    // 3
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &iOUnitDescription, &_ioNode);
    
    // 4
    AUGraphOpen(_audioGraph);
    
    // 5
    AUGraphNodeInfo(_audioGraph, _synthNode, NULL, &_synthUnit);
    AUGraphNodeInfo(_audioGraph, _ioNode, NULL, &_ioUnit);
    
    // 6
    AudioStreamBasicDescription format;
    format.mChannelsPerFrame = 2;
    format.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    format.mBytesPerFrame = sizeof(Float32);
    format.mBytesPerPacket = sizeof(Float32);
    format.mBitsPerChannel = 32;
    format.mFramesPerPacket = 1;
    
    // 7
    AudioUnitSetProperty(_synthUnit,
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
    
    // 8
    AUGraphConnectNodeInput(_audioGraph,
                            _synthNode,
                            0,
                            _ioNode,
                            0);
    
    // 9
    NSURL *instrumentURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SteelGuitar" ofType:@"aupreset"]];
    AUSamplerInstrumentData bpdata;
    bpdata.fileURL = (__bridge CFURLRef)instrumentURL;
    bpdata.instrumentType = kInstrumentType_AUPreset;
    bpdata.bankMSB = 0x79;
    bpdata.bankLSB = 0;
    bpdata.presetID = (UInt8)0;
    AudioUnitSetProperty(_synthUnit,
                         kAUSamplerProperty_LoadInstrument,
                         kAudioUnitScope_Global,
                         0, &bpdata, sizeof(bpdata));
    
    AudioUnitAddPropertyListener(_ioUnit,
                                 kAudioUnitProperty_IsInterAppConnected,
                                 AudioUnitPropertyChanged,
                                 (__bridge void*)self);
    
    AudioOutputUnitMIDICallbacks callbacks;
    callbacks.userData = (__bridge void*)self;
    callbacks.MIDIEventProc = AudioUnitMIDIEvent;
    callbacks.MIDISysExProc = NULL;
    AudioUnitSetProperty(_ioUnit,
                         kAudioOutputUnitProperty_MIDICallbacks,
                         kAudioUnitScope_Global,
                         0,
                         &callbacks,
                         sizeof(callbacks));
    
    // 10
    CAShow(_audioGraph);
}

- (void)startStopGraphAsRequired {
    if (_connected || _inForeground) {
        [self startAUGraph];
    } else if (!_inForeground) {
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

- (void)audioUnitPropertyChanged:(void *)object unit:(AudioUnit)unit propID:(AudioUnitPropertyID)propID scope:(AudioUnitScope)scope element:(AudioUnitElement)element {
    if (propID == kAudioUnitProperty_IsInterAppConnected) {
        if (unit == _effectUnit) {
            UInt32 connected;
            UInt32 dataSize = sizeof(UInt32);
            AudioUnitGetProperty(_effectUnit, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize);
            
            _connected = (BOOL)connected;
            
            if (!_connected && _effectNode) {
                [self stopAUGraph];
                
                AUGraphDisconnectNodeInput(_audioGraph, _effectNode, 0);
                AUGraphRemoveNode(_audioGraph, _effectNode);
                _effectIconImageView.image = nil;
                _effectNode = 0;
                _effectUnit = NULL;
                
                _effectIconImageView.image = nil;
                
                AUGraphConnectNodeInput(_audioGraph,
                                        _synthNode,
                                        0,
                                        _ioNode,
                                        0);
            }
            
            [self startStopGraphAsRequired];
        } else if (unit == _ioUnit) {
            UInt32 connected;
            UInt32 dataSize = sizeof(UInt32);
            AudioUnitGetProperty(_ioUnit, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize);
            
            _connected = (BOOL)connected;
            
            [self startStopGraphAsRequired];
        }
    }
}

- (void)audioUnitMIDIEvent:(void *)object status:(UInt32)status data1:(UInt32)data1 data2:(UInt32)data2 offsetSampleFrame:(UInt32)offsetSampleFrame {
    MusicDeviceMIDIEvent(_synthUnit, status, data1, data2, offsetSampleFrame);
}

- (void)connectEffect:(Effect*)effect {
    // 1
    [self stopAUGraph];
    
    // 2
    AUNode newEffectNode;
    AudioComponentDescription desc = effect.componentDescription;
    AUGraphAddNode(_audioGraph, &desc, &newEffectNode);
    
    // 3
    if (newEffectNode) {
        // 4
        if (_effectNode) {
            AUGraphDisconnectNodeInput(_audioGraph, _effectNode, 0);
            AUGraphRemoveNode(_audioGraph, _effectNode);
            _effectIconImageView.image = nil;
            _effectUnit = NULL;
        }
        
        // 5
        _effectNode = newEffectNode;
        
        // 6
        AUGraphNodeInfo(_audioGraph, _effectNode, 0, &_effectUnit);
        
        // 7
        AudioUnitAddPropertyListener(_effectUnit,
                                     kAudioUnitProperty_IsInterAppConnected,
                                     AudioUnitPropertyChanged,
                                     (__bridge void*)self);
        
        // 8
        AUGraphDisconnectNodeInput(_audioGraph, _ioNode, 0);
        
        // 9
        AUGraphConnectNodeInput(_audioGraph,
                                _effectNode,
                                0,
                                _ioNode,
                                0);
        
        // 10
        AUGraphConnectNodeInput(_audioGraph,
                                _synthNode,
                                0,
                                _effectNode,
                                0);
        
        // 11
        _connected = YES;
        _effectIconImageView.image = effect.icon;
    } else {
        NSLog(@"Failed to obtain effect audio unit.");
    }
    
    // 12
    [self startAUGraph];
    CAShow(_audioGraph);
}

- (void)publishAsNode {
    AudioComponentDescription desc = {
        kAudioUnitType_RemoteInstrument,
        'iasp',
        'i7bt',
        0,
        0
    };
	AudioOutputUnitPublish(&desc, CFSTR("iGuitar"), 1, _ioUnit);
}


#pragma mark - MIDI

- (void)noteOn:(NSUInteger)note {
    UInt32 noteCommand = (0x9 << 4) | 0;
    MusicDeviceMIDIEvent(_synthUnit, noteCommand, (UInt32)note, 100, 0);
}

- (void)noteOff:(NSUInteger)note {
    UInt32 noteCommand = (0x8 << 4) | 0;
    MusicDeviceMIDIEvent(_synthUnit, noteCommand, (UInt32)note, 100, 0);
}


#pragma mark - GuitarNeckDelegate

- (void)guitarNeck:(GuitarNeck *)guitarNeck didStartNote:(NSUInteger)note {
    [self noteOn:note];
}

- (void)guitarNeck:(GuitarNeck *)guitarNeck didStopNote:(NSUInteger)note {
    [self noteOff:note];
}


#pragma mark - SelectEffectViewControllerDelegate

- (void)selectEffectViewControllerWantsToClose:(SelectEffectViewController*)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectEffectViewController:(SelectEffectViewController*)viewController didSelectEffect:(Effect*)effect {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self connectEffect:effect];
}

@end
