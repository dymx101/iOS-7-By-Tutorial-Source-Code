//
//  ViewController.m
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

#import "GuitarNeck.h"

@import AudioToolbox;
@import AudioUnit;
@import AVFoundation;

@interface ViewController () <GuitarNeckDelegate>
@property (nonatomic, weak) IBOutlet GuitarNeck *guitarNeck;
@end

@implementation ViewController {
    AUGraph _audioGraph;
    AudioUnit _synthUnit;
    AudioUnit _ioUnit;
    AUNode _synthNode;
    AUNode _ioNode;
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
    [self startStopGraphAsRequired];
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
    NewAUGraph(&_audioGraph);
    
	AudioComponentDescription synthUnitDescription;
	synthUnitDescription.componentType = kAudioUnitType_MusicDevice;
	synthUnitDescription.componentSubType = kAudioUnitSubType_Sampler;
	synthUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	synthUnitDescription.componentFlags = 0;
	synthUnitDescription.componentFlagsMask = 0;
	AUGraphAddNode(_audioGraph, &synthUnitDescription, &_synthNode);
    
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    AUGraphAddNode(_audioGraph, &iOUnitDescription, &_ioNode);
    
	AUGraphOpen(_audioGraph);
    
	AUGraphNodeInfo(_audioGraph, _synthNode, NULL, &_synthUnit);
    AUGraphNodeInfo(_audioGraph, _ioNode, NULL, &_ioUnit);
    
    AudioStreamBasicDescription format;
    format.mChannelsPerFrame = 2;
    format.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    format.mBytesPerFrame = sizeof(Float32);
    format.mBytesPerPacket = sizeof(Float32);
    format.mBitsPerChannel = 32;
    format.mFramesPerPacket = 1;
    
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
    
    AUGraphConnectNodeInput(_audioGraph,
                            _synthNode,
                            0,
                            _ioNode,
                            0);
    
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

@end
