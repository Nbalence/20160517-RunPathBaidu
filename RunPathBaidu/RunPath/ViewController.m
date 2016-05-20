//
//  ViewController.m
//  RunPath
//
//  Created by qingyun on 16/5/16.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "QYAnnotation.h"
@interface ViewController ()<CLLocationManagerDelegate, BMKMapViewDelegate>

//管理定位的对象
@property (nonatomic, strong)CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (nonatomic, strong)CLLocation *nowLocation;
@property (nonatomic, weak)QYAnnotation *nowAnnotaion;

@property (nonatomic, strong)NSMutableArray *lines;//存放路线经过的点
@property (nonatomic, strong)BMKPolyline *nowPolyline;//当前已经添加的覆盖层模型


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createdLocationManager];
    
    self.mapView.delegate = self;
    
    //初始化存放点的数组
    self.lines = [NSMutableArray array];
    
}

-(void)createdLocationManager{
    self.manager = [[CLLocationManager alloc] init];
    //结果的回调，代理
    self.manager.delegate = self;
    
    //向用户发出定位的申请, 授权状态没有决定
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestWhenInUseAuthorization];
    }
    
    //设置定位的精确度
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //设置更新位置的条件,单位是米
    self.manager.distanceFilter = 10.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)run:(id)sender {
    //判断GPS开关是否开
    if ([CLLocationManager locationServicesEnabled]) {
        [self.manager startUpdatingLocation];
    }
}



- (IBAction)pause:(id)sender {
    //停止位置更细
    [self.manager stopUpdatingLocation];
    
    //添加一个标注
    QYAnnotation *anno = [[QYAnnotation alloc] init];
    anno.coordinate = self.nowLocation.coordinate;
    anno.title = @"暂停";
    anno.type = kAnnotationPause;
    [self.mapView addAnnotation:anno];
    
}
- (IBAction)stop:(id)sender {
    //停止位置更细
    [self.manager stopUpdatingLocation];
    
    //添加一个标注
    QYAnnotation *anno = [[QYAnnotation alloc] init];
    anno.coordinate = self.nowLocation.coordinate;
    anno.title = @"停止";
    anno.type = kAnnotationEnd;
    [self.mapView addAnnotation:anno];
}


#pragma mark - locationn manager
//更新位置的代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    NSLog(@"%@", location);
    if (!self.nowLocation) {
        //更改地图的显示区域
        //显示的区域的跨度（长和宽）
        BMKCoordinateSpan span;
        span.latitudeDelta = 0.05;
        span.longitudeDelta = 0.05;
        //区域
        BMKCoordinateRegion region;
        region.center = location.coordinate;
        region.span = span;
        //地图显示在该区域
        [self.mapView setRegion:region animated:YES];
        
        //添加第一个点的标注
        QYAnnotation *beginAnno = [[QYAnnotation alloc] init];
        beginAnno.coordinate = location.coordinate;
        beginAnno.title = @"开始";
        beginAnno.type = kAnnotationBegion;//指定标记点的类型
        [self.mapView addAnnotation:beginAnno];
    }
    self.nowLocation = location;
    
    //将添加的上一个标记点移走
    if (self.nowAnnotaion) {
        [self.mapView removeAnnotation:self.nowAnnotaion];
    }
    
    //添加当前点的标注
    QYAnnotation *nowAnno = [[QYAnnotation alloc] init];
    nowAnno.coordinate = location.coordinate;
    nowAnno.title = @"当前位置";
    nowAnno.type = KAnnotationCurrent;
    
    //将标注点添加到地图上
    [self.mapView addAnnotation:nowAnno];
    self.nowAnnotaion = nowAnno;
    
    
    //移走之前添加的覆盖层
    if (self.nowPolyline) {
        [self.mapView removeOverlay:self.nowPolyline];
    }
    //将所经过的点都添加到数组中
    [self.lines addObject:location];
    //地图上添加曲线覆盖层
    CLLocationCoordinate2D coordinates[self.lines.count];
    for (int i = 0; i < self.lines.count; i++) {
        coordinates[i] = [self.lines[i] coordinate];
    }
    //初始化覆盖层模型
    BMKPolyline *line = [BMKPolyline polylineWithCoordinates:coordinates count:self.lines.count];
    //地图添加
    [self.mapView addOverlay:line];
    //更新覆盖层模型
    self.nowPolyline = line;
}

//-更新失败的方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

#pragma mark - map view

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    //如果是我们自己添加的类型，才进行处理
    if ([annotation isKindOfClass:[QYAnnotation class]]) {
        QYAnnotation *anno = (QYAnnotation *)annotation;
        NSString *idifiter = @"QYAnnotaion";
        //指定一个标识符，从复用队列出对
        BMKAnnotationView *view =[mapView dequeueReusableAnnotationViewWithIdentifier:idifiter];
        if (!view) {
            view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:idifiter];
        }
        view.annotation = annotation;
        view.canShowCallout = YES;
        //根据设置的标注的类型，设置不同的图片
        switch (anno.type) {
            case kAnnotationBegion:
            {
                [view setImage:[UIImage imageNamed:@"map_start_icon"]];
                [view setCenterOffset:CGPointMake(0, -12)];
            }
                break;
            case KAnnotationCurrent:
            {
                [view setImage:[UIImage imageNamed:@"currentlocation"]];
                [view setCenterOffset:CGPointMake(0, 0)];
            }
                break;
            case kAnnotationPause:
            {
                [view setImage:[UIImage imageNamed:@"map_susoend_icon"]];
                [view setCenterOffset:CGPointMake(0, -12)];
            }
                break;
            case kAnnotationEnd:
            {
                [view setImage:[UIImage imageNamed:@"map_stop_icon"]];
                [view setCenterOffset:CGPointMake(0, -12)];
            }
                break;
            default:
                break;
        }
        
        return view;
    }
    return nil;
}

//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    
//}

//根据添加的覆盖层模型，返回相应的覆盖层视图
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //覆盖层视图
        BMKPolylineView *renderer = [[BMKPolylineView alloc] initWithPolyline:overlay];
        renderer.lineWidth = 3.f;
        renderer.strokeColor = [UIColor blueColor];
        return renderer;
    }
    return nil;
}

//-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        //覆盖层视图
//        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
//        renderer.lineWidth = 3.f;
//        renderer.strokeColor = [UIColor blueColor];
//        return renderer;
//    }
//    return nil;
//}

@end
