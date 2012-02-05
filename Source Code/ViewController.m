//
//  ViewController.m
//  Squeak
//
//  Created by Jim McGowan on 2/2/12.
//  Copyright (c) 2012 Jim McGowan. All rights reserved.
//

#import "ViewController.h"


// Convenience macro/function for logging FMOD errors
#define checkFMODError(e) _checkFMODError(__FILE__, __LINE__, e)
void _checkFMODError(const char *sourceFile, int line, FMOD_RESULT errorCode);

// Convenience function for constraining parameter values
float constrainFloat(float value, float lowerLimit, float upperLimit);



@implementation ViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self != nil)
	{
		previousTouchTimestamps = [[NSMutableDictionary alloc] init];
		fmodEventsForTouches = [[NSMutableDictionary alloc] init];
		
		// Initialize the FMOD event system
		checkFMODError(FMOD_EventSystem_Create(&eventSystem));
		checkFMODError(FMOD_EventSystem_Init(eventSystem, MAX_FMOD_AUDIO_CHANNELS, FMOD_INIT_NORMAL, NULL, FMOD_EVENT_INIT_NORMAL));
		
		// Load the FEV file
		NSString *fevPath = [[NSBundle mainBundle] pathForResource:@"Squeak" ofType:@"fev"];
		FMOD_EVENTPROJECT *project;
		checkFMODError(FMOD_EventSystem_Load(eventSystem, [fevPath UTF8String], FMOD_EVENT_INIT_NORMAL, &project));
		
		// Get the group that contains the finger drag (sqeak) event
		checkFMODError(FMOD_EventProject_GetGroup(project, "FingerDragGroup", true, &eventGroup));
		
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)dealloc
{
	checkFMODError(FMOD_EventSystem_Unload(eventSystem));	// unloads all projects
	checkFMODError(FMOD_EventSystem_Release(eventSystem));
}





#pragma mark - Touch Tracking

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *newTouch in touches)
	{
		[previousTouchTimestamps setObject:[NSNumber numberWithDouble:newTouch.timestamp] forKey:[NSNumber numberWithInteger:[newTouch hash]]];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// as this method will be called regulary, it is a good place to do the periodic update of the FMOD event system.
	FMOD_EventSystem_Update(eventSystem);
	
	// iterate through each moved touch
	for (UITouch *movedTouch in touches)
	{
		FMOD_EVENT *fingerDragEvent = NULL;
		
		// if there is currently an FMOD finger drag (squeak) event playing for this touch, then skip over it for now - individual snap sounds for each touch should not overlap
		fingerDragEvent = (FMOD_EVENT *)[(NSValue *)[fmodEventsForTouches objectForKey:[NSNumber numberWithInteger:[movedTouch hash]]] pointerValue];
		if (fingerDragEvent != NULL) 
		{
			FMOD_EVENT_STATE eventState;
			checkFMODError(FMOD_Event_GetState(fingerDragEvent, &eventState));
			if (eventState == FMOD_EVENT_STATE_PLAYING)
			{
				continue;
			}
		}
		
		
		// get the speed of the movement
		NSTimeInterval previousTimestamp = [[previousTouchTimestamps objectForKey:[NSNumber numberWithInteger:[movedTouch hash]]] doubleValue];
		CGPoint previousLocation = [movedTouch previousLocationInView:self.view];
		
		NSTimeInterval currentTimestamp = movedTouch.timestamp;
		CGPoint currentLocation = [movedTouch locationInView:self.view];
		
		double distanceMoved = vectorForPoints(previousLocation, currentLocation).magnitude;
		NSTimeInterval durationOfMove = currentTimestamp - previousTimestamp;
		
		double speed = distanceMoved / durationOfMove;
		
		
		
		// create an instance of the FMOD finger drag (squeak) event
		checkFMODError(FMOD_EventGroup_GetEvent(eventGroup, "FingerDrag", FMOD_EVENT_DEFAULT, &fingerDragEvent));
		
		// get the speed parameter of the event
		FMOD_EVENTPARAMETER *speedParam;
		checkFMODError(FMOD_Event_GetParameterByIndex(fingerDragEvent, 0, &speedParam));
		
		// get the required range of the parameter and constrain the speed value
		float min, max;
		checkFMODError(FMOD_EventParameter_GetRange(speedParam, &min, &max));
		float constrainedValue = constrainFloat(speed, min, max);
		
		// set the new value
		checkFMODError(FMOD_EventParameter_SetValue(speedParam, constrainedValue));
		
		// trigger the event
		checkFMODError(FMOD_Event_Start(fingerDragEvent));
		
		// add the event to the dictionary for this touch so we can check its state later
		[fmodEventsForTouches setObject:[NSValue valueWithPointer:fingerDragEvent] forKey:[NSNumber numberWithInteger:[movedTouch hash]]];
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *endedTouch in touches)
	{
		[previousTouchTimestamps removeObjectForKey:[NSNumber numberWithInteger:[endedTouch hash]]];
		[fmodEventsForTouches removeObjectForKey:[NSNumber numberWithInteger:[endedTouch hash]]];
	}
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *cancelledTouch in touches)
	{
		[previousTouchTimestamps removeObjectForKey:[NSNumber numberWithInteger:[cancelledTouch hash]]];
		[fmodEventsForTouches removeObjectForKey:[NSNumber numberWithInteger:[cancelledTouch hash]]];
	}
}



@end



void _checkFMODError(const char *sourceFile, int line, FMOD_RESULT errorCode)
{
	if (errorCode != FMOD_OK)
	{
		NSString *filename = [[NSString stringWithUTF8String:sourceFile] lastPathComponent];
		NSLog(@"%@:%d FMOD Error %d:%s", filename, line, errorCode, FMOD_ErrorString(errorCode));
	}
}


float constrainFloat(float value, float lowerLimit, float upperLimit)
{
	if (value < lowerLimit)
	{
		value = lowerLimit;
	}
	
	if (value > upperLimit)
	{
		value = upperLimit;
	}
	
	return value;
}

