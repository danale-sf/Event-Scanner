//
//  TabReaderAppDelegate.m
//  TabReader
//
//  
//

#import "TabReaderAppDelegate.h"
#import "ResultsViewController.h"
#import "searchByEmailViewController.h"
#import "Reachability.h"
#import "constants.h"

@interface TabReaderAppDelegate (private)
    -(void)reachabilityChanged:(NSNotification*)note;
@end

@implementation TabReaderAppDelegate

@synthesize window=_window;
@synthesize tabBarController =_tabBarController;
@synthesize alertIsActive;


- (BOOL) application: (UIApplication*) application
  didFinishLaunchingWithOptions: (NSDictionary*) options
{
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
#pragma mark -
#pragma Reachability
    alertIsActive = NO;
    NSLog(@"alertIsActive: %@", alertIsActive);
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"force.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says Reachable");
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says Unreachable");
        });
    };
    
    [reach startNotifier];


    // force class to load so it may be referenced directly from nib
    [ZBarReaderViewController class];

    ZBarReaderViewController *reader =
        [self.tabBarController.viewControllers objectAtIndex: 0];
    reader.readerDelegate = self;
    reader.showsZBarControls = NO;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    [TestFlight takeOff:kTESTFLIGHT];

    return(YES);
}

- (void) dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

-(void)showScanAlert{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Oops"
                          message:@"This does not appear to be a valid registration"
                          delegate:nil cancelButtonTitle:@"Try again"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

// ZBarReaderDelegate

- (void)  imagePickerController: (UIImagePickerController*) picker
  didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // do something useful with results
    UITabBarController *tabs = self.tabBarController;
    NSLog(@"tabs.viewControllers: %@",tabs.viewControllers);
    tabs.selectedIndex = 1;
    ResultsViewController *results = [tabs.viewControllers objectAtIndex: 1];

    id <NSFastEnumeration> syms =
    [info objectForKey: ZBarReaderControllerResults];
    for(ZBarSymbol *sym in syms) {
        
        NSString *resultsTag = @"Results: ";
        NSString *searchString = @"force.com";
        
        NSString *resultsData = sym.data;
        
        NSRange range = [resultsData rangeOfString:searchString
                                           options:NSCaseInsensitiveSearch];

        
        if(range.location == NSNotFound) {
            NSLog(@"Scanned code does not have %@", searchString);

            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Oops"
                                  message:@"The scanned registration code does not appear to be valid"
                                  delegate:nil
                                  cancelButtonTitle:@"Try Again"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];

            break;
        } else {
            NSLog(@"%@ detected. Likely a reg code", searchString);
        }
        
        NSString *resultsMessage = [resultsTag stringByAppendingString:resultsData];
        
        results.resultText.text = resultsMessage;

        NSURL *myURL = [NSURL URLWithString:[resultsData stringByAppendingString:@"&source=n1nj4d0j0"]];
        NSLog(@"myUrl: %@",myURL);
        
        
        [results.resultWebView loadRequest:[NSURLRequest requestWithURL:myURL]];
        // [myURL release];

        break;
    }
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Notification: Reachable");
    }
    else
    {
        NSLog(@"Notification: Unreachable");
        NSLog(@"alertIsActive: %@",alertIsActive);
        if (alertIsActive != NO) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Internet Error"
                                  message:@"Check-in site unreachable. Please check network connection."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Button Pressed");
        alertIsActive = NO;
    }
}




@end
