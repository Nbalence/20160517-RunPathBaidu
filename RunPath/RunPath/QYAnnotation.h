//
//  QYAnnotation.h
//  RunPath
//
//  Created by qingyun on 16/5/17.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum : NSUInteger {
    kAnnotationBegion,
    kAnnotationPause,
    kAnnotationEnd,
    KAnnotationCurrent
} QYAnnotationType;

@interface QYAnnotation : NSObject<MKAnnotation>

//标注点模型的数据
@property (nonatomic)CLLocationCoordinate2D coordinate;//位置
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic)QYAnnotationType type;

@end
