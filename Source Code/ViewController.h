//
//  ViewController.h
//  Squeak
//
//  Created by Jim McGowan on 2/2/12.
//  Copyright (c) 2012 Jim McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWVector.h"
#import "fmod.h"
#import "fmod_event.h"
#import "fmod_errors.h"

#define MAX_FMOD_AUDIO_CHANNELS 10


@interface ViewController : UIViewController
{
	NSMutableDictionary *previousTouchTimestamps;
	NSMutableDictionary *fmodEventsForTouches;
	
	FMOD_EVENTSYSTEM *eventSystem;
	FMOD_EVENTGROUP *eventGroup;
}

@end
