//
//  ViewController.h
//  ReverseGeocodeSample
//
//  Created by 尚雷勋 on 2020/4/10.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWidthScale         ([UIScreen mainScreen].bounds.size.width/375.0f)
#define kHeightScale        ([UIScreen mainScreen].bounds.size.height/667.0f)
// 屏幕宽度
#define kScreenWidth        ([UIScreen mainScreen].bounds.size.width)
// 屏幕高度
#define kScreenHeight       ([UIScreen mainScreen].bounds.size.height)
// 状态栏高度
#define kStatusBarHeight    ([UIApplication sharedApplication].statusBarFrame.size.height)
// 横屏：导航栏高度
#define kNavigationBarHeight 44.0
// 横屏：Tab Bar 高度
#define kTabBarHeight       49.0
// 横屏：导航栏高度 + 状态栏高度
#define kViewTopHeight      (kStatusBarHeight + kNavigationBarHeight)
// iPhone X 适配差值
#define kBottomSafeAreaHeight ([UIApplication sharedApplication].statusBarFrame.size.height>20.0?34.0:0.0)
#define kHeight_SegMentBackground 60

@interface ViewController : UIViewController


@end

