//
//  WPYCreditCardTest.m
//  Webpay
//
//  Created by yohei on 3/14/14.
//  Copyright (c) 2014 yohei, YasuLab. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WPYCreditCard.h"
#import "WPYErrors.h"

@implementation NSDate(WPYTest)
//overriding +date method for testing
+ (NSDate *)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:2014];
    [comps setMonth:3];
    [comps setDay:31];
    
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCal dateFromComponents:comps];
}
@end

@interface WPYCreditCardTest : XCTestCase

@end

@implementation WPYCreditCardTest
{
    WPYCreditCard *_creditCard;
}

// These card numbers are not real numbers.
// All these test purpose numbers are from the link below.
// https://webpay.jp/docs/mock_cards

static NSString *const visaCardNumber     = @"4111111111111111";
static NSString *const amexCardNumber     = @"378282246310005";
static NSString *const masterCardNumber   = @"5555555555554444";
static NSString *const discoverCardNumber = @"6011111111111117";
static NSString *const JCBCardNumber      = @"3530111333300000";
static NSString *const dinersCardNumber   = @"30569309025904";
static NSString *const unknownCardNumber  = @"9876543210123456";

static NSString *const spacedVisaNumber = @"4242 4242 4242 4242";
static NSString *const hyphenedVisaNumber = @"4242-4242-4242-4242";

static NSString *const validName = @"Test Test";

- (void)setUp
{
    [super setUp];
    
    _creditCard = [[WPYCreditCard alloc] init];
}

- (void)tearDown
{
    _creditCard = nil;
    
    [super tearDown];
}



#pragma mark setter
- (void)testSetNumberRemovesAllWhitespaces
{
    _creditCard.number = spacedVisaNumber;
    XCTAssertEqualObjects(_creditCard.number, @"4242424242424242", @"It should remove all whitespaces when set.");
}

- (void)testSetNumberRemovesAllHyphens
{
    _creditCard.number = hyphenedVisaNumber;
    XCTAssertEqualObjects(_creditCard.number, @"4242424242424242", @"It should remove all hyphens when set.");
}



#pragma mark brandName
- (void)testBrandNameReturnsNilForEmptyNumber
{
    _creditCard.number = nil;
    XCTAssertNil([_creditCard brandName], @"brandName should return nil for empty card number.");
}

- (void)testBrandNameDiscernsVisa
{
    _creditCard.number = visaCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"Visa", @"It should be recongnized as visa.");
}

- (void)testBrandNameDiscernsAmex
{
    _creditCard.number = amexCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"American Express", @"It should be recognized as amex.");
}

- (void)testBrandNameDiscernsMasterCard
{
    _creditCard.number = masterCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"MasterCard", @"It should be recognized as master card.");
}

- (void)testBrandNameDiscernsDiscover
{
    _creditCard.number = discoverCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"Discover", @"It should be recognized as discover.");
}

- (void)testBrandNameDiscernsJCB
{
    _creditCard.number = JCBCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"JCB", @"It should be recognized as JCB.");
}

- (void)testBrandNameDiscernsDiners
{
    _creditCard.number = dinersCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"Diners", @"It should be recognized as diners.");
}

- (void)testBrandNameDicernsUnknown
{
    _creditCard.number = unknownCardNumber;
    XCTAssertEqualObjects([_creditCard brandName], @"Unknown", @"It should be recognized as unknown.");
}

- (void)testBrandNameDicernsVisaNumberWithHyphens
{
    NSString *number = hyphenedVisaNumber;
    _creditCard.number = number;
    XCTAssertEqualObjects([_creditCard brandName], @"Visa", @"It should be recognized as visa.");
}

- (void)testBrandNameDicernsVisaNumberWithWhiteSpaces
{
    NSString *number = spacedVisaNumber;
    _creditCard.number = number;
    XCTAssertEqualObjects([_creditCard brandName], @"Visa", @"It should be recognized as visa.");
}



#pragma mark expiryInString
- (void)testUnsetExpiry
{
    XCTAssertNil([_creditCard expiryInString], @"It should return nil when expiry is not set.");
}

- (void)testPartiallySetExpiry
{
    WPYCreditCard *card1 = [[WPYCreditCard alloc] init];
    card1.expiryYear = 2015;
    XCTAssertNil([card1 expiryInString], @"It should return nil when month is not set");
    
    WPYCreditCard *card2 = [[WPYCreditCard alloc] init];
    card2.expiryMonth = 11;
    XCTAssertNil([card2 expiryInString], @"It should return nil when year is not set");
}

- (void)testBothSetExpiry
{
    _creditCard.expiryYear = 2016;
    _creditCard.expiryMonth = 1;
    XCTAssertEqualObjects([_creditCard expiryInString], @"01 / 2016", @"It should return expiry in expected format.");
}


#pragma mark brandNameFromPartialNumber
- (void)testNilPartialNumber
{
    XCTAssertEqualObjects(@"Unknown", [WPYCreditCard brandNameFromPartialNumber:nil], @"nil partial number will be identified as unknown.");
}

- (void)testNonNumericPartialNumber
{
    XCTAssertEqualObjects(@"Unknown", [WPYCreditCard brandNameFromPartialNumber:@"abc"], @"Non numeric value wil be recognized as unknown.");
}

- (void)testTooShortPartialNumber
{
    XCTAssertEqualObjects(@"Unknown", [WPYCreditCard brandNameFromPartialNumber:@"1"], @"1 digit number will be identified as unknown.");
}

- (void)testPatialNumberWithVisaPrefix
{
    XCTAssertEqualObjects(@"Visa", [WPYCreditCard brandNameFromPartialNumber:@"42"], @"It should be recognized as visa.");
}

- (void)testPatialNumberWithMasterCardPrefix
{
    XCTAssertEqualObjects(@"MasterCard", [WPYCreditCard brandNameFromPartialNumber:@"5111 1"], @"It should be recognized as Master Card.");
}

- (void)testPatialNumberWithAmericanExpressPrefix
{
    XCTAssertEqualObjects(@"American Express", [WPYCreditCard brandNameFromPartialNumber:@"340"], @"It should be recognized as American Express.");
}

- (void)testPatialNumberWithDinersPrefix
{
    XCTAssertEqualObjects(@"Diners", [WPYCreditCard brandNameFromPartialNumber:@"3000"], @"It should be recognized as Diners.");
}

- (void)testPatialNumberWithJCBPrefix
{
    XCTAssertEqualObjects(@"JCB", [WPYCreditCard brandNameFromPartialNumber:@"3501"], @"It should be recognized as JCB.");
}

- (void)testPatialNumberWithDiscoverPrefix
{
    XCTAssertEqualObjects(@"Discover", [WPYCreditCard brandNameFromPartialNumber:@"6590"], @"It should be recognized as Discover.");
}



#pragma mark isSupportedBrand
- (void)testNilBrand
{
    XCTAssertNoThrow([WPYCreditCard isSupportedBrand:nil], @"It should not raise exception.");
    XCTAssertFalse([WPYCreditCard isSupportedBrand:nil], @"It should return No.");
}

- (void)testInvalidBrand
{
    XCTAssertFalse([WPYCreditCard isSupportedBrand:@"Credit Card"], @"Invalid brand should return nil.");
}

- (void)testUnsupportedBrand
{
    XCTAssertFalse([WPYCreditCard isSupportedBrand:@"Discover"], @"Discover is not supported.");
    XCTAssertFalse([WPYCreditCard isSupportedBrand:@"Unknown"], @"Unknown is not supported.");
}



#pragma mark - property validation
#pragma mark validateName
- (void)testValidateNameAcceptsNilAsErrorArgument
{
    NSString *name = nil;
    XCTAssertNoThrow([_creditCard validateName:&name error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testNilName
{
    NSString *name = nil;
    XCTAssertFalse([_creditCard validateName:&name error:nil], @"It should invalidate nil name.");
}

- (void)testNilNameReturnsExpectedError
{
    NSError *error = nil;
    NSString *name = nil;
    [_creditCard validateName:&name error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidName, @"Error code should be WPYInvalidName.");
    XCTAssertEqualObjects([error localizedDescription], @"The name provided is invalid. Make sure the name entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Name should not be nil.", @"It should return expected failure reason.");
}

- (void)testEmptyStrAsName
{
    NSString *name = @"    ";
    XCTAssertFalse([_creditCard validateName:&name error:nil], @"It should invalidate empty string for a name");
}

- (void)testEmptyStrAsNameReturnsExpectedError
{
    NSError *error = nil;
    NSString *name = @"   ";
    [_creditCard validateName:&name error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidName, @"Error code should be WPYInvalidName.");
    XCTAssertEqualObjects([error localizedDescription], @"The name provided is invalid. Make sure the name entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Name should not be empty.", @"It should return expected failure reason.");
}

- (void)testValidName
{
    NSError *error = nil;
    NSString *name = validName;
    XCTAssertTrue([_creditCard validateName:&name error:&error], @"It should validate name.");
}

- (void)testValidNameDoesNotReturnError
{
    NSError *error = nil;
    NSString *name = validName;
    [_creditCard validateName:&name error:&error];
    XCTAssertNil(error, @"Error object should be nil.");
}



#pragma mark validateNumber
- (void)testValidateNumberAcceptsNilAsErrorArgument
{
    NSString *number = @"1";
    XCTAssertNoThrow([_creditCard validateNumber:&number error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testNilNumber
{
    NSString *number = nil;
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invalidate nil number.");
}

- (void)testNilNumberReturnsExpectedError
{
    NSError *error = nil;
    NSString *number = nil;
    [_creditCard validateNumber:&number error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Number should not be nil.", @"It should return expected failure reason.");
}

- (void)testNonNumericNumber
{
    NSString *number = @"411111111234abcd1";
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invalidate non numeric number.");
}

- (void)testNonNumericNumberReturnsExpectedError
{
    NSError *error = nil;
    NSString *number = @"411111111234abcd1";
    [_creditCard validateNumber:&number error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Number should be numeric only.", @"It should return expected failure reason.");
}

- (void)testEmptyNumber
{
    NSString *number = @"   ";
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invalidate empty string number.");
}

- (void)testEmptyNumberReturnsExpectedError
{
    NSError *error = nil;
    NSString *number = @"   ";
    [_creditCard validateNumber:&number error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Number should be 13 digits to 16 digits.", @"It should return expected failure reason.");
}

- (void)testNumberWithTwelveDigits
{
    NSString *number = @"411111111111";
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invalidate 12 digits card number.");
}

- (void)testNumberThirteenDigits
{
    NSString *number = @"4111111111119";
    XCTAssertTrue([_creditCard validateNumber:&number error:nil], @"It should validate 13 digits card number.");
}

- (void)testNumberWithSixteenDigits
{
    NSString *number = @"4111111111111111";
    XCTAssertTrue([_creditCard validateNumber:&number error:nil], @"It should validate 16 digits card number.");
}

- (void)testNumberWithSeventeenDigits
{
    NSString *number = @"41111111111111111";
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invalidate 17 digits card number.");
}

- (void)testNumberWithInvalidDigitsReturnsExpectedError
{
    NSError *error = nil;
    NSString *number = @"411111111111"; //12 digits
    [_creditCard validateNumber:&number error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Number should be 13 digits to 16 digits.", @"It should return expected failure reason.");
}

- (void)testLuhnInvalidNumber
{
    NSString *number = @"4111111111111112";
    XCTAssertFalse([_creditCard validateNumber:&number error:nil], @"It should invaildate numbers that are not luhn valid.");
}

- (void)testLuhnInvalidNumberReturnsExpectedError
{
    NSError *error = nil;
    NSString *number = @"1234567890123456";
    [_creditCard validateNumber:&number error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"This number is not Luhn valid string.", @"It should return expected failure reason.");
}

- (void)testNumberWithSpaces
{
    NSString *number = spacedVisaNumber;
    XCTAssertTrue([_creditCard validateNumber:&number error:nil], @"It should validate valid card number with spaces.");
}

- (void)testNumberWithHyphens
{
    NSString *number = hyphenedVisaNumber;
    XCTAssertTrue([_creditCard validateNumber:&number error:nil], @"It should validate valid card number with hyphens.");
}

- (void)testValidNumberDoesNotReturnError
{
    NSError *error = nil;
    NSString *number = spacedVisaNumber;
    [_creditCard validateNumber:&number error:&error];
    XCTAssertNil(error, @"Valid number should not cause the method to populate error object.");
}



#pragma mark validateCvc
- (void)testValidateCvcAcceptsNilAsErrorArgument
{
    NSString *cvc = nil;
    XCTAssertNoThrow([_creditCard validateCvc:&cvc error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testNilCvc
{
    NSError *error = nil;
    NSString *cvc = nil;
    XCTAssertFalse([_creditCard validateCvc:&cvc error: &error], @"Nil cvc should be invalidated.");
}

- (void)testNilCvcReturnsExpectedError
{
    NSError *error = nil;
    NSString *cvc = nil;
    [_creditCard validateCvc:&cvc error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc should not be nil.", @"It should return expected failure reason.");
}

- (void)testEmptyCvc
{
    NSError *error = nil;
    NSString *cvc = @"   ";
    XCTAssertFalse([_creditCard validateCvc:&cvc error: &error], @"Empty cvc should be invalidated.");
}

- (void)testNonNumericCvc
{
    NSString *cvc = @"1a4";
    XCTAssertFalse([_creditCard validateCvc:&cvc error:nil], @"It should invalidate non numeric cvc.");
}

- (void)testNonNumericCvcReturnsExpectedError
{
    NSError *error = nil;
    NSString *cvc = @"1a5";
    [_creditCard validateCvc:&cvc error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc should be numeric only.", @"It should return expected failure reason.");
}

- (void)testTwoDigitsCvc
{
    NSString *cvc = @"12";
    XCTAssertFalse([_creditCard validateCvc:&cvc error:nil], @"It should invalidate 2 digits cvc.");
}

- (void)testThreeDigitsCvc
{
    NSError *error = nil;
    NSString *cvc = @"123";
    XCTAssertTrue([_creditCard validateCvc:&cvc error: &error], @"It should validate 3 digits cvc.");
}

- (void)testFourDigitsCvc
{
    NSError *error = nil;
    NSString *cvc = @"1234";
    XCTAssertTrue([_creditCard validateCvc:&cvc error: &error], @"It should validate 4 digits cvc.");
}

- (void)testFiveDigitsCvc
{
    NSString *cvc = @"12345";
    XCTAssertFalse([_creditCard validateCvc:&cvc error:nil], @"It should invalidate 5 digits cvc.");
}

- (void)testInvalidDigitsReturnsExpectedError
{
    NSError *error = nil;
    NSString *cvc = @"12";
    [_creditCard validateCvc:&cvc error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc should be 3 or 4 digits.", @"It should return expected failure reason.");
}

- (void)testAmexWithThreeDigitsCvc
{
    _creditCard.number = amexCardNumber;
    
    NSString *cvc = @"123";
    XCTAssertFalse([_creditCard validateCvc:&cvc error:nil], @"It should invalidate 3 digits cvc for amex card.");
}

- (void)testAmexWithThreeDigitsCvcReturnsExpectedError
{
    NSError *error = nil;
    _creditCard.number = amexCardNumber;
    
    NSString *cvc = @"123";
    [_creditCard validateCvc:&cvc error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc for amex card should be 4 digits.", @"It should return expected failure reason.");
}

- (void)testAmexWithFourDigitsCvc
{
    _creditCard.number = amexCardNumber;
    
    NSError *error = nil;
    NSString *cvc = @"1234";
    XCTAssertTrue([_creditCard validateCvc:&cvc error: &error], @"It should validate 4 digits cvc for amex card.");
}

- (void)testNonAmexCardWithThreeDigitsCvc
{
    _creditCard.number = masterCardNumber;
    
    NSError *error = nil;
    NSString *cvc = @"123";
    XCTAssertTrue([_creditCard validateCvc:&cvc error: &error], @"It should validate 3 digits cvc for non amex card.");
}

- (void)testNonAmexCardWithFourDigitsCvc
{
    _creditCard.number = masterCardNumber;
    
    NSString *cvc = @"1234";
    XCTAssertFalse([_creditCard validateCvc:&cvc error:nil], @"It should invalidate 4 digits cvc for non amex card.");
}

- (void)testNonAmexCardWithFourDigitsCvcReturnsExpectedError
{
    NSError *error = nil;
    _creditCard.number = masterCardNumber;
    
    NSString *cvc = @"1234";
    [_creditCard validateCvc:&cvc error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc for non amex card should be 3 digits.", @"It should return expected failure reason.");
}

- (void)testValidCvcDoesNotReturnError
{
    _creditCard.number = amexCardNumber;
    
    NSError *error = nil;
    NSString *cvc = @"1234";
    [_creditCard validateCvc:&cvc error: &error];
    XCTAssertNil(error, @"It should not populate error object.");
}



#pragma mark validateExpiryMonth
- (void)testValidateExpiryMonthAcceptsNilAsErrorArgument
{
    NSNumber *expiryMonth = nil;
    XCTAssertNoThrow([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testNilExpiryMonth
{
    NSNumber *expiryMonth = nil;
    XCTAssertFalse([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should invalidate nil expiryMonth.");
}

- (void)testNilExpiryMonthReturnsExpectedError
{
    NSError *error = nil;
    NSNumber *expiryMonth = nil;
    [_creditCard validateExpiryMonth:&expiryMonth error: &error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidExpiryMonth, @"Error code should be WPYInvalidExpiryMonth.");
    XCTAssertEqualObjects([error localizedDescription], @"The expiry month provided is invalid. Make sure the expiry month entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Expiry month should not be nil.", @"It should return expected failure reason.");
}

- (void)testWhenExpiryMonthIsZero
{
    NSNumber *expiryMonth = [NSNumber numberWithInt:0];
    XCTAssertFalse([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should invalidate when expiry month is 0.");
}

- (void)testWhenExpiryMonthIsOne
{
    NSNumber *expiryMonth = [NSNumber numberWithInt:1];
    XCTAssertTrue([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should validate when expiry month is 1.");
}

- (void)testWhenExpiryMonthIsTwelve
{
    NSNumber *expiryMonth = [NSNumber numberWithInt:12];
    XCTAssertTrue([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should validate when expiry month is 12.");
}

- (void)testWhenExpiryMonthIsThirteen
{
    NSNumber *expiryMonth = [NSNumber numberWithInt:13];
    XCTAssertFalse([_creditCard validateExpiryMonth:&expiryMonth error:nil], @"It should invalidate when expiry month is 13.");
}

- (void)testInvalidExpiryMonthRangeReturnsExpectedError
{
    NSError *error = nil;
    NSNumber *expiryMonth = [NSNumber numberWithInt:13];
    [_creditCard validateExpiryMonth:&expiryMonth error: &error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidExpiryMonth, @"Error code should be WPYInvalidExpiryMonth.");
    XCTAssertEqualObjects([error localizedDescription], @"The expiry month provided is invalid. Make sure the expiry month entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Expiry month should be a number between 1 to 12.", @"It should return expected failure reason.");
}

- (void)testValidExpiryMonthDoesNotReturnError
{
    NSError *error = nil;
    NSNumber *expiryMonth = [NSNumber numberWithInt:12];
    [_creditCard validateExpiryMonth:&expiryMonth error:&error];
    XCTAssertNil(error, @"It should not populate error object for valid expiry month.");
}



#pragma mark validateExpiryYear
- (void)testValidateExpiryYearAcceptsNilAsErrorArgument
{
    NSNumber *expiryYear = nil;
    XCTAssertNoThrow([_creditCard validateExpiryYear:&expiryYear error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testNilExpiryYear
{
    NSNumber *expiryYear = nil;
    XCTAssertFalse([_creditCard validateExpiryYear:&expiryYear error:nil], @"It should invalidate nil expiry year.");
}

- (void)testNilExpiryYearReturnsExpectedError
{
    NSError *error = nil;
    NSNumber *expiryYear = nil;
    
    [_creditCard validateExpiryYear:&expiryYear error:&error];
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqual([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidExpiryYear, @"Error code should be WPYInvalidExpiryYear.");
    XCTAssertEqualObjects([error localizedDescription], @"The expiry year provided is invalid. Make sure the expiry year entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqual(failureReason, @"Expiry year should not be nil.", @"It should return expected failure reason.");
}



#pragma mark validateExpiry
- (void)testValidateExpiryAcceptsNilAsArgument
{
    XCTAssertNoThrow([_creditCard validateExpiryYear:2014 month:12 error:nil], @"It should not raise exception when nil is passed as error argument.");
}

- (void)testWhenExpiryIsOneYearAgo
{
    int year = 2013;
    int month = 3;
    XCTAssertFalse([_creditCard validateExpiryYear:year month:month error:nil], @"It should invalidate if expiry date is a year ago.");
}

- (void)testWhenExpiryIsOneMonthAgo
{
    int year = 2014;
    int month = 2;
    XCTAssertFalse([_creditCard validateExpiryYear:year month:month error:nil], @"It should invalidate if expiry date is a month a go.");
}

- (void)testWhenExpiryIsThisMonth
{
    int year = 2014;
    int month = 3;
    XCTAssertTrue([_creditCard validateExpiryYear:year month:month error:nil], @"It should validate if expiry month is this month.");
}

- (void)testWhenExpiryIsNextMonth
{
    int year = 2014;
    int month = 4;
    XCTAssertTrue([_creditCard validateExpiryYear:year month:month error:nil], @"It should validate if expiry month is next month");
}

- (void)testWhenExpiryIsNextYear
{
    int year = 2015;
    int month = 3;
    XCTAssertTrue([_creditCard validateExpiryYear:year month:month error:nil], @"It should validate if expiry year is next year.");
}

- (void)testExpiredDateReturnsExpectedError
{
    NSError *error = nil;
    [_creditCard validateExpiryYear:2010 month:3 error:&error];
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectExpiry, @"Error code should be WPYInvalidName.");
    XCTAssertEqualObjects([error localizedDescription], @"The card's expiry is incorrect. Make sure you entered the correct expiration date.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"This card is expired.", @"It should return expected failure reason.");
}

- (void)testValidExpiryDoesNotReturnError
{
    NSError *error = nil;
    [_creditCard validateExpiryYear:2015 month:3 error:&error];
    XCTAssertNil(error, @"It should not return error for valid expiry.");
}



#pragma mark validate
- (void)testValidateAcceptsNilAsArgument
{
    XCTAssertNoThrow([_creditCard validate:nil], @"It should not throw");
}

- (void)testValidateWithInvalidName
{
    _creditCard.name = @"    ";
    _creditCard.number = visaCardNumber;
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with invalid name.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidName, @"Error code should be WPYInvalidName.");
    XCTAssertEqualObjects([error localizedDescription], @"The name provided is invalid. Make sure the name entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Name should not be empty.", @"It should return expected failure reason.");
}

- (void)testValidateWithInvalidNumber
{
    _creditCard.name = validName;
    _creditCard.number = @"4111111111111112";
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with invalid number.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"This number is not Luhn valid string.", @"It should return expected failure reason.");
}

- (void)testValidateWithInvalidCvc
{
    _creditCard.name = validName;
    _creditCard.number = visaCardNumber;
    _creditCard.cvc = @"1234";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with invalid cvc.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidCvc, @"Error code should be WPYInvalidCvc.");
    XCTAssertEqualObjects([error localizedDescription], @"The security code provided is invalid. For Visa, MasterCard, JCB, and Diners Club, enter the last 3 digits on the back of your card. For American Express, enter the 4 digits printed above your number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"cvc for non amex card should be 3 digits.", @"It should return expected failure reason.");
}

- (void)testValidateWithInvalidExpiryMonth
{
    _creditCard.name = validName;
    _creditCard.number = visaCardNumber;
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 13;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with invalid expiry month.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYInvalidExpiryMonth, @"Error code should be WPYInvalidExpiryMonth.");
    XCTAssertEqualObjects([error localizedDescription], @"The expiry month provided is invalid. Make sure the expiry month entered matches your credit card.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"Expiry month should be a number between 1 to 12.", @"It should return expected failure reason.");
}

- (void)testValidateWithInvalidExpiry
{
    _creditCard.name = validName;
    _creditCard.number = visaCardNumber;
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2010;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with invalid expiry.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectExpiry, @"Error code should be WPYIncorrectExpiry.");
    XCTAssertEqualObjects([error localizedDescription], @"The card's expiry is incorrect. Make sure you entered the correct expiration date.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"This card is expired.", @"It should return expected failure reason.");

}

- (void)testValidateWithUnsupportedBrand
{
    _creditCard.name = validName;
    _creditCard.number = discoverCardNumber;
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertFalse([_creditCard validate:&error], @"It should invalidate card with unsupported brand.");
    
    XCTAssertNotNil(error, @"Error object should not be nil.");
    XCTAssertEqualObjects([error domain], WPYErrorDomain, @"Error domain should be WPYErrorDomain.");
    XCTAssertEqual([error code], WPYIncorrectNumber, @"Error code should be WPYIncorrectNumber.");
    XCTAssertEqualObjects([error localizedDescription], @"The card number is incorrect. Make sure you entered the correct card number.", @"It should return expected localized description.");
    NSDictionary *userInfo = [error userInfo];
    NSString *failureReason = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    XCTAssertEqualObjects(failureReason, @"This brand is not supported by Webpay.", @"It should return expected failure reason.");
}

- (void)testValidateWithSupportedBrand
{
    _creditCard.name = validName;
    _creditCard.number = dinersCardNumber;
    _creditCard.cvc = @"123";
    _creditCard.expiryYear = 2014;
    _creditCard.expiryMonth = 12;
    
    NSError *error = nil;
    XCTAssertTrue([_creditCard validate:&error], @"It should validate card with supported brand.");
    XCTAssertNil(error, @"Error object should be nil.");
}


@end