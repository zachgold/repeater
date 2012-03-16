/*
 * ofMoviePlayer for iPhone
 *
 * Copyright 2010 (c) Zach Gold
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * ----------------------
 *
 * Requires iOS 4.0 or greater
 * 
 */

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#include "ofMain.h"

class ofMoviePlayer {
  public:
	ofMoviePlayer();
	~ofMoviePlayer();
	
	void loadMovie(string name);
	UInt8* getPixels();
	void setPixels(unsigned char* pixels);
	void draw(int x, int y);
	void draw(int x, int y, int w, int h);
	void play();
	void stop();
	void pause();
	float getSpeed();
	void setSpeed(float speed);
	int getPosition();
	void setPosition(int position);
	int getDuration();
	
	vector<CMSampleBufferRef> frameBuffer;
    vector<CMSampleBufferRef> tempFrameBuffer;

	int frameRate;
	
	size_t width;
	size_t height;
	unsigned char* Pixels;
	int duration;
	int position;
	int32_t timescale;
	int playFrame; 
	size_t pixelByteDataLength;
	
  private:
	ofTexture tex;
	AVAsset *asset;
	AVAssetReader *reader;
	unsigned char *pixelsTmp;
	void handler();
	unsigned char* getPixelsFromBuffer(CMSampleBufferRef sampleBuffer);
    BOOL direction;
    NSTimeInterval previousTime;
};




