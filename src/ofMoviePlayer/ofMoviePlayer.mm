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

#include "ofMoviePlayer.h"

//--------------------------------------------------------------
ofMoviePlayer::ofMoviePlayer()
{
	playFrame = 0;
    direction = YES;
    frameRate = 30;
}

//--------------------------------------------------------------
ofMoviePlayer::~ofMoviePlayer()
{
	frameBuffer.clear();
}
//--------------------------------------------------------------
void ofMoviePlayer::handler()
{    
	AVAssetTrack *videoTrack = nil;
	NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
	
	if ([tracks count] == 1)	
	{
		videoTrack = [tracks objectAtIndex:0];
		//frameRate = (int)[videoTrack nominalFrameRate];
		
		NSError *error = nil;
		NSString *key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
		NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
		NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
		
		reader = [AVAssetReader alloc];	
		reader = [reader initWithAsset:asset error:&error];     
		[reader addOutput:[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoSettings]];
        //[reader timeRange] = CMTimeRangeMake(CMTimeMakeWithSeconds(beginning, 600), CMTimeMakeWithSeconds(end, 600));
        [reader startReading];
        while(reader.status == AVAssetReaderStatusReading){
            AVAssetReaderTrackOutput * output = [reader.outputs objectAtIndex:0];
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
            tempFrameBuffer.push_back(sampleBuffer);
        }
    
        frameBuffer.swap(tempFrameBuffer);
        playFrame = 0;
        previousTime = [NSDate timeIntervalSinceReferenceDate]; 
        tempFrameBuffer.clear();
        
        [reader release];
        //cout << "total frames: " << frameBuffer.size() << endl;
	}
    //[asset release]; //infinite loop error
}

//--------------------------------------------------------------
void ofMoviePlayer::loadMovie(string name)
{    
	vector<string> nameSplit = ofSplitString(name, ".");
	NSString *nameURL = [NSString stringWithCString: nameSplit[0].c_str() encoding: [NSString defaultCStringEncoding]];
	NSString *nameExtension = [NSString stringWithCString: nameSplit[1].c_str() encoding: [NSString defaultCStringEncoding]];
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:nameURL withExtension:nameExtension];
	
	asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
	width = [asset naturalSize].width;
	height = [asset naturalSize].height;
    tex.allocate(width,height,GL_RGB);
	duration = (int)(CMTimeGetSeconds([asset duration])*1000);
	timescale = asset.duration.timescale;
		
	[asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{handler();}];
}

//--------------------------------------------------------------*/
unsigned char* ofMoviePlayer::getPixelsFromBuffer(CMSampleBufferRef sampleBuffer)
{
	
			CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			
			// Lock the image buffer
			CVPixelBufferLockBaseAddress(imageBuffer, 0);
			
			// Get information of the image
			size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
			
			// Create Colorspace
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			
			void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
			
			// Get the data size for contiguous planes of the pixel buffer.
			size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
			
			// Create a Quartz direct-access data provider that uses data we supply
			CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
			
			// Create a bitmap image from data supplied by our data provider
			CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
			
			// Copy image data
			CFDataRef bitmapData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
			pixelByteDataLength = CFDataGetLength(bitmapData);
			
			if(!pixelsTmp)
				pixelsTmp = (unsigned char*)malloc(pixelByteDataLength);
			if(!Pixels)
				Pixels = (unsigned char*)malloc(pixelByteDataLength);
			
			int bytesPerPixel	= CGImageGetBitsPerPixel(cgImage)/8;
            if(bytesPerPixel == 3) bytesPerPixel = 4;
			
			CFDataGetBytes(bitmapData, CFRangeMake(0, pixelByteDataLength), pixelsTmp);
			
			//convert from BGRA to RGB
            int j = 0;
			for(int i = 0; i < pixelByteDataLength; i+= bytesPerPixel){
				Pixels[j+2] = pixelsTmp[i];
				Pixels[j+1] = pixelsTmp[i+1];
				Pixels[j] = pixelsTmp[i+2];
                j+=3;
			}
			
			CFRelease(bitmapData);
			CGImageRelease(cgImage);
			CGDataProviderRelease(provider);
			CGColorSpaceRelease(colorSpace);
			
			// Unlock the image buffer
			CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
			
			return Pixels;
}

//--------------------------------------------------------------
void ofMoviePlayer::play()
{	
    NSTimeInterval ellapsedTime = [NSDate timeIntervalSinceReferenceDate] - previousTime;
    previousTime = [NSDate timeIntervalSinceReferenceDate];
    cout<<ellapsedTime<<endl;
    
	if(direction == YES){
        playFrame += round(ellapsedTime / (1.0/frameRate));
	} else if(direction == NO){
		playFrame -= round(ellapsedTime / (1.0/frameRate));
	}
	
	if(playFrame <= 0) {		
		direction = YES;
		playFrame = 0;
    }else  if(playFrame >= (frameBuffer.size()-1)) {
		direction = NO;
		playFrame = frameBuffer.size()-2;
    }
    
    tex.loadData(getPixelsFromBuffer(frameBuffer.at(playFrame)), width, height, GL_RGB);
    NSTimeInterval sleepTime = (1.0/30);
    [NSThread sleepForTimeInterval:sleepTime];
    
}
//--------------------------------------------------------------
void ofMoviePlayer::pause()
{
	
}
//--------------------------------------------------------------
void ofMoviePlayer::stop()
{

}
//--------------------------------------------------------------
int ofMoviePlayer::getDuration()
{
	return duration;
}
//--------------------------------------------------------------
float ofMoviePlayer::getSpeed()
{
    return (frameRate/10);
}
//--------------------------------------------------------------
void ofMoviePlayer::setSpeed(float speed)
{
    frameRate = (int)(speed*10);
}
//--------------------------------------------------------------
int ofMoviePlayer::getPosition()
{

}
//--------------------------------------------------------------
void ofMoviePlayer::setPosition(int position)
{
    int frame = (position/duration) * (frameBuffer.size()-2);
    //cout<<"frame: "<<frame<<endl;
    tex.loadData(getPixelsFromBuffer(frameBuffer.at(frame)), width, height, GL_RGB);
}
//--------------------------------------------------------------
UInt8* ofMoviePlayer::getPixels()
{

}
//--------------------------------------------------------------
void ofMoviePlayer::setPixels(unsigned char* pixels)
{

}
//--------------------------------------------------------------
void ofMoviePlayer::draw(int x, int y)
{
    ofSetColor(255);
	tex.draw(x, y, width, height);
}
//--------------------------------------------------------------
void ofMoviePlayer::draw(int x, int y, int w, int h)
{
    ofSetColor(255);
	tex.draw(x, y, w, h);
}

