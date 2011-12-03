#include "functionGraph.h"
#include <vector>
#include <algorithm>
#include "math.h"
using namespace std;

functionGraph::functionGraph(int xPos, int yPos, int Width, int Height, ofColor pColor, ofColor lColor, ofColor fColor, ofColor eColor) {
	xPosition = xPos;
	yPosition = yPos;
	fWidth = Width;
	fHeight = Height;
	endWidth = xPos + Width;
	endHeight = yPos + Height;
	
	pointColor = pColor;
	lineColor = lColor;
	frameColor = fColor;
	eraseColor = eColor;
	
	bezierSpline.push_back(bezierVertex(xPosition, endHeight, xPosition, endHeight, xPosition, endHeight, 0, 0));
	bezierSpline.push_back(bezierVertex(endWidth, endHeight, endWidth, endHeight, endWidth, endHeight, 0, 0));
    
    values.resize(fWidth);
}

bezierVertex::bezierVertex(int pointx, int pointy) {
	pointX = pointx;
	pointY = pointy;
}

bezierVertex::bezierVertex(int pointx, int pointy, int tangentpointbackx, int tangentpointbacky, int tangentpointforwardx, int tangentpointforwardy, int midpointx, int midpointy) {
	pointX = pointx;
	pointY = pointy;
	tangentPointBackX = tangentpointbackx;
	tangentPointBackY = tangentpointbacky;
	tangentPointForwardX = tangentpointforwardx;
	tangentPointForwardY = tangentpointforwardy;
	midPointX = midpointx;
	midPointY = midpointy;
}

bool bezierVertex::compareX(const bezierVertex A, const bezierVertex B){
	return A.pointX<B.pointX;
}

void functionGraph::refresh(bool isPinching, bool isRotating, float tanLocX, float tanLocY) {
	
	float   ax, bx, cx;
	float   ay, by, cy;
	float   t, t2, t3;
	float   x, y;
	int resolution = 20;
	
	ofSetColor(eraseColor.r, eraseColor.g, eraseColor.b);
	ofFill();
	ofRect(xPosition, yPosition, fWidth, fHeight);
	
	glLineWidth(2);
	ofSetColor(frameColor.r, frameColor.g, frameColor.b);
	ofNoFill();
	ofRect(xPosition, yPosition, fWidth, fHeight);
	
	for(int i=1; i < bezierSpline.size(); i++){
		ofNoFill();
		glLineWidth(2);
		ofSetColor(lineColor.r, lineColor.g, lineColor.b);
		
		// polynomial coefficients
		cx = 3.0f * (bezierSpline[i-1].tangentPointForwardX - bezierSpline[i-1].pointX);
		bx = 3.0f * (bezierSpline[i].tangentPointBackX - bezierSpline[i-1].tangentPointForwardX) - cx;
		ax = bezierSpline[i].pointX - bezierSpline[i-1].pointX - cx - bx;
		
		cy = 3.0f * (bezierSpline[i-1].tangentPointForwardY - bezierSpline[i-1].pointY);
		by = 3.0f * (bezierSpline[i].tangentPointBackY - bezierSpline[i-1].tangentPointForwardY) - cy;
		ay = bezierSpline[i].pointY - bezierSpline[i-1].pointY - cy - by;
		
		ofBeginShape();
		for (int j = 0; j < resolution; j++){
			t 	=  (float)j / (float)(resolution-1);
			t2 = t * t;
			t3 = t2 * t;
			x = (ax * t3) + (bx * t2) + (cx * t) + bezierSpline[i-1].pointX;
			y = (ay * t3) + (by * t2) + (cy * t) + bezierSpline[i-1].pointY;
			ofVertex(x,y);
            values[x-xPosition] = (y - yPosition) / fHeight;
		}
		ofEndShape();
		
		ofFill();
		ofSetColor(pointColor.r, pointColor.g, pointColor.b);
		ofCircle(bezierSpline[i].pointX, bezierSpline[i].pointY, 5);
	}
	
	if(isPinching == true || isRotating == true){
		drawTangent(tanLocX, tanLocY);
	}
}

float functionGraph::getValue(int x){
    return values[x];
}

void functionGraph::drawPlayhead(int x){
    glLineWidth(1);
	ofSetColor(frameColor.r, frameColor.g, frameColor.b);
    ofLine(x+xPosition, yPosition, x+xPosition, endHeight);
}

void functionGraph::click(int x, int y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){  
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5){
                if(bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){
                    bezierSpline.erase(bezierSpline.begin()+i);	
                    break;
                }else{
                    bezierSpline[i].pointY = y;
                    break;
                }
            } else {
                if (x < bezierSpline[i].pointX) {
                    bezierSpline.insert(bezierSpline.begin()+ i, bezierVertex(x, y));
                    
                    bezierSpline[i].midPointX = 0;
                    bezierSpline[i].midPointY = 0;
                    bezierSpline[i].tangentPointBackX = x;
                    bezierSpline[i].tangentPointBackY = y;
                    bezierSpline[i].tangentPointForwardX = x;
                    bezierSpline[i].tangentPointForwardY = y;
                    break;
                }
            }
        }
    }
}

void functionGraph::drag(int x, int y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){ 
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5 && bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){ 
                bezierSpline[i].pointX = x;
                bezierSpline[i].pointY = y;
            }  
        }
    }
}

void functionGraph::erase(int x, int y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){ 
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5 && bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){ 
                bezierSpline.erase(bezierSpline.begin()+i);
                break;
            }  
        }
    }
}

void functionGraph::scaleTangent(float scale, float x, float y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){ 
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5 && bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){ 
                bezierSpline[i].tangentPointBackX *= scale;
                bezierSpline[i].tangentPointBackY *= scale;
                bezierSpline[i].tangentPointForwardX *= scale;
                bezierSpline[i].tangentPointForwardY *= scale;
            }  
        }
    }
}

void functionGraph::rotateTangent(float rotation, float x, float y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){ 
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5 && bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){  
                //X = d + rCosθ, Y = d + rSinθ
                float radius = sqrt( (bezierSpline[i].pointX - bezierSpline[i].tangentPointBackX)^2 + (bezierSpline[i].pointY - bezierSpline[i].tangentPointBackY)^2 );
                bezierSpline[i].tangentPointBackX += radius*cos(rotation);
                bezierSpline[i].tangentPointBackY += radius*sin(rotation);
                bezierSpline[i].tangentPointForwardX += radius*cos(rotation);
                bezierSpline[i].tangentPointForwardY += radius*sin(rotation);
            }  
        }
    }
}

void functionGraph::drawTangent(float x, float y){
    if((xPosition<x) && (x<(xPosition+fWidth)) && (yPosition<y) && (y<(yPosition+fHeight))){ 
        for(int i = 0; i < bezierSpline.size(); i++){
            if(bezierSpline[i].pointX <= x + 5 && bezierSpline[i].pointX >= x - 5 && bezierSpline[i].pointY <= y + 5 && bezierSpline[i].pointY >= y - 5){ 
                ofSetColor(frameColor.r, frameColor.g, frameColor.b);
                ofCircle(bezierSpline[i].tangentPointBackX, bezierSpline[i].tangentPointBackY, 3);
                ofCircle(bezierSpline[i].tangentPointForwardX, bezierSpline[i].tangentPointForwardY, 3);
                ofSetColor(0, 0, 0);
                ofLine(bezierSpline[i].tangentPointBackX, bezierSpline[i].tangentPointBackY, bezierSpline[i].tangentPointForwardX, bezierSpline[i].tangentPointForwardY);
                cout << "drawing tangent" << endl;
            }  
        }
    }
}
