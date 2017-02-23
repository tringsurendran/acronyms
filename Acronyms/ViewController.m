//
//  ViewController.m
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/23/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import "ViewController.h"
#import "AcronymResultObject.h"
#import "MBProgressHUD.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) UILabel *titlelabel;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITableView *resultTableView;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSArray *results;
@property (nonatomic) MBProgressHUD *progressView;
@property (nonatomic) UILabel *noResultFoundLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titlelabel = [[UILabel alloc] init];
    [self.titlelabel setText:@"Enter an acronym"];
    [self.view addSubview:self.titlelabel];
    
    self.textField = [[UITextField alloc] init];
    [self.textField setPlaceholder:@"eg: NASA"];
    [self.textField setBorderStyle:UITextBorderStyleLine];
    self.textField.delegate = self;
    self.textField.clearsOnBeginEditing = YES;
    self.textField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.textField];

    self.resultTableView = [[UITableView alloc] init];
    [self.view addSubview:self.resultTableView];
    self.resultTableView.dataSource = self;
    self.resultTableView.delegate = self;
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    self.noResultFoundLabel = [[UILabel alloc] init];
    [self.noResultFoundLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.view addSubview:self.noResultFoundLabel];
    [self.noResultFoundLabel setText:@"No Results Found"];
    [self.noResultFoundLabel setHidden:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.titlelabel sizeToFit];
    CGFloat topPadding = 20;
    CGFloat leftPadding = 16;
    CGFloat verticalItemSpacing = 10;
    CGFloat titlelabelX = (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.titlelabel.frame)) / 2;
    self.titlelabel.frame = CGRectMake(titlelabelX, topPadding, self.titlelabel.frame.size.width, self.titlelabel.frame.size.height);
    CGFloat textFieldHeight = 40;
    self.textField.frame = CGRectMake(leftPadding, CGRectGetMaxY(self.titlelabel.frame) +  verticalItemSpacing, CGRectGetWidth(self.view.bounds) - (leftPadding * 2), textFieldHeight);
    self.resultTableView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame) +  verticalItemSpacing, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.textField.frame) - verticalItemSpacing);
    self.noResultFoundLabel.frame = CGRectMake(leftPadding, CGRectGetMaxY(self.textField.frame) + 5, 0, 0);
    [self.noResultFoundLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getResult {
    self.progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressView.removeFromSuperViewOnHide = YES;
    NSString *urlString = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@",self.textField.text];
    // TODO : Create a Network Manager
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            self.results = nil;
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string) {
            
        }
        id result =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *objects = [NSMutableArray new];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [objects addObject:[[AcronymResultObject alloc] initWithDict:obj]];
            }];
            self.results = objects;
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }] resume];

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
