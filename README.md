# webpay-token-ios [![Build Status](https://travis-ci.org/webpay/webpay-token-ios.svg?branch=master)](https://travis-ci.org/webpay/webpay-token-ios)

webpay-token-ios is an ios library for creating a token from a credit card.

## Requirements
webpay-token-ios supports iOS 5 and above.
Tested on iOS6+.


## Installation

You can either install using cocoapods(recommended) or copying files manually.

### 1. Cocoapods
In your Podfile, add a line
```
pod 'WebPay', '1.0'
```
then, run `pod install`.


### 2. copy files manually

1. clone this repository
2. add files under Webpay directory to your project


### Check if installed correctly
add `#import 'Webpay.h'` in one of your files, and see if your target builds without error.


## Overview

webpay-token-ios consists of 3 components.

1. WPYTokenizer(model)
2. WPYCardFormView(view)
3. WPYPaymentViewController(view controller)

Each component is independent, which leaves a flexible option on which component
to reuse or make on your own.

## How to use

### Initialization(required for every components)
``` objective-c
#import "Webpay.h"

[WPYTokenizer setPublicKey:@"test_public_YOUR_PUBLIC_KEY"];
```

### WPYTokenizer (Model)
If you are creating your own view, create token using WPYTokenizer.

```
#import "Webpay.h"

// create a credit card model and populate with data
WPYCreditCard *card = [[WPYCreditCard alloc] init];
card.number = @"4242424242424242";
card.expiryYear = 2015;
card.expiryMonth = 12;
card.cvc = @"123";
card.name = @"Yohei Okada";
    
// pass card instance and a callback
[WPYTokenizer createTokenFromCard:card completionBlock:^(WPYToken *token, NSError *error)
{
  if (token)
  {
    NSLog(@"token:%@", token.tokenId);
  }
  else
  {
    NSLog(@"error:%@", [error localizedDescription]);
  }
}];
```

### WPYCardFormView (View)
WPYCardFormView is a credit card form view that calls delegate method when card form is valid. It handles padding credit card number, masking security code, and validation on each field.

```
// create view
WPYCardFormView *cardForm = [[WPYCardFormView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
cardForm.delegate = self;
[self.view addSubview: cardForm];

// WPYCardFormDelegate methods
- (void)validFormWithCard:(WPYCreditCard *)creditCard
{
  // called when the form is valid.  
  self.card = creditCard;
  self.button.enabled = YES;
}
```

If you want more granular control, use subclasses of `WPYAbstractCardField`.


### WPYPaymentViewController
If you just want a viewcontroller for `pushViewController:animated` or `presentViewController:animated:completion:`, this is what you want.

```
WPYPaymentViewController *paymentViewController = [[WPYPaymentViewController alloc] initWithPriceTag:@"$23.67" callback:^(WPYPaymentViewController *paymentViewController, WPYToken *token, NSError *error){
  if(token)
  {
    //post token to your server
    
    // when transaction is complete
    [viewController setPayButtonComplete]; // this will change the button color to green and its title to checkmark
    [viewController dismissAfterDelay: 2.0f];
  }
  else
  { 
    NSLog(@"error:%@", [error localizedDescription]);
  }
}];
    
[self.navigationController pushViewController:paymentViewController animated:YES];
```

If you want the card form to be populated with card data, use `initWithPriceTag:card:callback:` instead.


### Other classes
#### WPYCreditCard
WPYCreditCard offers various validation methods.
For validating the whole card, use `- (BOOL)validate:`
```
NSError *cardError = nil;
if (![card validate:&cardError])
{
  NSLog(@"error:%@", [cardError localizedDescription]);
}
```

For validating each property, use `- (BOOL)validatePROPERTY:error:`
```
NSString *number = @"4242424242424242";
NSError *cardError = nil;
WPYCreditCard *card = [[WPYCreditCard alloc] init];
if (![card validateNumber:&number error:&cardError])
{
  NSLog(@"error:%@", [cardError localizedDescription]);
}
```

For checking brand from partial numbers
```
[WPYCreditCard brandNameFromPartialNumber:@"42"];
```

#### WPYToken
WPYToken holds token data returned from Webpay API.

#### WPYError
This class defines all the errors originating from webpay-ios-token.

