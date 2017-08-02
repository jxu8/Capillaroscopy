//
//  OpenCVWrapper.mm
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 6/29/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"
using namespace std;
//C++ syntax within function, Objective-C for function structure
//creating the vector to hold grayscale pixel intensity
typedef cv::Vec<uchar,1> pixelIntensity;

@implementation OpenCVWrapper
+(NSMutableArray *) getPixelIntensity: (UIImage *)image
           withEndpointsX: (NSMutableArray *)endpointsXCoordinates
          withEndpointsY: (NSMutableArray *)endpointsYCoordinates
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    int imageType = imageMat.type();
    if (imageType == 24) {
        cv::cvtColor(imageMat, imageMat, CV_RGB2GRAY); //make all images grayscale which the one-channel vector can hold
    }
    //cout << "image type is " << imageMat.type();
    //make sure pixel width, height, and voxel depth is 1.0 (can check in fiji)
    //array of x coordinates
    int countX = [endpointsXCoordinates count];
     float *arrayXCoordinates = new float[countX];
     for(int i=0; i<countX; i++) {
     arrayXCoordinates[i] = [[endpointsXCoordinates objectAtIndex:i] floatValue];
     }
    
    //array of y coordinates
    int countY = [endpointsYCoordinates count];
    float *arrayYCoordinates = new float[countY];
    for(int i=0; i<countY; i++) {
        arrayYCoordinates[i] = [[endpointsYCoordinates objectAtIndex:i] floatValue];
    }
    
    //create an array of points to use in lineiterator
    vector<cv::Point> arrayOfPoints(countX);
    for(int i = 0; i < countX; i++){
        //multipled by rows and cols to find the coordinate on the actual photo
        cv::Point point (arrayXCoordinates[i]*imageMat.cols, arrayYCoordinates[i]*imageMat.rows);
        arrayOfPoints[i] = point;
        //cout << arrayOfPoints[i] << ",";
    }

    //use lineiterator between each set of two points
    vector<pixelIntensity> allIntensityValues; //holds all the intensity values
    int lastElement = countX-1; //if countX is 6, then last element in iterator is when i = 5 b/c i starts at 0
    for (int i = 0; i < countX; i++){
        
        //will not create a lineiterator for last point
        if (i != lastElement){
            cv::LineIterator it(imageMat, arrayOfPoints[i], arrayOfPoints[i+1], 8, true);
            
            vector<pixelIntensity> someIntensityValues(it.count); //vector to hold the pixel intensity values called someIntensityValues
            //cout << p1 << ", " << p2;
            //cout <<imageMat.rows <<", " <<imageMat.cols;
            
            //add intensity values between two endpoints in an array
            for(int i = 0; i < it.count; i++, ++it) {
                someIntensityValues[i] = imageMat.at<pixelIntensity>(it.pos());
            }
            
            //add each element of someIntensityValues to all the intensity values
            for (int i = 0; i < someIntensityValues.size(); i++){
                allIntensityValues.push_back(someIntensityValues[i]);
            }
        }
    }
    
    //convert intensity values (uchar) to int then to NSMutableArray for swift
    NSMutableArray *allIntensityValuesForSwift = [NSMutableArray arrayWithCapacity:allIntensityValues.size()];
    for (int i = 0; i < allIntensityValues.size(); i++){
        NSNumber *pixelIntensityAsNSNumber = [NSNumber numberWithInt:(int)allIntensityValues[i][0]];
        [allIntensityValuesForSwift addObject:pixelIntensityAsNSNumber];
    }
    
    //to see if opencv rendered the image correctly:
    //cv::imwrite("/Users/xujr/Desktop/test.tif", imageMat);
    

    return allIntensityValuesForSwift;
}

//code that did not work, i.e. iOS image processing in opencv documentation
/*CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
 CGFloat cols = image.size.width;
 CGFloat rows = image.size.height;
 size_t bitpc = CGImageGetBitsPerComponent(image.CGImage);
 size_t bitpp = CGImageGetBitsPerPixel(image.CGImage);
 size_t bytepr = CGImageGetBytesPerRow(image.CGImage);
 int numOfChannels = bitpp/bitpc;
 cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 1 channels
 CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
 cols,                       // Width of bitmap
 rows,                       // Height of bitmap
 8,                          // Bits per component
 bytepr,              // Bytes per row
 colorSpace,                 // Colorspace
 kCGImageAlphaNoneSkipLast |
 kCGBitmapByteOrderDefault); // Bitmap info flags
 CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
 CGContextRelease(contextRef);
 cv::Point *p1 = new cv::Point( array[0],array[1]);
 cv::Point *p2 = new cv::Point( array[2],array[3]);
 cv::LineIterator it (grayImageMat, *p1, *p2, 8, true);
 vector<int> buf(it.count);
 for(int i = 0; i < it.count; i++, ++it) {
 buf[i] = imageMat.at<uchar>(it.pos());
 buf [i] = (int)**it;
 }*/



@end
