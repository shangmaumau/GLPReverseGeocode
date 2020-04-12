

# 简介
示例提供了集合的六种地理坐标反编码的方法，分别为苹果地图，高德地图，百度地图，谷歌地图，微软地图（前必应地图），以及 OpenStreetMap 开放地图（OSM）。
除了苹果地图和 OSM ，其他几个地图服务，都需要导入相应的 SDK ，在 GLPReverseGeocode.h 中，如果导入了相应的 SDK ，则取消注释相应的 define 即可。
示例使用的是 CocoPods 导入方式，手动导入的，可能不需要尖括号导入。

# 使用
## 方式一
适用于同时触发多次请求的情况。在 resultHandler 中处理即可。
```objc
    __weak typeof(self) weakSelf = self;
    _geocode = [[GLPReverseGeocode alloc] initWithService:GLPGeocodeServiceApple];
    _geocode.resultHandler = ^(GLPGeocodeAddress * _Nullable address, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                // 此处处理 address
            }
        });
    };
    
    [_geocode reverseWithCoordinate:coordi];
```

## 方式二
适用于单次请求。
```objc
    [_geocode reverseGeocodeWithCoordinate:CLLocationCoordinate2DMake(lat, long) completionHandler:^(GLPGeocodeAddress * _Nullable address, NSError * _Nullable error) {
        if (!error) {
            // 在此处处理 address
        }
    }];
```

# License
GLPReverseGeocode 使用 [MIT license](http://opensource.org/licenses/MIT) 。