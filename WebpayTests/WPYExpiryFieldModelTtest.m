//
//  WPYExpiryFieldModelTtest.m
//  Webpay
//
//  Created by yohei on 5/5/14.
//  Copyright (c) 2014 yohei, YasuLab. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WPYExpiryFieldModel.h"

@interface WPYExpiryFieldModelTtest : XCTestCase

@end

@implementation WPYExpiryFieldModelTtest
{
    WPYExpiryFieldModel *_model;
}

- (void)setUp
{
    [super setUp];
    WPYCreditCard *card = [[WPYCreditCard alloc] init];
    _model = [[WPYExpiryFieldModel alloc] initWithCard:card];
}

- (void)tearDown
{
    _model = nil;
    [super tearDown];
}



#pragma mark test key
- (void)testFieldKey
{
    XCTAssertEqual([_model key], WPYExpiryFieldKey, @"Key should be WPYExpiryFieldKey.");
}



#pragma mark shouldValidateOnFocusLost
- (void)testShouldNotValidateWhenExpiryIsNil
{
    XCTAssertFalse([_model shouldValidateOnFocusLost], @"It should not validate when expiry is nil.");
}

- (void)testShouldNotValidateNilExpiryYear
{
    _model.card.expiryMonth = 11;
    XCTAssertFalse([_model shouldValidateOnFocusLost], @"It should not validate when year is nil");
}

- (void)testShouldNotValidateNilExpiryMonth
{
    _model.card.expiryYear = 2020;
    XCTAssertFalse([_model shouldValidateOnFocusLost], @"It should not validate when month is nil");
}

- (void)testShouldValidateWhenExpiryExists
{
    _model.card.expiryMonth = 11;
    _model.card.expiryYear = 2020;
    XCTAssertTrue([_model shouldValidateOnFocusLost], @"It should validate if expiry is set.");
}


#pragma mark initialValueForTextField
- (void)testInitialExpiry
{
    _model.card.expiryYear = 2018;
    _model.card.expiryMonth = 2;
    XCTAssertEqualObjects([_model initialValueForTextField], @"02 / 2018", @"It should format expiry as MM / YYYY.");
}

@end