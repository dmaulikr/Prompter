//
//  SpeechesTableViewController.m
//  Prompter
//
//  Created by Christian Villa on 8/25/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "AppDelegate.h"
#import "Note.h"
#import "SpeechesTableViewController.h"
#import "SpeechTableViewCell.h"
#import "SpeechViewController.h"

@interface SpeechesTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SpeechesTableViewController

# pragma - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareNavigationBar];
    [self prepareCoreData];
}

# pragma - Table View Data Source and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.fetchedResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpeechTableViewCell *speechCell = (SpeechTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SpeechCell"
                                                                                                  forIndexPath:indexPath];
    [self configureSpeechCell:speechCell AtIndexPath:indexPath];
    return speechCell;
}

- (SpeechTableViewCell *)configureSpeechCell:(SpeechTableViewCell *)speechCell AtIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    speechCell.notePreviewLabel.text = note.text;
    NSString *dateString = note.sortDescriptor;
    NSArray *dateComponents = [dateString componentsSeparatedByString:@" "];
    speechCell.dateUpdatedLabel.text = [dateComponents objectAtIndex:0];
    return speechCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:note];
    }
}

# pragma - Navigation Controller Methods

- (void)prepareNavigationBar {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(73.0/255.0)
                                                                           green:(220.0/255.0)
                                                                            blue:(189.0/255.0)
                                                                           alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [UIColor whiteColor],
                                                                   NSForegroundColorAttributeName,
                                                                   [UIFont fontWithName:@"AvenirNext-Bold"
                                                                                   size:21.0],
                                                                   NSFontAttributeName,
                                                                   nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SpeechViewController *SVC = (SpeechViewController *)segue.destinationViewController;
    SVC.managedObjectContext = self.managedObjectContext;
    if ([segue.identifier isEqualToString:@"NewSpeechSegue"]) {
        SVC.navigationItem.title = @"New Speech";
    } else if ([segue.identifier isEqualToString:@"EditSpeechSegue"]) {
        SVC.navigationItem.title = @"Edit Speech";
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SVC.noteSelected = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

# pragma - Core Data Methods

- (void)prepareCoreData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"sortDescriptor"
                                                                 ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Uh oh! I cannot fetch your speeches!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

# pragma - Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            SpeechTableViewCell *speechCell = (SpeechTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self configureSpeechCell:speechCell AtIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

@end
