//
//  gestures.mm
//  iScrub
//
//  Created by Zach  Gold on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ofxiPhoneExtras.h"
#import "testApp.h"

@interface EAGLView (Gestures) <UIGestureRecognizerDelegate>

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
- (IBAction)handleRotateGesture:(UIRotationGestureRecognizer *)sender;

@end



@implementation EAGLView (Gestures)

// scale the piece by the current scale
// reset the gesture recognizer's scale to 1 after applying so the next callback is a delta from the current scale
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
	
	if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
		
		testApp *myApp;
		myApp = (testApp*)ofGetAppPtr();
		myApp->pinch([sender scale], [sender locationInView:self]);
		myApp->isPinching = YES;
		
		[sender setScale:1];
	}
	else {
		testApp *myApp;
		myApp = (testApp*)ofGetAppPtr();
		myApp->isPinching = NO;
	}
	
}

// rotate the piece by the current rotation
- (IBAction)handleRotateGesture:(UIRotationGestureRecognizer *)sender {
	
	if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
		
		testApp *myApp;
		myApp = (testApp*)ofGetAppPtr();
		myApp->rotate([sender rotation], [sender locationInView:self]);
		myApp->isRotating = YES;
	}
	else {
		testApp *myApp;
		myApp = (testApp*)ofGetAppPtr();
		myApp->isRotating = NO;
	}
	
}

// enable simultaneous pinch and rotate
- (BOOL)gestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPinchGestureRecognizer *)otherGestureRecognizer {
	return YES;
}


@end