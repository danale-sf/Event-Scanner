//
//  TabReaderAppDelegate.h
//  TabReader
//
//  
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "constants.h"

@interface TabReaderAppDelegate
    : NSObject
    < UIApplicationDelegate,
      UITabBarControllerDelegate,
      UIAlertViewDelegate,
      ZBarReaderDelegate >
{
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (atomic) BOOL alertIsActive;
-(void)showScanAlert;

@end
