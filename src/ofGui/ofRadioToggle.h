#pragma once

#include "ofPanel.h"
#include "ofToggle.h"

class ofRadioToggle : public ofBaseGui{
	friend class ofPanel;

public:
    ofRadioToggle* setup(string tempName, int numButtons){
        name = tempName;
		b.x = 0;
		b.y = 0;
		b.width = defaultWidth;
		b.height = defaultWidth * numButtons;
		currentFrame = 0;			
		bGuiActive = true;
        return this;
    }
    
    void addButton(ofToggle* button){
        buttons.push_back(button);
    }
    
    int getSelected(){
        return selected;
    }
    
	virtual void mousePressed(ofMouseEventArgs & args){
        setValue(args.x, args.y, true);
	}
	
	virtual void mouseReleased(ofMouseEventArgs & args){	
	}
    
    virtual void mouseDragged(ofMouseEventArgs & args){
	}
    
    virtual void mouseMoved(ofMouseEventArgs & args){
	}
	
    virtual void saveToXml(ofxXmlSettings& xml) {
		cout << "warning we need to check for spaces in a name" << endl;	
		xml.addValue(name, selected);
	}
	
	virtual void loadFromXml(ofxXmlSettings& xml) {
		cout << "warning we need to check for spaces in a name" << endl;		
		selected = xml.getValue(name, selected);
	}
    
    void setValue(float mx, float my, bool bCheckBounds){
        for(int i=0;i < buttons.size();i++){
            if(buttons[i]->getValue() == true){
                buttons[i]->setVal(false);
            }
            buttons[i]->setValue(mx, my, true);
            if(buttons[i]->getValue() == true){
                selected = i;
            }
        }
    }
    
    void draw(){
        for(int i=0;i < buttons.size();i++){
            buttons[i]->draw();
        }
    }
    
    vector<ofToggle*> buttons;
    
protected:
    int selected;
};