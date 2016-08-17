//
//  MapViewController.m
//  Vision
//
//  Created by dllo on 16/3/23.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface MapViewController ()<MAMapViewDelegate , AMapSearchDelegate>
@property(nonatomic,retain)MAMapView *mapView;
@property(nonatomic,retain)AMapSearchAPI *search;
@property(nonatomic,retain)UIButton *locationButton;
@property(nonatomic,retain)MAPointAnnotation *pointAnnotation;
@property(nonatomic,retain)NSArray *pathPolylines;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"FZLTZCHJW--GB1-0" size:20];
    titleLabel.text = self.city;
    self.navigationItem.titleView = titleLabel;
    
    [self setNavigationItem];
    [self createView];
    [self createSearch];
}

- (void)setNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createView {
    
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"dbadd3f05af273bb99cd27536ad32988";
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.mapView setZoomLevel:16.1 animated:YES];
    self.mapView.showsUserLocation = YES;
    
    //大头针
    self.pointAnnotation = [[MAPointAnnotation alloc] init];
    self.pointAnnotation.coordinate = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    [_mapView addAnnotation:self.pointAnnotation];
    //将要定位的位置设置成中心
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]) animated:YES];
}

-(void)createSearch{
    
    [AMapSearchServices sharedServices].apiKey = @"dbadd3f05af273bb99cd27536ad32988";
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:[self.latitude floatValue] longitude:[self.longitude floatValue]];
    
    NSLog(@"%@,%@",self.latitude, self.longitude);
    regeo.radius = 10000;
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeo];
    
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    request.origin = [AMapGeoPoint locationWithLatitude:32.994949 longitude:116.447265];
    request.destination = [AMapGeoPoint locationWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    request.strategy = 2;//距离优先
    request.requireExtension = YES;
    
    //发起路径搜索
    [_search AMapDrivingRouteSearch: request];
    
}

//显示大头针的位置信息
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0) {
        title = response.regeocode.addressComponent.province;
    }
    self.pointAnnotation.title = title;
    self.pointAnnotation.subtitle = response.regeocode.formattedAddress;
}

//大头针的设置
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.canShowCallout = YES;
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
