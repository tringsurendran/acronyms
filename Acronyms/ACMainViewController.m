//
//  ViewController.m
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/23/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import "ACMainViewController.h"
#import "AcronymResultObject.h"
#import "MBProgressHUD.h"
#import "ACNetworkManager.h"

@interface ACMainViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) UILabel *titlelabel;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITableView *resultTableView;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSArray *results;
@property (nonatomic) MBProgressHUD *progressView;
@property (nonatomic) UILabel *noResultFoundLabel;

@end

@implementation ACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titlelabel = [[UILabel alloc] init];
    [self.titlelabel setText:@"Enter an acronym"];
    [self.view addSubview:self.titlelabel];
    [self.titlelabel setTextAlignment:NSTextAlignmentCenter];
    self.titlelabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.textField = [[UITextField alloc] init];
    [self.textField setPlaceholder:@"eg: NASA"];
    [self.textField setBorderStyle:UITextBorderStyleLine];
    self.textField.delegate = self;
    self.textField.clearsOnBeginEditing = YES;
    self.textField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.textField];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;

    self.resultTableView = [[UITableView alloc] init];
    [self.view addSubview:self.resultTableView];
    self.resultTableView.dataSource = self;
    self.resultTableView.delegate = self;
    self.resultTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.noResultFoundLabel = [[UILabel alloc] init];
    [self.noResultFoundLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.view addSubview:self.noResultFoundLabel];
    [self.noResultFoundLabel setText:@"No Results Found"];
    [self.noResultFoundLabel setHidden:YES];
    self.noResultFoundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *bindings = @{@"titleLabel": self.titlelabel, @"textField": self.textField, @"tableView": self.resultTableView, @"noResultFoundLabel" : self.noResultFoundLabel};
    CGFloat padding = 16;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[titleLabel]-(10)-[textField]-(2)-[noResultFoundLabel]-(10)-[tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titlelabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noResultFoundLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noResultFoundLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-padding]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getResult {
    self.progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressView.removeFromSuperViewOnHide = YES;
    __weak ACMainViewController *weakSelf = self;
    [[ACNetworkManager sharedInstance] getDetailsForAcronyms:self.textField.text completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ACMainViewController *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.results = nil;
            if (!error) {
                id result =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([result isKindOfClass:[NSArray class]]) {
                    NSMutableArray *objects = [NSMutableArray new];
                    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [objects addObject:[[AcronymResultObject alloc] initWithDict:obj]];
                    }];
                    strongSelf.results = objects;
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf reloadData];
            });
        }
    }];
}

- (void)reloadData {
    [self.progressView hideAnimated:YES];
    [self.textField setUserInteractionEnabled:YES];
    if (self.results == nil || [self.results count] == 0) {
        [self.noResultFoundLabel setHidden:NO];
    }
    [self.resultTableView reloadData];
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.noResultFoundLabel setHidden:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self getResult];
    [self.textField resignFirstResponder];
    [self.textField setUserInteractionEnabled:NO];
    return YES;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // TODO : Customize the cells
    AcronymResultObject *acronymResultObject = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = acronymResultObject.fullForm;
    cell.detailTextLabel.text = acronymResultObject.since;
    return cell;
}

@end
