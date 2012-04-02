//
//  GDMediaPlayer.m
//  Prop Phone
//
//  Created by Chris Lavender on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GDMediaPlayer.h"
#import <Foundation/Foundation.h>

@interface GDMediaPlayer()
{
    int tempIndex;
}
@property (strong, nonatomic, readwrite) MPMusicPlayerController *musicPlayer;
@property (strong, nonatomic, readwrite) MPMediaItemCollection   *userMediaCollection;
@property (strong, nonatomic)            AVAudioPlayer           *defaultSoundPlayer;
@property (strong, nonatomic, readwrite) NSString                *currentTrack;
- (void) musicPlayerStateDidChange:(NSNotification*)notification;
- (void) nowPlayingItemDidChange:(NSNotification*)notification;
@end

#pragma mark -
#pragma mark Audio session callbacks

// Audio session callback function for responding to audio route changes. If playing 
//		back application audio when the headset is unplugged, this callback pauses 
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback  
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
	// This callback, being outside the implementation block, needs a reference to the
	//		GDMediaPlayer object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to 
	//		AudioSessionAddPropertyListener).
	GDMediaPlayer *gdMediaPlayer = (__bridge GDMediaPlayer *) inUserData;
	
	// if application sound is not playing, there's nothing to do, so return.
	if (gdMediaPlayer.defaultSoundPlayer.playing == 0 ) {
        
		NSLog (@"Audio route change while application audio is stopped.");
		return;
		
	} else {
        
		// Determines the reason for the route change, to ensure that it is not
		//		because of a category change.
		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
		
		CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
		SInt32 routeChangeReason;
		
		CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
		
		// "Old device unavailable" indicates that a headset was unplugged, or that the
		//	device was removed from a dock connector that supports audio output. This is
		//	the recommended test for when to pause audio.
		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
			[gdMediaPlayer.defaultSoundPlayer pause];
			NSLog (@"Output device removed, so application audio was paused.");
            
			UIAlertView *routeChangeAlertView = 
            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
                                      delegate: gdMediaPlayer
                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
			[routeChangeAlertView show];
			// release takes place in alertView:clickedButtonAtIndex: method
            //CL added.
		} else {
            
			NSLog (@"A route change occurred that does not require pausing of application audio.");
		}
	}
}

@implementation GDMediaPlayer

@synthesize delegate;
@synthesize userMediaCollection=_userMediaCollection;
@synthesize musicPlayer=_musicPlayer, defaultSoundPlayer=_defaultSoundPlayer;
@synthesize currentTrack=_currentTrack;
@synthesize index=_index;

// keeps a reference to the track title
// and also reports to the delegate what it is 
// so the delegate can send the title to the controller.
- (void) setCurrentTrack:(NSString *)currentTrack
{
    if (currentTrack != _currentTrack)
    {
        _currentTrack = currentTrack;
        // NSLog(@"GDMediaPlayer.currentTrack:%@", _currentTrack);
        [self.delegate currentTrackChanged:self];
    }
}

// before playback the index is referenced
// this setter also sets the currentTrack title
- (void) setIndex:(NSInteger)index
{
    _index = index;
    // NSLog(@"GDMediaPlayer.index:%d",_index);
    
    if (self.userMediaCollection && itunesLib!= NO) {
        self.currentTrack = 
            [[self.userMediaCollection.items objectAtIndex:self.index] valueForProperty: MPMediaItemPropertyTitle];
    }
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        [self setupApplicationAudio];
    } 
    return self;
}

- (void)dealloc {
    
    if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [_musicPlayer stop];
    }
    
    
    [_defaultSoundPlayer stop];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification" 
                                                  object:_musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification" 
                                                  object:_musicPlayer];

    [_musicPlayer endGeneratingPlaybackNotifications];

    
}

- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) collection {
    [self.musicPlayer stop];
    
    //NSLog(@"MPMediaItemCollection count:%d", [collection count]);
    self.userMediaCollection = collection;
    [self.musicPlayer setQueueWithItemCollection: self.userMediaCollection];
    /*
    if (collection) {
        userMediaCollection = collection;
        [self.musicPlayer setQueueWithItemCollection: userMediaCollection];
     }
    else {
        userMediaCollection = collection;
        [self.musicPlayer setQueueWithItemCollection:nil];
    }*/
}

#pragma mark -
#pragma mark User-Selected Audio Transport

- (void)playerTransport:(NSString*)action {
    if ([action isEqualToString:@"play"]) [self playSound];
    else if ([action isEqualToString:@"pause"]) [self pauseSound];
    else [self stopSound];

}

- (void)playSound {
    if (itunesLib) {        
        if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
            self.musicPlayer.currentPlaybackTime = 0;
        }
        //printf("GDMediaPlayer musicPlayer play\n");
        if (self.musicPlayer.playbackState != MPMusicPlaybackStatePaused){
            self.musicPlayer.nowPlayingItem = 
            [self.userMediaCollection.items objectAtIndex:self.index];
            //tempIndex = self.index;
        }
        [self.musicPlayer play];
    }
    else {
        // self.currentTrack = @"Default Ringer";
        if ([self.defaultSoundPlayer isPlaying]) {
            self.defaultSoundPlayer.currentTime = 0;
        }
        // printf("play\n");
        [self.defaultSoundPlayer play];
    }
    [self.delegate mediaPlayerIsPlaying:YES];
}
- (void)pauseSound {
    if (itunesLib) {
        //printf("GDMediaPlayer musicPlayer paused\n");
        [self.musicPlayer pause];
    }
    else {
        //  printf("pause\n");
        [self.defaultSoundPlayer stop];
    } 
    [self.delegate mediaPlayerIsPlaying:NO];
}

- (void)stopSound {
    if (itunesLib) {
        [self.musicPlayer stop];
    }
    else {
        // printf("stop\n");
        [self.defaultSoundPlayer stop];
    }
    self.defaultSoundPlayer.currentTime = 0;
    [self.delegate mediaPlayerIsPlaying:NO];
}

- (void)testPlay:(NSInteger)index
{
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer stop];
    }
    self.musicPlayer.nowPlayingItem = [self.userMediaCollection.items objectAtIndex:index];
    
    [self.musicPlayer play];
}
#pragma mark -
#pragma mark Default Sound Audio Transport

- (void)playDefault {
    
	[self.defaultSoundPlayer play];
}

#pragma mark -
#pragma mark Audio Setup

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif

- (void) setupApplicationAudio {

	// Gets the file system path to the sound to play.
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tele"
                                                              ofType:@"mp3"];
    
	// Converts the sound's file path to an NSURL object
	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
	// Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setDelegate: self];
	
     // Use this code to allow the app sound to continue to play when the screen is locked.
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
     
     UInt32 doSetProperty = 0;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,
     sizeof (doSetProperty),
     &doSetProperty
     );
    
	// Registers the audio route change listener callback function
	AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge void *)(self)
                                     );
    
	// Activates the audio session.
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    
	// Instantiates the AVAudioPlayer object, initializing it with the sound
	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error: nil];
	self.defaultSoundPlayer = newPlayer;

	[self.defaultSoundPlayer prepareToPlay]; //ensures that playback starts quickly when the user taps Play
	[self.defaultSoundPlayer setVolume: 1.0];
	[self.defaultSoundPlayer setDelegate: self];
    
    // instantiate a music player
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    self.musicPlayer.repeatMode = MPMusicRepeatModeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(musicPlayerStateDidChange:) 
                                                 name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification" 
                                               object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(nowPlayingItemDidChange:) 
                                                 name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification" 
                                               object:self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
}

- (void)setLoopMode:(BOOL)switchVal {
    if (switchVal) {
        self.musicPlayer.repeatMode = MPMusicRepeatModeOne;
        self.defaultSoundPlayer.numberOfLoops = -1;
        // printf("GDMediaPlayer setLoopMode ON\n");
    }
    else {
        self.musicPlayer.repeatMode = MPMusicRepeatModeNone;
        self.defaultSoundPlayer.numberOfLoops = 0;
        // printf("GDMediaPlayer setLoopMode OFF\n");
    }
}

- (void)setSoundMode:(BOOL)switchVal {
    // NSLog(@"itunesLib is ON? %@", switchVal == YES ? @"YES" : @"NO");
    if (switchVal != itunesLib) [self stopSound];
    itunesLib = switchVal;
    
    if (!itunesLib) {
        self.currentTrack = @"Default Ringer";
    }
}

#pragma mark -
#pragma mark AVAudioPlayer Delegate Method Impementations

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate mediaPlayerIsPlaying:NO];
}

#pragma mark -
#pragma mark MPMusicPlayerController Notification Method

// to report if something is playing, mediaPlayerIsPlaying Delegate method is also called above.
- (void) musicPlayerStateDidChange:(NSNotification *)notification {
    // printf("music player changed state\n");
    
    // check to see if the player is playing.
    // if not then let delegate know about it.
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped || 
        self.musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
        [self.delegate mediaPlayerIsPlaying:NO];
    }
}

- (void) nowPlayingItemDidChange:(NSNotification *)notification {
    // printf("nowItem changed\n");
    
    // check to see if the new nowPlayingItem equals the currentTrack
    // if not then stop the player
    if (![[self.musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyTitle]isEqualToString:self.currentTrack]) {
        // printf("nowPlayingItemDidChange notification stopped musicPlayer\n");
        [self.musicPlayer stop];
    }
}

@end
