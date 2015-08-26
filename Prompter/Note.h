//
//  Note.h
//  Prompter
//
//  Created by Christian Villa on 8/25/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * dateUpdated;
@property (nonatomic, retain) NSString * sortDescriptor;

@end
