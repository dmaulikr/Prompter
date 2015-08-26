//
//  SpeechViewController.m
//  Prompter
//
//  Created by Christian Villa on 8/25/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "SpeechViewController.h"

@interface SpeechViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation SpeechViewController

# pragma - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareDateAndText];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if ([self.noteTextView.text isEqualToString:@""]) {
            if ([self.navigationItem.title isEqualToString:@"Edit Speech"]) {
                [self.managedObjectContext deleteObject:self.noteSelected];
            }
        } else {
            if ([self.navigationItem.title isEqualToString:@"New Speech"]) {
                [self saveSpeech];
            } else if ([self.navigationItem.title isEqualToString:@"Edit Speech"]) {
                NSString *text = self.noteSelected.text;
                if (![text isEqualToString:self.noteTextView.text]) {
                    [self updateSpeech];
                }
            }
        }
        [self saveManagedObjectContext];
    }
}

# pragma - Navigation Controller Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

# pragma - Text View Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateDateLabel];
}

# pragma - Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Delete Speech"]) {
        self.noteTextView.text = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

# pragma - Mail Compose Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma - Notification Methods

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillBeShown:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.noteTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    self.noteTextView.scrollIndicatorInsets = self.noteTextView.contentInset;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    self.noteTextView.contentInset = UIEdgeInsetsZero;
    self.noteTextView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

# pragma - Action Methods

- (IBAction)hideButtonPressed:(UIBarButtonItem *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.noteTextView resignFirstResponder];
}

- (IBAction)trashButtonPressed:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Delete Speech"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}
- (IBAction)emailButtonPressed:(UIButton *)sender {
    MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init];
    [emailComposer setMailComposeDelegate:self];
    [emailComposer setSubject:@"You received a speech from Prompter!"];
    [emailComposer setMessageBody:self.noteTextView.text isHTML:NO];
    [self presentViewController:emailComposer animated:YES completion:nil];
}

- (void)updateDateLabel {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy, h:mm a"];
    NSDate *currentDate = [[NSDate alloc] init];
    self.dateLabel.text = [dateFormat stringFromDate:currentDate];
}

- (void)prepareDateAndText {
    if ([self.navigationItem.title isEqualToString:@"New Speech"]) {
        [self updateDateLabel];
        self.noteTextView.text = @"";
    } else if ([self.navigationItem.title isEqualToString:@"Edit Speech"]) {
        self.dateLabel.text = self.noteSelected.dateUpdated;
        self.noteTextView.text = self.noteSelected.text;
    }
}

- (NSString *)sortDescriptorForNote {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy          HH:mm:ss a"];
    NSDate *currentDate = [[NSDate alloc] init];
    return [dateFormat stringFromDate:currentDate];
}

- (void)saveSpeech {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:self.managedObjectContext];
    Note *note = [[Note alloc] initWithEntity:entityDescription
               insertIntoManagedObjectContext:self.managedObjectContext];
    note.dateUpdated = self.dateLabel.text;
    note.text = self.noteTextView.text;
    note.sortDescriptor = [self sortDescriptorForNote];
}

- (void)updateSpeech {
    self.noteSelected.dateUpdated = self.dateLabel.text;
    self.noteSelected.text = self.noteTextView.text;
    self.noteSelected.sortDescriptor = [self sortDescriptorForNote];
}

- (void)saveManagedObjectContext {
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Uh oh! I was unable to save your speech!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
