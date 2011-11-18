#include "testApp.h"
#include "ofGui.h"


 ofPanel gui;
 ofSlider frameRate;
 ofToggle filled;

//--------------------------------------------------------------
void testApp::setup(){	
	
	// register touch events
	ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
	
	//If you want a landscape oreintation 
	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
    ofBackground(0,0,0);
    
	myMoviePlayer.loadMovie("Movie.m4v");
    
    gui.setup("panel", 0, 270);
	gui.add(filled.setup("toggle", true));
	gui.add(frameRate.setup("framerate", 1, 0, 3));
}


//--------------------------------------------------------------
void testApp::update(){	
    myMoviePlayer.play();
    myMoviePlayer.setSpeed(frameRate.getValue());
}
//--------------------------------------------------------------
void testApp::draw(){

    myMoviePlayer.draw(0, 0);
    gui.draw();
}
//--------------------------------------------------------------
void testApp::exit(){
	
}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::lostFocus(){
	
}

//--------------------------------------------------------------
void testApp::gotFocus(){
	
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
	
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
	
}

