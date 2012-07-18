//
//  ScanViewController.h
//  SimpleScan
//
//  Created by Michael Critz on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "SFRestAPI.h"

@protocol scanViewDataSource <NSObject>

-(void)parseContactData:(NSArray *)contactArray;
-(void)setpresenceID:(NSString *)presenceID;

@end


@interface ScanViewController : UIViewController
    <SFRestDelegate, ZBarReaderViewDelegate, UIAlertViewDelegate>
{
    ZBarReaderView *readerView;
    UITextView *resultText;
    ZBarCameraSimulator *cameraSim;
    
    // setup delegate method
    // NSArray *contactArray;
    id <scanViewDataSource> delegate;

}

@property (nonatomic, retain) IBOutlet ZBarReaderView *readerView;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
@property (nonatomic, retain) ZBarCameraSimulator *cameraSim;

@property (nonatomic, retain) NSArray *sfdcArray;
@property (nonatomic, retain) NSString *scannedText;

@property (nonatomic, assign)id delegate;



// @property (nonatomic, retain) IBOutlet UIButton *cancelButton;
-(IBAction)cancelButtonPressed; //:(id)sender;
-(void)alertOnFailedRequest;

@end
