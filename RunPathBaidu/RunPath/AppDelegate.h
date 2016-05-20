//
//  AppDelegate.h
//  RunPath
//
//  Created by qingyun on 16/5/16.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager *mapManager;

@end

