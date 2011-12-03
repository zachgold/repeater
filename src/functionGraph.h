#ifndef _FUNCTION_GRAPH
#define _FUNCTION_GRAPH

#include "ofMain.h"

class bezierVertex{
public:
	bezierVertex(int pointx, int pointy);
	bezierVertex(int pointx, int pointy, int tangentpointbackx, int tangentpointbacky, int tangentpointforwardx, int tangentpointforwardy, int midpointx, int midpointy);
	int pointX;
	int pointY;
	int midPointX;
	int midPointY;
	int tangentPointBackX;
	int tangentPointBackY;
	int tangentPointForwardX;
	int tangentPointForwardY;
	static bool compareX(const bezierVertex A, const bezierVertex B);
};

class functionGraph{
	
	vector<bezierVertex> bezierSpline;
    vector<float> values;

	int xPosition;
	int yPosition;
	int endWidth;
	int endHeight;
	
	ofBaseApp* parent;
	
	ofColor pointColor;
	ofColor lineColor;
	ofColor frameColor; 
	ofColor eraseColor;
	
	public:
	functionGraph(int xPos, int yPos, int Width, int Height, ofColor pColor, ofColor lColor, ofColor fColor, ofColor eColor);
	void refresh(bool isPinching, bool isRotating, float tanLocX, float tanLocY);
	void click(int x, int y);
	void drag(int x, int y);
	void scaleTangent(float scale, float x, float y);
	void rotateTangent(float rotation, float x, float y);
	void drawTangent(float x, float y);
	void erase(int x, int y);
    float getValue(int x);
    void drawPlayhead(int x);
    int fWidth;
	int fHeight;
};

#endif