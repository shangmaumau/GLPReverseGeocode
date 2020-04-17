//
//  GLPReverseGeocode.m
//
//  Created by Michael Shang on 2020/2/16.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import "GLPReverseGeocode.h"
#import <Contacts/Contacts.h>
#import <CoreLocation/CLGeocoder.h>
#ifdef GLPAMapAvaliable
#import <AMapSearchKit/AMapSearchKit.h>
#endif
#ifdef GLPBaiduMapAvaliable
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#endif
#ifdef GLPGoogleMapsAvaliable
#import <GoogleMaps/GMSGeocoder.h>
#endif
#ifdef GLPMicrosoftMapsAvaliable
#import <MicrosoftMaps/MicrosoftMaps.h>
#endif

#import <objc/runtime.h>

/// Apple Maps service, which is the system default map service. Limited. DO NOT request too many times once.
/// Not global, current country only.
GLPGeocodeService const GLPGeocodeServiceApple = @"AppleReverseGeocode";
/// AMap service. China only. No limited.
GLPGeocodeService const GLPGeocodeServiceAMap = @"AMapReverseGeocode";
/// Baidu Map service. China only. No limited.
GLPGeocodeService const GLPGeocodeServiceBaidu = @"BaiduReverseGeocode";
/// Google Maps service. Global. No limited.
GLPGeocodeService const GLPGeocodeServiceGoogle = @"GoogleReverseGeocode";
/// Microsoft Maps is former Bing Maps, the display name is always in English. Global. No limited.
GLPGeocodeService const GLPGeocodeServiceMicrosoft = @"MicrosoftReverseGeocode";
/// Open Street Map service. Global. No limited.
GLPGeocodeService const GLPGeocodeServiceOpenStreet = @"OpenStreetReverseGeocode";

@implementation GLPGeocodeAddress

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordi address:(NSString *)address {
    
    if (self = [super init]) {
        _coordinate = coordi;
        _line = address;
    }
    return self;
}

@end

@interface GLPReverseGeocode ()
#ifdef GLPHasDelegate
<
#ifdef GLPAMapAvaliable
AMapSearchDelegate,
#endif
#ifdef GLPBaiduMapAvaliable
BMKGeoCodeSearchDelegate,
#endif
>
#endif

@property (nonatomic) CLLocationCoordinate2D coordi;
@property (nonatomic, strong) NSMutableArray<CLLocation *> *coordinates;
@property (nonatomic, strong) NSMutableArray<GLPGeocodeAddress *> *addresses;

#ifdef GLPAMapAvaliable
@property (nonatomic, strong) AMapSearchAPI *amapSerchAPI;
#endif

@end

@implementation GLPReverseGeocode

- (instancetype)initWithService:(GLPGeocodeService)aType {
    
    if (self = [super init]) {
        _service = aType;
        _coordinates = [NSMutableArray array];
        _addresses = [NSMutableArray array];
    }
    return self;
}

/// Reverse geocode with providing a coordinate.
/// @note This method will overwrite the completion handler block, so if you call it many times, the last one will return results, but all the calls before will have no results return.
/// @param aCoordi The coordinate.
/// @param rHandler  Completion handler block.
- (void)reverseGeocodeWithCoordinate:(CLLocationCoordinate2D)aCoordi completionHandler:(GLPGeocodeResultHandler)rHandler {
    
    /**
     The following three coordinates
     */
    // 140.468508,36.389491 Japan Mito
    // aCoordi = CLLocationCoordinate2DMake(36.389491, 140.468508);
    // -104.953127,39.734062 USA Denver
    // aCoordi = CLLocationCoordinate2DMake(39.734062, -104.953127);
    // 4.84194,45.721939 France Lyons
    // aCoordi = CLLocationCoordinate2DMake(45.721939, 4.84194);
    
    _resultHandler = [rHandler copy];
    [self reverseWithCoordinate:aCoordi];
}

- (void)reverseWithCoordinate:(CLLocationCoordinate2D)coordi {
    
    if ([self.service isEqualToString:GLPGeocodeServiceApple]) {
        [self appleReverseGeocode:coordi];
    }
#ifdef GLPAMapAvaliable
    else if ([self.service isEqualToString:GLPGeocodeServiceAMap]) {
        [self amapReverseGeocode:coordi];
    }
#endif
            
#ifdef GLPBaiduMapAvaliable
    else if ([self.service isEqualToString:GLPGeocodeServiceBaidu]) {
        [self baiduReverseGeocode:coordi];
    }
#endif
            
#ifdef GLPGoogleMapsAvaliable
    else if ([self.service isEqualToString:GLPGeocodeServiceGoogle]) {
        [self googleReverseGeocode:coordi];
    }
#endif
            
#ifdef GLPMicrosoftMapsAvaliable
    else if ([self.service isEqualToString:GLPGeocodeServiceMicrosoft]) {
        [self microsoftReverseGeocode:coordi];
    }
#endif
    
    else if ([self.service isEqualToString:GLPGeocodeServiceOpenStreet]) {
        [self openMapReverseGeocode:coordi];
    }
}

// MARK:- Apple Maps reverse geocode

- (void)appleReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordi.latitude longitude:coordi.longitude];
    CLGeocoder *_clGeocoder = CLGeocoder.new;
    
    __weak __typeof(self) weakSelf = self;
    [_clGeocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (weakSelf.resultHandler) {
            
            if (!error) {
                
                NSString *addressString = @"";
                NSString *postalAddress = @"";
                CLPlacemark *thePlacemark = placemarks.firstObject;
                CNPostalAddressFormatter *postalAddressFormatter = [CNPostalAddressFormatter new];
                
                if (@available(iOS 11.0, *)) {
                    
                    postalAddress = [postalAddressFormatter stringFromPostalAddress:thePlacemark.postalAddress];
                    
                } else {
                    
                    CNMutablePostalAddress *mPostalAddress = [[CNMutablePostalAddress alloc] init];
                    
                    mPostalAddress.ISOCountryCode = thePlacemark.ISOcountryCode;
                    mPostalAddress.country = thePlacemark.country;
                    mPostalAddress.postalCode = thePlacemark.postalCode;
                    mPostalAddress.state = thePlacemark.administrativeArea;
                    mPostalAddress.city = thePlacemark.locality;
                    mPostalAddress.street = thePlacemark.thoroughfare;
                    
                    if (@available(iOS 10.3, *)) {
                        mPostalAddress.subLocality = thePlacemark.subLocality;
                        mPostalAddress.subAdministrativeArea = thePlacemark.subAdministrativeArea;
                    }
                    
                    postalAddress = [postalAddressFormatter stringFromPostalAddress:[mPostalAddress copy]];
                }
                
                addressString = [postalAddress stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                
                GLPGeocodeAddress *geoAddress = [GLPGeocodeAddress new];
                /* The placemark's `name` property is usually a company or organization name. */
                geoAddress.line = [addressString stringByAppendingString:thePlacemark.name];
                geoAddress.coordinate = thePlacemark.location.coordinate;
                
                [weakSelf.addresses addObject:geoAddress];
                weakSelf.resultHandler(geoAddress, nil);
                
            } else {
                weakSelf.resultHandler(nil, error);
            }
        }
    }];
}

// MARK:- AMap reverse geocode

#ifdef GLPAMapAvaliable

- (void)amapReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    if (!_amapSerchAPI) {
        _amapSerchAPI = AMapSearchAPI.new;
        _amapSerchAPI.delegate = self;
    }
    
    AMapReGeocodeSearchRequest *regeo = [AMapReGeocodeSearchRequest new];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordi.latitude longitude:coordi.longitude];
    regeo.requireExtension = YES;
    regeo.radius = 500.0f;
    
    [_amapSerchAPI AMapReGoecodeSearch:regeo];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    if (self.resultHandler) {
        
        if (response.regeocode != nil) {
            
            GLPGeocodeAddress *geoAddress = [GLPGeocodeAddress new];
            geoAddress.line = response.regeocode.formattedAddress;
            geoAddress.coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
            self.resultHandler(geoAddress, nil);
        }
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if (self.resultHandler) {
        self.resultHandler(nil, error);
    }
}

#endif

// MARK:- Baidu Map reverse geocode

#ifdef GLPBaiduMapAvaliable

- (void)baiduReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseGeoCodeOption.location = coordi;
    reverseGeoCodeOption.isLatestAdmin = YES;
    
    BMKGeoCodeSearch *geocoderSearch = [[BMKGeoCodeSearch alloc] init];
    geocoderSearch.delegate = self;
    [geocoderSearch reverseGeoCode:reverseGeoCodeOption];
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (self.resultHandler) {
        
        if (!error) {
            GLPGeocodeAddress *geoAddress = [GLPGeocodeAddress new];
            geoAddress.line = [result.address stringByAppendingString:result.sematicDescription];
            geoAddress.coordinate = result.location;
            
            self.resultHandler(geoAddress, nil);
        } else {
            
            NSError *__error =  [NSError errorWithDomain:NSCocoaErrorDomain code:error userInfo:@{ NSLocalizedDescriptionKey: @"BMK geocode search reverse geocode error." }];
            self.resultHandler(nil, __error);
        }
    }
}

#endif

// MARK:- Google Maps reverse geocode

#ifdef GLPGoogleMapsAvaliable

- (void)googleReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    GMSGeocoder *gmsGeocoder = [GMSGeocoder geocoder];
    
    __weak __typeof(self) weakSelf = self;
    [gmsGeocoder reverseGeocodeCoordinate:coordi completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoResponse, NSError * _Nullable error) {
        
        if (weakSelf.resultHandler) {
            if (!error) {
                if (geoResponse.firstResult.lines.count > 0) {
                    GLPGeocodeAddress *geoAddress = [GLPGeocodeAddress new];
                    geoAddress.line = [geoResponse.firstResult.lines firstObject];
                    geoAddress.coordinate = geoResponse.firstResult.coordinate;
                    weakSelf.resultHandler(geoAddress, nil);
                }
            } else {
                weakSelf.resultHandler(nil, error);
            }
        }
    }];
}

#endif

// MARK:- Microsoft Maps reverse geocode

#ifdef GLPMicrosoftMapsAvaliable

- (void)microsoftReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    __weak typeof(self) weakSelf = self;
    [MSMapLocationFinder findLocationsAt:[MSGeopoint geopointWithLatitude:coordi.latitude longitude:coordi.longitude] withOptions:nil handleResultWith:^(MSMapLocationFinderResult * _Nonnull result) {
        
        if (weakSelf.resultHandler) {
            if (result.status == MSMapLocationFinderStatusSuccess) {
                MSMapLocation *rLocation = result.locations.firstObject;
                GLPGeocodeAddress *geoAddress = [GLPGeocodeAddress new];
                geoAddress.line = rLocation.displayName;
                CLLocationCoordinate2D originalCoordi = CLLocationCoordinate2DMake(rLocation.point.position.latitude, rLocation.point.position.longitude);
                geoAddress.coordinate = originalCoordi;
                
                weakSelf.resultHandler(geoAddress, nil);
            } else {
                NSError *__error =  [NSError errorWithDomain:NSCocoaErrorDomain code:result.status userInfo:@{ NSLocalizedDescriptionKey: @"Microsoft Maps reverse geocode error." }];
                weakSelf.resultHandler(nil, __error);
            }
        }
    }];
}

#endif

// MARK:- OpenMap reverse geocode

- (void)openMapReverseGeocode:(CLLocationCoordinate2D)coordi {
    
    NSString *urlHead = @"https://nominatim.openstreetmap.org/reverse?";
    NSString *urlBody = [NSString stringWithFormat:@"format=jsonv2&lat=%f&lon=%f&accept-language=en", coordi.latitude, coordi.longitude];
    NSString *getPath = [NSString stringWithFormat:@"%@%@", urlHead, urlBody];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:getPath]];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (weakSelf.resultHandler) {
            
            if (!error) {
                
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:nil];
                
                NSString *displayName = dataDictionary[@"display_name"];
                if (displayName.length > 0) {
                    CLLocationDegrees lati = [dataDictionary[@"lat"] doubleValue];
                    CLLocationDegrees longi = [dataDictionary[@"lon"] doubleValue];
                    
                    GLPGeocodeAddress *geoAddress = GLPGeocodeAddress.new;
                    geoAddress.line = displayName;
                    geoAddress.coordinate = CLLocationCoordinate2DMake(lati, longi);
                    
                    weakSelf.resultHandler(geoAddress, nil);
                }
                
            } else {
                weakSelf.resultHandler(nil, error);
            }
        }
    }];
    
    [dataTask resume];
    
}

@end
