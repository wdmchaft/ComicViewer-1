//
//  VolumnListController.m
//  ComicViewer
//
//  Created by Gongwei Zhang on 4/1/12.
//  Copyright (c) 2012 autodesk. All rights reserved.
//

#import "VolumnListController.h"
#import "KangDmParser.h"
#import "AFHTTPRequestOperation.h"
#import "VolumnPhotoSource.h"
#import "EGOPhotoViewController.h"



@implementation VolumnListController

@synthesize comicUrl = _comicUrl;

#pragma mark memory management
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _comicUrl = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_items release];
    [_comicUrl release];
}

#pragma mark parse html

-(void) setComicUrl:(NSURL *)comicUrl
{
    [_comicUrl release];
    _comicUrl = [comicUrl retain];
    
    AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:_comicUrl]];
    request.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        VolumnListParser *parser = [[KangDmVolumnListParser alloc] initwithData:responseObject forUrl:_comicUrl error:nil];
        int insertIdx = [_items count];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        for (VolumnItem *item in parser.list) {
            [_items insertObject:item atIndex:insertIdx];
            [indexArray addObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]];
            ++insertIdx;
        }
        
        [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
        [indexArray release];
        [parser release];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error to Get List URL: %@ with Error: %@", _comicUrl, error);
    }];
    
    [request start];
    [request release];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    VolumnItem *item = [_items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [item.url absoluteString];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: reduce souce parse time to improve view response
    
    VolumnItem *item = [_items objectAtIndex:indexPath.row];
    VolumnPhotoSource *source = [[VolumnPhotoSource alloc] initWithVolumnURL: item.url];
    EGOPhotoViewController *photoConroller = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoConroller];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:navController animated:YES];
    
    [navController release];
    [photoConroller release];
    [source release];
}

@end
