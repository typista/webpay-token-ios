//
//  WPYAbstractCardFieldSubclass.h
//  Webpay
//
//  Created by yohei on 5/17/14.
//  Copyright (c) 2014 yohei, YasuLab. All rights reserved.
//

#import "WPYAbstractCardField.h"

@interface WPYAbstractCardField ()
// protected setter
// setText is for client setting value
// updateText is protected & common procedure for setting text.
- (void)updateText:(NSString *)text;
@end
