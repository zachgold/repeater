#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofMoviePlayer.h"
#include "functionGraph.h"

class testApp : public ofxiPhoneApp {
	
public:
	
	void setup();
	void update();
	void draw();
	void exit();

	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
    //void touchCancelled(ofTouchEventArgs &touch);
	
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	ofMoviePlayer myMoviePlayer;
    
    void pinch(CGFloat scale, CGPoint location);
	void rotate(CGFloat rotation, CGPoint location);
    void addButton(string name);
	BOOL isPinching;
	BOOL isRotating;
	float previousAngle;
	CGPoint tangentLocation;
	functionGraph* myFunction;
    int playhead;
    int clipPlaying;
};


