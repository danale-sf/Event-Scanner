//
//  SecondViewController.h
//  TabReader
//
//  
//

#import <UIKit/UIKit.h>

@interface ResultsViewController
    : UIViewController
{
}

@property (nonatomic, retain) IBOutlet UITextView *resultText;
@property (retain, nonatomic) IBOutlet UIWebView *resultWebView;
@property (atomic) BOOL userHasScanned;

@end
