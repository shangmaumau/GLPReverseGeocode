//
//  SceneDelegate.m
//  ReverseGeocodeSample
//
//  Created by 尚雷勋 on 2020/4/10.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import "SceneDelegate.h"
#import "ViewController.h"

#import <AMapFoundationKit/AMapServices.h>
#import <GoogleMaps/GMSServices.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <MicrosoftMaps/MSMapView.h>

#define AMapKey @"Use Your AMap Key"
#define BaiduMapKey @"Use Your Baidu Map Key"
#define MicrosoftMapsKey @"Use Your MS Maps Key"
#define GoogleServiceUniversalKey @"Use Your Google API Key"

@interface SceneDelegate ()<BMKGeneralDelegate>

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    /* Baidu Map register auth key and activate service. */
    BMKMapManager *mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [mapManager start:BaiduMapKey generalDelegate:nil];
    if (!ret) {
        NSLog(@"Start Baidu Map manager failed.");
    }
    
    /* AMap register set key. */
    [[AMapServices sharedServices] setApiKey:AMapKey];
    
    /* Microsoft Maps set key, this method is not so good, 'cause it binds the auth to map view where sometimes we don't need the map view but some other functions. */
    [MSMapView.new setCredentialsKey:MicrosoftMapsKey];
    
    /* Google Maps set key. */
    [GMSServices provideAPIKey:GoogleServiceUniversalKey];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:ViewController.new];
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end