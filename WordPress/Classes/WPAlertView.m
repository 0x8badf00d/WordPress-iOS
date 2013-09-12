//  NewWPWalkthroughOverlayView.m
//  WordPress
//
//  Created by Aaron Douglas on 9/5/2013
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "WPAlertView.h"
#import "WPNUXPrimaryButton.h"
#import "WPNUXSecondaryButton.h"
#import "WPNUXUtility.h"

@interface WPAlertView() {
    UITapGestureRecognizer *_gestureRecognizer;
    NSArray *_horizontalConstraints;
    NSArray *_verticalConstraints;
}

@property (nonatomic, assign) WPAlertViewOverlayMode overlayMode;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bottomSeparator;
@property (nonatomic, weak) IBOutlet UILabel *bottomLabel;
@property (nonatomic, weak) IBOutlet WPNUXSecondaryButton *leftButton;
@property (nonatomic, weak) IBOutlet WPNUXPrimaryButton *rightButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *verticalCenteringConstraint;

@end

@implementation WPAlertView

CGFloat const WPAlertViewStandardOffset = 16.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andOverlayMode:WPAlertViewOverlayModeTwoTextFieldsTwoButtonMode];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andOverlayMode:(WPAlertViewOverlayMode)overlayMode
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _overlayMode = overlayMode;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _verticalConstraints = [NSArray array];
        _horizontalConstraints = [NSArray array];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView = scrollView;
        [self addSubview:scrollView];
        
        UIView *backgroundView = nil;
        
        if (_overlayMode == WPAlertViewOverlayModeTwoTextFieldsSideBySideTwoButtonMode) {
            backgroundView = [[NSBundle mainBundle] loadNibNamed:@"WPAlertViewSideBySide" owner:self options:nil][0];
        } else {
            backgroundView = [[NSBundle mainBundle] loadNibNamed:@"WPAlertView" owner:self options:nil][0];
        }
        
        backgroundView.frame = scrollView.frame;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [scrollView addSubview:backgroundView];
        
        [self configureView];
        [self configureBackgroundColor];
        [self configureButtonVisibility];
        [self configureTextFieldVisibility];
        [self addGestureRecognizer];
    }
    return self;
}

- (void)setOverlayMode:(WPAlertViewOverlayMode)overlayMode
{
    if (_overlayMode != overlayMode) {
        _overlayMode = overlayMode;
        [self adjustOverlayDismissal];
        [self configureButtonVisibility];
        [self configureTextFieldVisibility];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setOverlayTitle:(NSString *)overlayTitle
{
    if (_overlayTitle != overlayTitle) {
        _overlayTitle = overlayTitle;
        self.titleLabel.text = _overlayTitle;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setOverlayDescription:(NSString *)overlayDescription
{
    if (_overlayDescription != overlayDescription) {
        self.descriptionLabel.hidden = NO;
        _overlayDescription = overlayDescription;
        self.descriptionLabel.text = _overlayDescription;
        [self setNeedsUpdateConstraints];
    } else if (overlayDescription == nil) {
        self.descriptionLabel.hidden = YES;
    }
}

- (void)setFooterDescription:(NSString *)footerDescription
{
    if (_footerDescription != footerDescription) {
        _footerDescription = footerDescription;
        self.bottomLabel.text = _footerDescription;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFirstTextFieldPlaceholder:(NSString *)firstTextFieldPlaceholder
{
    if (![_firstTextFieldPlaceholder isEqualToString:firstTextFieldPlaceholder]) {
        _firstTextFieldPlaceholder = firstTextFieldPlaceholder;
        self.firstTextField.placeholder = _firstTextFieldPlaceholder;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFirstTextFieldValue:(NSString *)firstTextFieldValue
{
    if (![_firstTextFieldValue isEqualToString:firstTextFieldValue]) {
        _firstTextFieldValue = firstTextFieldValue;
        self.firstTextField.text = _firstTextFieldValue;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setSecondTextFieldPlaceholder:(NSString *)secondTextFieldPlaceholder
{
    if (![_secondTextFieldPlaceholder isEqualToString:secondTextFieldPlaceholder]) {
        _secondTextFieldPlaceholder = secondTextFieldPlaceholder;
        self.secondTextField.placeholder = _secondTextFieldPlaceholder;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setSecondTextFieldValue:(NSString *)secondTextFieldValue
{
    if (![_secondTextFieldValue isEqualToString:secondTextFieldValue]) {
        _secondTextFieldValue = secondTextFieldValue;
        self.secondTextField.text = _secondTextFieldValue;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setLeftButtonText:(NSString *)leftButtonText
{
    if (_leftButtonText != leftButtonText) {
        _leftButtonText = leftButtonText;
        [self.leftButton setTitle:_leftButtonText forState:UIControlStateNormal];
        [self needsUpdateConstraints];
    }
}

- (void)setRightButtonText:(NSString *)rightButtonText
{
    if (_rightButtonText != rightButtonText) {
        _rightButtonText = rightButtonText;
        [self.rightButton setTitle:_rightButtonText forState:UIControlStateNormal];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setHideBackgroundView:(BOOL)hideBackgroundView
{
    if (_hideBackgroundView != hideBackgroundView) {
        _hideBackgroundView = hideBackgroundView;
        [self configureBackgroundColor];
        [self setNeedsUpdateConstraints];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (IS_IPAD)
        return;
 
    // Make the scroll view scrollable when in landscape on the iPhone - the keyboard
    // covers up half of the view otherwise
    CGSize size = self.backgroundView.bounds.size;
    
    if (size.width > size.height) {
        size.height = size.height * 1.35;
    }
    
    self.scrollView.contentSize = size;
    
    CGRect rect = CGRectZero;
    if ([self.firstTextField isFirstResponder]) {
        rect = self.firstTextField.frame;
        rect = [self.scrollView convertRect:rect fromView:self.firstTextField];
    } else if([self.secondTextField isFirstResponder]) {
        rect = self.secondTextField.frame;
        rect = [self.scrollView convertRect:rect fromView:self.secondTextField];
    }
    
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

#pragma mark - IBAction Methods

- (IBAction)clickedOnButton1
{
    if (self.button1CompletionBlock) {
        self.button1CompletionBlock(self);
    }
}

- (IBAction)clickedOnButton2
{
    if (self.button2CompletionBlock) {
        self.button2CompletionBlock(self);
    }
}

#pragma mark - Private Methods

- (void)configureBackgroundColor
{
    CGFloat alpha = 0.95;
    if (self.hideBackgroundView) {
        alpha = 1.0;
    }
    self.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:alpha];
    self.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)addGestureRecognizer
{
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
    _gestureRecognizer.numberOfTapsRequired = 1;
    _gestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_gestureRecognizer];
}

- (void)configureView
{
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:25.0];
    self.descriptionLabel.font = [WPNUXUtility descriptionTextFont];
    self.bottomLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
}

- (void)configureButtonVisibility
{
    if (self.overlayMode == WPAlertViewOverlayModeTwoButtonMode ||
        self.overlayMode == WPAlertViewOverlayModeOneTextFieldTwoButtonMode ||
        self.overlayMode == WPAlertViewOverlayModeTwoTextFieldsTwoButtonMode ||
        self.overlayMode == WPAlertViewOverlayModeTwoTextFieldsSideBySideTwoButtonMode) {
        _leftButton.hidden = NO;
        _rightButton.hidden = NO;
    } else {
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
    }
}

- (void)configureTextFieldVisibility
{
    if (self.overlayMode == WPAlertViewOverlayModeOneTextFieldTwoButtonMode) {
        _firstTextField.hidden = NO;
        [_firstTextField becomeFirstResponder];
        _secondTextField.hidden = YES;
    } else if (self.overlayMode == WPAlertViewOverlayModeTwoTextFieldsTwoButtonMode ||
               self.overlayMode == WPAlertViewOverlayModeTwoTextFieldsSideBySideTwoButtonMode) {
        _firstTextField.hidden = NO;
        [_firstTextField becomeFirstResponder];
        _secondTextField.hidden = NO;
    } else {
        _firstTextField.hidden = YES;
        _secondTextField.hidden = YES;
    }
}

- (void)adjustOverlayDismissal
{
    if (self.overlayMode == WPAlertViewOverlayModeTapToDismiss) {
        _gestureRecognizer.numberOfTapsRequired = 1;
    } else if (self.overlayMode == WPAlertViewOverlayModeDoubleTapToDismiss) {
        _gestureRecognizer.numberOfTapsRequired = 2;
    } else {
        // This is for the two button mode, we still want the gesture recognizer to fire off
        // as it will redirect the button taps to the correct target. Plus we also enable
        // tap to dismiss for the two button mode.
        _gestureRecognizer.numberOfTapsRequired = 1;
    }
}


- (void)tappedOnView:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    
    // To avoid accidentally dismissing the view when the user was trying to tap one of the buttons,
    // add some padding around the button frames.
    CGRect button1Frame = CGRectInset([self.leftButton convertRect:self.leftButton.frame toView:self], -2 * WPAlertViewStandardOffset, -WPAlertViewStandardOffset);
    CGRect button2Frame = CGRectInset([self.rightButton convertRect:self.rightButton.frame toView:self], -2 * WPAlertViewStandardOffset, -WPAlertViewStandardOffset);
    
    BOOL touchedButton1 = CGRectContainsPoint(button1Frame, touchPoint);
    BOOL touchedButton2 = CGRectContainsPoint(button2Frame, touchPoint);
    
    if (touchedButton1 || touchedButton2)
        return;
    
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        if (self.singleTapCompletionBlock) {
            self.singleTapCompletionBlock(self);
        }
    } else if (gestureRecognizer.numberOfTapsRequired == 2) {
        if (self.doubleTapCompletionBlock) {
            self.doubleTapCompletionBlock(self);
        }
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];
}

@end
