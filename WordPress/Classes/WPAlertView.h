//
//  WPAlertView.h
//  WordPress
//
//  Created by Aaron Douglas on 9/5/2013.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WPAlertViewOverlayMode) {
    WPAlertViewOverlayModeTapToDismiss,
    WPAlertViewOverlayModeDoubleTapToDismiss,
    WPAlertViewOverlayModeTwoButtonMode,
    WPAlertViewOverlayModeOneTextFieldTwoButtonMode,
    WPAlertViewOverlayModeTwoTextFieldsTwoButtonMode
};

@interface WPAlertView : UIView

@property (nonatomic, assign) WPAlertViewOverlayMode overlayMode;
@property (nonatomic, strong) NSString *overlayTitle;
@property (nonatomic, strong) NSString *overlayDescription;
@property (nonatomic, strong) NSString *footerDescription;
@property (nonatomic, strong) NSString *firstTextFieldPlaceholder;
@property (nonatomic, strong) NSString *firstTextFieldValue;
@property (nonatomic, strong) NSString *secondTextFieldPlaceholder;
@property (nonatomic, strong) NSString *secondTextFieldValue;
@property (nonatomic, strong) NSString *leftButtonText;
@property (nonatomic, strong) NSString *rightButtonText;
@property (nonatomic, assign) BOOL hideBackgroundView;

// Provided for convenience to alter keyboard behavior
@property (nonatomic, weak) IBOutlet UITextField *firstTextField;
@property (nonatomic, weak) IBOutlet UITextField *secondTextField;

@property (nonatomic, copy) void (^singleTapCompletionBlock)(WPAlertView *);
@property (nonatomic, copy) void (^doubleTapCompletionBlock)(WPAlertView *);
@property (nonatomic, copy) void (^button1CompletionBlock)(WPAlertView *);
@property (nonatomic, copy) void (^button2CompletionBlock)(WPAlertView *);

- (void)dismiss;

@end
