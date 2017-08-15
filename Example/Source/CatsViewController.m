//
//  CatsViewController.m
//  HTHorizontalSelectionList Example
//
//  Created by Erik Ackermann on 2/5/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

#import "CatsViewController.h"

#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "Masonry.h"

@interface CatsViewController () <HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>

@property (nonatomic, strong) HTHorizontalSelectionList *customViewSelectionList;
@property (nonatomic, strong) NSArray<UIImageView *> *spaceCats;

@property (nonatomic, strong) UIView *selectedSpaceCatView;

@property (nonatomic) BOOL filtered;
@property (nonatomic) UIImageView *selectedSpaceCatImageView;

@end

@implementation CatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.customViewSelectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectZero];
    self.customViewSelectionList.delegate = self;
    self.customViewSelectionList.dataSource = self;

    self.customViewSelectionList.selectionIndicatorStyle = HTHorizontalSelectionIndicatorStyleButtonBorder;
    self.customViewSelectionList.selectionIndicatorColor = [UIColor redColor];
    self.customViewSelectionList.bottomTrimHidden = YES;
    self.customViewSelectionList.showsEdgeFadeEffect = YES;

    self.customViewSelectionList.buttonInsets = UIEdgeInsetsMake(15, 10, 15, 10);

    self.spaceCats = @[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spacecat1.jpeg"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spacecat2.jpeg"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spacecat3.jpeg"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spacecat4.jpeg"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spacecat5.jpeg"]]];

    [self.view addSubview:self.customViewSelectionList];
    [self.customViewSelectionList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view).offset(0);
        make.height.equalTo(@100);
    }];

    self.selectedSpaceCatView = [[UIView alloc] init];
    UIImage *selectedImage = ((UIImageView *)self.spaceCats[self.customViewSelectionList.selectedButtonIndex]).image;
    self.selectedSpaceCatView.backgroundColor = [UIColor colorWithPatternImage:selectedImage];
    self.selectedSpaceCatView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.selectedSpaceCatView];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectedSpaceCatView]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_selectedSpaceCatView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_customViewSelectionList][_selectedSpaceCatView]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_customViewSelectionList, _selectedSpaceCatView)]];

    UIButton *filterToggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    filterToggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [filterToggleButton setTitle:@"Filter Selection List" forState:UIControlStateNormal];

    filterToggleButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    filterToggleButton.backgroundColor = [UIColor whiteColor];
    filterToggleButton.layer.cornerRadius = 3.0;

    [filterToggleButton addTarget:self
                           action:@selector(filterToggleButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];

    filterToggleButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:filterToggleButton];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:filterToggleButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:filterToggleButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-20.0]];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return self.spaceCats.count;
}

- (UIView *)selectionList:(HTHorizontalSelectionList *)selectionList viewForItemWithIndex:(NSInteger)index {
    return self.spaceCats[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    self.selectedSpaceCatImageView = self.spaceCats[index];
    UIImage *selectedImage = self.spaceCats[index].image;
    self.selectedSpaceCatView.backgroundColor = [UIColor colorWithPatternImage:selectedImage];
}

#pragma mark - Action Handlers

- (void)filterToggleButtonTapped:(id)sender {
    self.filtered = !self.filtered;

    [self.customViewSelectionList reloadData];

    // NOTE: After changing the selection list data source and reloading,
    // it is up to the data source to reselect the correct button
    // (or deselect everything by setting |selectedButtonIndex| to -1)
    NSInteger selectedButtonIndex = [self.spaceCats indexOfObject:self.selectedSpaceCatImageView];
    self.customViewSelectionList.selectedButtonIndex = selectedButtonIndex != NSNotFound ? selectedButtonIndex : -1;
}

#pragma mark - Custom Getters and Setters

- (NSArray *)spaceCats {
    if (self.filtered) {
        // take only the second half of the |spaceCats| array
        return [_spaceCats subarrayWithRange:NSMakeRange(_spaceCats.count/2, _spaceCats.count/2)];
    }

    return _spaceCats;
}

@end
