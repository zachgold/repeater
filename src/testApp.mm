#include "testApp.h"
#include "ofGui.h"


 ofPanel clips;
 ofRadioToggle videos;
 ofToggle elevator;
 ofToggle bubbles;
 ofToggle blinker;
 ofToggle whip;

 ofPanel slider;
 ofSlider speed;

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

	myMoviePlayer.loadMovie("elevator.m4v");
    clipPlaying = 0;
    
    clips.setup("clips", 5, 150);
    clips.add(videos.setup("videos", 4));
    videos.addButton(elevator.setup("elevator", true, 0));
    videos.addButton(bubbles.setup("bubbles", false, 1));
    videos.addButton(blinker.setup("blinker", false, 2));
    videos.addButton(whip.setup("whip", false, 3));
    
    slider.setup("slider", 0, 280);
    slider.add(speed.setup("speed", 1, .2, 5, false, ofGetWidth()));
    
    ofColor pcolor;
	pcolor.r = 191; 
	pcolor.g = 8;
	pcolor.b = 66;
    
	ofColor lcolor;
	lcolor.r = 10;
	lcolor.g = 92;
	lcolor.b = 115;
    
	ofColor fcolor;
	fcolor.r = 115;
	fcolor.g = 16;
	fcolor.b = 47;
    
	ofColor ecolor;
	ecolor.r = 135;
	ecolor.g = 126;
	ecolor.b = 0;
	
	myFunction = new functionGraph(2, 230, ofGetWidth()-4, 64, pcolor, lcolor, fcolor, ecolor);
	
	// Set up pinch gesture	
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
											  initWithTarget:ofxiPhoneGetGLView() action:@selector(handlePinchGesture:)];
    [ofxiPhoneGetGLView() addGestureRecognizer:pinchGesture];
	[pinchGesture setDelegate:ofxiPhoneGetGLView()];
	[pinchGesture release];
	isPinching = NO;
	
	// Set up rotation gesture
	UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc]
												  initWithTarget:ofxiPhoneGetGLView() action:@selector(handleRotateGesture:)];
	[ofxiPhoneGetGLView() addGestureRecognizer:rotateGesture];
	[rotateGesture setDelegate:ofxiPhoneGetGLView()];
	[rotateGesture release];
	isRotating = NO;
	previousAngle = 0.0f;
    
    playhead = 0;
}


//--------------------------------------------------------------
void testApp::update(){	
    //myMoviePlayer.play();
}
//--------------------------------------------------------------
void testApp::draw(){
    clips.draw();
    slider.draw();
    
    myFunction->refresh(isPinching, isRotating, tangentLocation.x, tangentLocation.y);
    if(playhead < myFunction->fWidth){
        myFunction->drawPlayhead(playhead);
        if(myFunction->getValue(playhead) != 0){
            int playTime = myFunction->getValue(playhead) * myMoviePlayer.duration;
            myMoviePlayer.setPosition(playTime);
            //why is playback not working correctly?
        }
        playhead++;
    } else{
        playhead = 0;
    }
    
    myMoviePlayer.draw(120, 5, 330, 220);
    
    NSTimeInterval sleepTime = 1.0 / (30 * speed.getValue());
    [NSThread sleepForTimeInterval:sleepTime];

}
//--------------------------------------------------------------
void testApp::exit(){
	
}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    if(clipPlaying != videos.getSelected()){
        clipPlaying = videos.getSelected();
        switch(clipPlaying){
            case 0: 
                myMoviePlayer.loadMovie("elevator.m4v");
                break;
            case 1: 
                myMoviePlayer.loadMovie("bubbles.m4v");
                break;
            case 2: 
                myMoviePlayer.loadMovie("blinker.m4v");
                break;
            case 3: 
                myMoviePlayer.loadMovie("whip.m4v");
                break;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
    myFunction->drag(touch.x, touch.y);
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
    myFunction->click(touch.x, touch.y);
}
//--------------------------------------------------------------
void testApp::pinch(CGFloat scale, CGPoint location){
	myFunction->scaleTangent(scale, location.x, location.y);
	tangentLocation = location;
}

//--------------------------------------------------------------
void testApp::rotate(CGFloat rotation, CGPoint location){
	myFunction->rotateTangent(rotation, location.x, location.y);
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

