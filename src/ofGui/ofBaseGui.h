#pragma once

#include "ofxXmlSettings.h"

const ofColor
headerBackgroundColor(64),
backgroundColor(0),
textColor(255),
fillColor(128);

const int textPadding = 4;
const int defaultWidth = 80;
const int defaultHeight = 16;

class ofBaseGui{
public:
	ofBaseGui(){
		bGuiActive = false;
	}
	
	virtual void mouseMoved(ofMouseEventArgs & args) = 0; //touchMoved
	virtual void mousePressed(ofMouseEventArgs & args) = 0; //touchDown
	virtual void mouseDragged(ofMouseEventArgs & args) = 0; //touchMoved
	virtual void mouseReleased(ofMouseEventArgs & args) = 0; //touchUp
    
    /*
    virtual void touchDown(ofTouchEventArgs &touch);
	virtual void touchMoved(ofTouchEventArgs &touch);
	virtual void touchUp(ofTouchEventArgs &touch);
	virtual void touchDoubleTap(ofTouchEventArgs &touch);
	*/
     
	virtual void setValue(float mx, float my, bool bCheckBounds) = 0;
	virtual void draw() = 0;
	
	void saveToFile(string filename) {
		ofxXmlSettings xml;
		saveToXml(xml);
		xml.saveFile(filename);
	}
	
	void loadFromFile(string filename) {
		ofxXmlSettings xml;
		xml.loadFile(filename);
		loadFromXml(xml);
	}
	
	virtual void saveToXml(ofxXmlSettings& xml) = 0;
	virtual void loadFromXml(ofxXmlSettings& xml) = 0;
	
	string name;
	unsigned long currentFrame;			
	ofRectangle b;
	bool bGuiActive;
}; 
