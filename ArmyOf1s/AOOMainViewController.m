//
//  AOOMainViewController.m
//  ArmyOf1s
//
//  Created by Varun Goyal on 5/1/14.
//  Copyright (c) 2014 HugeVG. All rights reserved.
//
//  iOS app to convert currencies.
//  Google API was shut down on November 1
//  So I am using another 3rd party API links are as below:-
//
//  UK Pounds:    http://rate-exchange.appspot.com/currency?from=USD&to=GBP&q=1
//  EU Euro:      http://rate-exchange.appspot.com/currency?from=USD&to=EUR&q=1
//  Japan Yen:    http://rate-exchange.appspot.com/currency?from=USD&to=JPY&q=1
//  Brazil Reais: http://rate-exchange.appspot.com/currency?from=USD&to=BRL&q=1
//
//  Further improvments:- Can add better error message like server not responding or network not available

#import "AOOMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "AFNetworking/AFHTTPRequestOperation.h"

@interface AOOMainViewController ()
@property (strong, nonatomic) IBOutlet UITextField *tf_InputAmount;
@property (strong, nonatomic) IBOutlet UITextField *tf_OutputAmount;
@property (strong, nonatomic) IBOutlet UILabel *lb_OutputCurrency;
@property (strong, nonatomic) IBOutlet UIPickerView *pv_OutputCurrency;
@property (strong, nonatomic) NSDictionary * currencyAndLinks;
@property (strong, nonatomic) IBOutlet UIButton *bt_Convert;
@end


@implementation AOOMainViewController
@synthesize tf_InputAmount = _tf_InputAmount;
@synthesize tf_OutputAmount = _tf_OutputAmount;
@synthesize lb_OutputCurrency = _lb_OutputCurrency;
@synthesize pv_OutputCurrency = _pv_OutputCurrency;
@synthesize currencyAndLinks = _currencyAndLinks;

#pragma mark- Lifecycle
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // To initialize the directory of currency
    self.currencyAndLinks = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"http://rate-exchange.appspot.com/currency?from=USD&to=GBP&q=", @"UK Pounds",
                         @"http://rate-exchange.appspot.com/currency?from=USD&to=EUR&q=1", @"EU Euro",
                         @"http://rate-exchange.appspot.com/currency?from=USD&to=JPY&q=1", @"Japan Yen",
                         @"http://rate-exchange.appspot.com/currency?from=USD&to=BRL&q=1", @"Brazil Reais",
                         nil];
    
    // To get the selected currency name
    [self setLb_OutputCurrencyAtRow:0];
    
    // To add border to button convert
    [self.bt_Convert.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.bt_Convert.layer setBorderWidth:1];
}


#pragma mark- UIPickerView DataSourceDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currencyAndLinks.count;
}


#pragma mark- UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.currencyAndLinks.allKeys objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setLb_OutputCurrencyAtRow:row];
}


#pragma mark- UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setText:@""];
}

#pragma mark- Utility
- (void) setLb_OutputCurrencyAtRow:(NSInteger) row
{
    // To set the output label for selected row
    NSString *selectedCurrencyName = [[self.currencyAndLinks allKeys] objectAtIndex:row];
    [self.lb_OutputCurrency setText:selectedCurrencyName];
}


#pragma mark- Actions
- (IBAction)bt_ChangeCurrencyPressed:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)bt_ConvertPressed:(id)sender
{
    // To start activity indicator
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self.view endEditing:YES];
    
    // To make api request for currency conversion
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           [self.currencyAndLinks objectForKey:self.lb_OutputCurrency.text],
                           self.tf_InputAmount.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // To display converted amount
        NSDictionary *responseJSON = (NSDictionary *) responseObject;
        float outputAmountfloat = [[responseJSON objectForKey:@"v"] floatValue];
        NSString* outputAmount = [NSString stringWithFormat:@"%.02f", outputAmountfloat];
        [SVProgressHUD dismiss];
        [self.tf_OutputAmount setText:outputAmount];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Please try again later."];
    }];
    
    [operation start];
    
}

@end
