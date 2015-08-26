//
//  PromptViewController.m
//  Prompter
//
//  Created by Christian Villa on 8/26/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "PromptViewController.h"

@interface PromptViewController ()

@property (weak, nonatomic) IBOutlet UITextView *speechTextView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIButton *promptButton;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat currentSpeed;
@property (nonatomic) NSInteger currentLocation;

@property (nonatomic) BOOL speechIsPrompting;
@property (nonatomic) BOOL bottomBarIsHidden;

@property (nonatomic) NSInteger fontSize;

@end

@implementation PromptViewController

# pragma - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.speechTextView.selectable = NO;
    self.speechTextView.text = self.speechText;
    self.currentLocation = 0;
    self.currentSpeed = fabs(self.speedSlider.value - self.speedSlider.maximumValue);
    self.speechIsPrompting = NO;
    self.bottomBarIsHidden = NO;
    self.fontSize = self.speechTextView.font.pointSize;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

# pragma - Gesture Methods

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapLocation = [gestureRecognizer locationInView:self.view];
    CGRect tapArea = CGRectMake(0, 0, self.speechTextView.bounds.size.width, (self.speechTextView.bounds.size.height - self.bottomLabel.bounds.size.height));
    if (CGRectContainsPoint(tapArea, tapLocation)) {
        self.bottomLabel.hidden = !self.bottomBarIsHidden;
        self.promptButton.hidden = !self.bottomBarIsHidden;
        self.speedSlider.hidden = !self.bottomBarIsHidden;
        self.editButton.hidden = !self.bottomBarIsHidden;
        self.bottomBarIsHidden = !self.bottomBarIsHidden;
    }
}

# pragma - Navigation Controller Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

# pragma - Animation Methods

- (void)updateLocation {
    self.speechTextView.contentOffset = CGPointMake(0, self.currentLocation);
    self.currentLocation += 1;
    if (self.currentLocation >= (self.speechTextView.contentSize.height - self.speechTextView.frame.size.height)) {
        [self.timer invalidate];
        self.timer = nil;
        [self.promptButton setTitle:@"▶︎"
                           forState:UIControlStateNormal];
        self.speechIsPrompting = NO;
    }
}

- (void)animateTextView {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.currentSpeed
                                                      target:self
                                                    selector:@selector(updateLocation)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

# pragma - Action Methods

- (IBAction)promptButtonPressed:(UIButton *)sender {
    if (!self.speechIsPrompting) {
        if (self.currentLocation >= (self.speechTextView.contentSize.height - self.speechTextView.frame.size.height)) {
            self.currentLocation = -200;
        } else {
            self.currentLocation = self.speechTextView.contentOffset.y;
        }
        [self animateTextView];
        self.speechIsPrompting = YES;
        [sender setTitle:@"| |"
                forState:UIControlStateNormal];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        self.speechIsPrompting = NO;
        [sender setTitle:@"▶︎"
                forState:UIControlStateNormal];
    }
}

- (IBAction)speedSliderMoved:(UISlider *)sender {
    self.currentSpeed = fabs(sender.value - self.speedSlider.maximumValue);
    [self.timer invalidate];
    self.timer = nil;
    if (self.speechIsPrompting) {
        [self animateTextView];
    }
}

- (IBAction)sizeButtonPressed:(UIButton *)sender {
    self.fontSize += 10;
    if (self.fontSize > 70) {
        self.fontSize = 30;
    }
    self.speechTextView.font = [UIFont fontWithName:@"AvenirNext-Medium"
                                               size:self.fontSize];
}

@end
