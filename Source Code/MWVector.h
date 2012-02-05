//
//  MWVector.h
//  Malkinware
//
//  Created by Jim McGowan on 14/07/2011.
//  Copyright 2011 Jim McGowan. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>

typedef struct _MWVector {
	double angle;
	double magnitude;
} MWVector; // angle is in degrees

#define MWZeroVector MWMakeVector(0.0, 0.0)

MWVector MWMakeVector(double angle, double magnitude);
MWVector vectorForPoints(CGPoint startPoint, CGPoint endPoint);
double raidansToDegrees(double radianValue);
