/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFLocationModule Plugin.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YTFLocationModule : NSObject<MKMapViewDelegate,CLLocationManagerDelegate>
{

    NSString *  noViewCbid;
    id  noViewWebView;
     CLPlacemark *placeInfo;


}
@property(weak,nonatomic)MKMapView * mapView;
// 这个属性主要用来请求权限
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (nonatomic, strong) CLLocation *userLocation;

/**
 *  无界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)getLocation:(NSDictionary *)args;


/**
 *  无界面后台定位  停止
 *
 *  @param args JS传入的参数
 */
- (void)noViewStopLocation:(NSDictionary *)args;


/**
 *  y有界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)viewLocationMethod:(NSDictionary *)args;

@end
