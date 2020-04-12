//
//  ViewController.m
//  ReverseGeocodeSample
//
//  Created by 尚雷勋 on 2020/4/10.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "GLPReverseGeocode.h"

@interface ViewController ()

@property (nonatomic, strong) UISegmentedControl *servicesSegment;

@property (nonatomic, strong) UILabel *latiTitle;
@property (nonatomic, strong) UITextField *latiText;
@property (nonatomic, strong) UILabel *longiTitle;
@property (nonatomic, strong) UITextField *longiText;

@property (nonatomic, strong) UITextView *addressText;
@property (nonatomic, strong) UIButton *reverseButton;

@property (nonatomic, strong) GLPReverseGeocode *geocode;
@property (nonatomic) CLLocationCoordinate2D coordi;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSArray<NSString *> *titlesArray;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *titleToEnumDictionary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Reverse Geocode";
    self.view.backgroundColor = UIColor.whiteColor;
    
    _servicesSegment = [[UISegmentedControl alloc] initWithItems:self.fetchAvaliableServices];
    _servicesSegment.selectedSegmentIndex = 0;
    [_servicesSegment addTarget:self action:@selector(serviceChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_servicesSegment];
    
    _latiTitle = UILabel.new;
    _latiTitle.text = @"Latitude";
    _latiTitle.font = [UIFont boldSystemFontOfSize:17.0];
    _latiTitle.textAlignment = NSTextAlignmentCenter;
    _latiTitle.layer.borderColor = UIColor.blackColor.CGColor;
    _latiTitle.layer.borderWidth = 3.0f;
    
    [self.view addSubview:_latiTitle];
    
    _latiText = UITextField.new;
    _latiText.placeholder = @"Input latitude here";
    _latiText.keyboardType = UIKeyboardTypeDecimalPad;
    _latiText.borderStyle = UITextBorderStyleRoundedRect;
    
    // 116.242718,40.007402
    // 111.999553,32.600801
    _latiText.text = @"32.600801";
    
    [self.view addSubview:_latiText];
    
    _longiTitle = UILabel.new;
    _longiTitle.text = @"Longitude";
    _longiTitle.font = [UIFont boldSystemFontOfSize:17.0];
    _longiTitle.textAlignment = NSTextAlignmentCenter;
    _longiTitle.layer.borderColor = UIColor.blackColor.CGColor;
    _longiTitle.layer.borderWidth = 3.0f;
    
    [self.view addSubview:_longiTitle];
    
    _longiText = UITextField.new;
    _longiText.placeholder = @"Input longitude here";
    _longiText.keyboardType = UIKeyboardTypeDecimalPad;
    _longiText.borderStyle = UITextBorderStyleRoundedRect;
    
    _longiText.text = @"111.999553";

    [self.view addSubview:_longiText];
    
    _addressText = UITextView.new;
    _addressText.editable = NO;
    _addressText.font = [UIFont italicSystemFontOfSize:17.0];
    _addressText.layer.borderColor = UIColor.blackColor.CGColor;
    _addressText.layer.borderWidth = 3.0f;
    _addressText.contentInset = UIEdgeInsetsMake(4.0, 8.0, 4.0, 8.0);
    
    [self.view addSubview:_addressText];
    
    _reverseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reverseButton setTitle:@"Search" forState:UIControlStateNormal];
    [_reverseButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [_reverseButton addTarget:self action:@selector(reverseAction:) forControlEvents:UIControlEventTouchUpInside];
    _reverseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:_reverseButton];
    
    CGFloat padding = 16.0;
    CGFloat margin = 2.0;
    CGFloat wScale = UIScreen.mainScreen.bounds.size.width / 375.0;
    CGFloat hScale = UIScreen.mainScreen.bounds.size.height / 667.0;
    
    [_servicesSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(padding);
        make.right.equalTo(self.view.mas_right).offset(-padding);
        make.top.equalTo(self.view.mas_top).offset(padding+kViewTopHeight);
        make.height.mas_equalTo(30.0);
    }];
    
    [_latiTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.servicesSegment.mas_bottom).offset(margin*8.0);
        make.left.equalTo(self.view.mas_left).offset(padding);
        make.height.mas_equalTo(30.0*hScale);
        make.width.mas_equalTo(100.0*wScale);
    }];
    
    [_latiText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.servicesSegment.mas_bottom).offset(margin*8.0);
        make.left.equalTo(self.latiTitle.mas_right).offset(margin*4);
        make.right.equalTo(self.view.mas_right).offset(-padding);
        make.height.mas_equalTo(30.0*hScale);
    }];
    
    [_longiTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.latiTitle.mas_bottom).offset(margin*8.0);
        make.left.equalTo(self.view.mas_left).offset(padding);
        make.height.mas_equalTo(30.0*hScale);
        make.width.mas_equalTo(100.0*wScale);
    }];
    
    [_longiText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.latiTitle.mas_bottom).offset(margin*8.0);
        make.left.equalTo(self.longiTitle.mas_right).offset(margin*4);
        make.right.equalTo(self.view.mas_right).offset(-padding);
        make.height.mas_equalTo(30.0*hScale);
    }];
    
    [_addressText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.longiTitle.mas_bottom).offset(margin*10.0);
        make.left.equalTo(self.view.mas_left).offset(padding);
        make.right.equalTo(self.view.mas_right).offset(-padding);
        make.height.mas_equalTo(60.0*hScale);
    }];
    
    [_reverseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-padding);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(60.0*wScale, 60.0*wScale));
    }];
    
    __weak typeof(self) weakSelf = self;
    _geocode = [[GLPReverseGeocode alloc] initWithService:GLPGeocodeServiceApple];
    _geocode.resultHandler = ^(GLPGeocodeAddress * _Nullable address, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideProgressHUD];
            if (!error) {
                weakSelf.addressText.text = address.line;
            }
        });
    };
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResignFirstResponser:)];
    [self.view addGestureRecognizer:tapOnView];
}

- (NSArray<NSString *> *)fetchAvaliableServices {
    
    NSMutableDictionary *titleToEnum = NSMutableDictionary.dictionary;
    NSMutableArray *services = NSMutableArray.array;
    [services addObject:@"Apple"];
    [titleToEnum setValue:GLPGeocodeServiceApple forKey:@"Apple"];
#ifdef GLPAMapAvaliable
    [services addObject:@"AMap"];
    [titleToEnum setValue:GLPGeocodeServiceAMap forKey:@"AMap"];
#endif
#ifdef GLPBaiduMapAvaliable
    [services addObject:@"Baidu"];
    [titleToEnum setValue:GLPGeocodeServiceBaidu forKey:@"Baidu"];
#endif
#ifdef GLPGoogleMapsAvaliable
    [services addObject:@"Google"];
    [titleToEnum setValue:GLPGeocodeServiceGoogle forKey:@"Google"];
#endif
#ifdef GLPMicrosoftMapsAvaliable
    [services addObject:@"MS"];
    [titleToEnum setValue:GLPGeocodeServiceMicrosoft forKey:@"MS"];
#endif
    [services addObject:@"Open"];
    [titleToEnum setValue:GLPGeocodeServiceOpenStreet forKey:@"Open"];
    
    _titleToEnumDictionary = [titleToEnum copy];
    _titlesArray = [services copy];
    
    return [services copy];
}

- (void)tapResignFirstResponser:(UITapGestureRecognizer *)tapOnce {

    if ([_latiText isFirstResponder]) {
        [_latiText resignFirstResponder];
    }
    if ([_longiText isFirstResponder]) {
        [_longiText resignFirstResponder];
    }
}

- (void)serviceChanged:(UISegmentedControl *)segment {
    _geocode.service = _titleToEnumDictionary[_titlesArray[segment.selectedSegmentIndex]];
    if (self.lastCoordi.latitude != 0) {
        [self reverseCoordi:self.lastCoordi];
    }
}

- (CLLocationCoordinate2D)lastCoordi {
    return CLLocationCoordinate2DMake(_latiText.text.doubleValue, _longiText.text.doubleValue);
}

- (void)reverseAction:(UIButton *)sender {
    CLLocationDegrees lati = [_latiText.text doubleValue];
    CLLocationDegrees longi = [_longiText.text doubleValue];
    [self reverseCoordi:CLLocationCoordinate2DMake(lati, longi)];
}

- (void)reverseCoordi:(CLLocationCoordinate2D)coordi {
    [_geocode reverseWithCoordinate:coordi];
    [self showProgressHUD];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}

- (void)showProgressHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"reversing...";
    _hud = hud;
}

- (void)hideProgressHUD {
    if (_hud) {
        [_hud hideAnimated:YES];
    }
}


@end
