//
//  GLPReverseGeocode.h
//
//  Created by Michael Shang on 2020/2/16.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Uncomment the define if you have import the service.

//#ifndef GLPAMapAvaliable
//#   define GLPAMapAvaliable
//#endif
//
//#ifndef GLPBaiduMapAvaliable
//#   define GLPBaiduMapAvaliable
//#endif

//#ifndef GLPGoogleMapsAvaliable
//#   define GLPGoogleMapsAvaliable
//#endif
//
//#ifndef GLPMicrosoftMapsAvaliable
//#   define GLPMicrosoftMapsAvaliable
//#endif


NS_ASSUME_NONNULL_BEGIN

@class GLPGeocodeAddress;

typedef NSString * GLPGeocodeService NS_STRING_ENUM;

FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceApple;
FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceAMap;
FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceBaidu;
FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceGoogle;
FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceMicrosoft;
FOUNDATION_EXPORT GLPGeocodeService const GLPGeocodeServiceOpenStreet;

/// A block that return reverse geocode results.
/// @note The error message is not in the same format, because we return the original `error` message except
/// Baidu Map which only return an error code.
/// @param address Address line.
/// @param error Error message.
typedef void(^GLPGeocodeResultHandler)(GLPGeocodeAddress * _Nullable address, NSError * _Nullable error);

@interface GLPGeocodeAddress : NSObject
/// Formatted address.
@property (nonatomic, copy) NSString *line;
/// Coordinate.
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordi address:(NSString *)address;

@end

/**
 Location info geocode.
 @discussion Main feature is reverse geocode.
 */
@interface GLPReverseGeocode : NSObject

/// Completion handler block.
@property (nonatomic, copy) GLPGeocodeResultHandler resultHandler;
@property (nonatomic, copy) GLPGeocodeService service;

- (instancetype)initWithService:(GLPGeocodeService)aType;
- (void)reverseWithCoordinate:(CLLocationCoordinate2D)coordi;

- (void)reverseGeocodeWithCoordinate:(CLLocationCoordinate2D)aCoordi completionHandler:(GLPGeocodeResultHandler)rHandler;

@end

NS_ASSUME_NONNULL_END
