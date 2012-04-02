//
//  GDMediaPlayer.h
//  Prop Phone
//
//  Created by Chris Lavender on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class GDMediaPlayer;
@protocol GDMediaPlayerDelegate
- (void)mediaPlayerIsPlaying:(BOOL)state;
- (void)currentTrackChanged:(GDMediaPlayer*)requestor;
@end

@interface GDMediaPlayer : NSObject <AVAudioPlayerDelegate> {

    NSURL					*soundFileURL;    
    BOOL                    itunesLib;

}
@property (unsafe_unretained, nonatomic)   id<GDMediaPlayerDelegate> delegate;

@property (strong, nonatomic, readonly) MPMusicPlayerController *musicPlayer;
@property (strong, nonatomic, readonly) MPMediaItemCollection   *userMediaCollection;

@property (strong, nonatomic, readonly) NSString                *currentTrack;

@property (nonatomic) NSInteger index;

- (void)updatePlayerQueueWithMediaCollection:(MPMediaItemCollection *)collection;
- (void)setupApplicationAudio;

- (void)playerTransport:(NSString*)action;
- (void)setLoopMode:(BOOL)switchVal;
- (void)setSoundMode:(BOOL)switchVal;

- (void)playSound;
- (void)pauseSound;
- (void)stopSound;
- (void)testPlay:(NSInteger)index;
- (void)playDefault;

@end
