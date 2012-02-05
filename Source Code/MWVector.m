//
//  MWVector.m
//  Harmonious
//
//  Created by Jim McGowan on 14/07/2011.
//  Copyright 2011 Jim McGowan. All rights reserved.
//

#import "MWVector.h"


MWVector MWMakeVector(double angle, double magnitude)
{
	MWVector vector;
	vector.angle = angle;
	vector.magnitude = magnitude;
	return vector;
}


MWVector vectorForPoints(CGPoint startPoint, CGPoint endPoint)
{
	double xOffset = endPoint.x - startPoint.x;
	double yOffset = endPoint.y - startPoint.y;
	
	if( (xOffset == 0.0) && (yOffset == 0.0) )
	{
		return MWZeroVector;
	}
	
	if(xOffset == 0.0)
	{
		if (yOffset > 0.0)
		{
			return MWMakeVector(0.0, yOffset);
		}
		else 
		{
			return MWMakeVector(180.0, fabs(yOffset));
		}
	}
	
	if(yOffset == 0.0)
	{
		if (xOffset > 0.0) 
		{
			return MWMakeVector(90.0, xOffset);
		}
		else 
		{
			return MWMakeVector(270, fabs(xOffset));
		}
	}
	
	
	NSInteger quadrant = 0;
	
	if( (xOffset > 0.0) && (yOffset < 0.0) )
	{
		quadrant = 1;
	}
	else if( (xOffset < 0.0) && (yOffset < 0.0) )
	{
		quadrant = 2;
	}
	else if( (xOffset < 0.0) && (yOffset > 0.0) )
	{
		quadrant = 3;
	}
	
	double hypotenuse, opposite, adjacent;
	switch (quadrant) 
	{
		case 0:
		{
			adjacent = yOffset;
			opposite = xOffset;
			break;
		}
		case 1:
		{
			adjacent = xOffset;
			opposite = -yOffset;
			break;
		}
		case 2:
		{
			adjacent = -yOffset;
			opposite = -xOffset;
			break;
		}
		case 3:
		{
			adjacent = -xOffset;
			opposite = yOffset;
			break;
		}
		default:
			break;
	}
	
	hypotenuse = hypot(adjacent, opposite);
	
	double angleInRadians = asin(opposite / hypotenuse);
	double angleInDegrees = raidansToDegrees(angleInRadians);
	
	switch (quadrant) 
	{
		case 1:
			angleInDegrees += 90.0;
			break;
		case 2:
			angleInDegrees += 180.0;
			break;
		case 3:
			angleInDegrees += 270.0;
			break;
		default:
			break;
	}
	
	return MWMakeVector(angleInDegrees, hypotenuse);
}


double raidansToDegrees(double radianValue)
{
	return radianValue / (M_PI / 180.0);
}
