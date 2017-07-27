//
//  OpenCVWrapper.h
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 6/29/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
+(NSMutableArray *) getPixelIntensity: (UIImage *)image withEndpointsX: (NSMutableArray *)endpointsXCoordinates
          withEndpointsY: (NSMutableArray *)endpointsYCoordinates;

@end
