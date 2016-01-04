//
//  HTHorizontalSelectionList.h
//  Hightower
//
//  Created by Erik Ackermann on 7/31/14.
//  Copyright (c) 2014 Hightower Inc. All rights reserved.
//

@import UIKit;

@protocol HTHorizontalSelectionListDataSource;
@protocol HTHorizontalSelectionListDelegate;

typedef NS_ENUM(NSInteger, HTHorizontalSelectionIndicatorStyle) {
    HTHorizontalSelectionIndicatorStyleBottomBar,           // Default
    HTHorizontalSelectionIndicatorStyleButtonBorder,
    HTHorizontalSelectionIndicatorStyleNone
};

typedef NS_ENUM(NSInteger, HTHorizontalSelectionIndicatorAnimationMode) {
    HTHorizontalSelectionIndicatorAnimationModeHeavyBounce,     // Default
    HTHorizontalSelectionIndicatorAnimationModeLightBounce,
    HTHorizontalSelectionIndicatorAnimationModeNoBounce
};

@interface HTHorizontalSelectionList : UIView

/**
    Returns selected button index or -1 if nothing selected.  To animate changing the selected button, use -setSelectedButtonIndex:animated:.
    NOTE: this value will persist between calls to -reloadData.
 */
@property (nonatomic) NSInteger selectedButtonIndex;

@property (nonatomic, weak) id<HTHorizontalSelectionListDataSource> dataSource;
@property (nonatomic, weak) id<HTHorizontalSelectionListDelegate> delegate;

@property (nonatomic) CGFloat selectionIndicatorHeight;
@property (nonatomic) CGFloat selectionIndicatorHorizontalPadding;
@property (nonatomic, strong) UIColor *selectionIndicatorColor;
@property (nonatomic, strong) UIColor *bottomTrimColor;

/// Default is NO
@property (nonatomic) BOOL bottomTrimHidden;

/// Default is NO.  If set to YES, the buttons will fade away near the edges of the list.
@property (nonatomic) BOOL showsEdgeFadeEffect;

/// Default is NO.  Only has an affect if the number of buttons in the selection list does not fill the space horizontally.
@property (nonatomic) BOOL centerAlignButtons;

/// Default is NO.  If YES, the selected button will be centered on selection.
@property (nonatomic) BOOL centerOnSelection;

/// Default is NO.  If YES, buttons will be aligned to center in view.
@property (nonatomic) BOOL centerButtons;

/// Default is NO.  If YES, forces the centermost button to be centered after dragging.
@property (nonatomic) BOOL snapToCenter;

/// Default is NO.  If YES, as the user drags the selection list, the central button will automatically become selected.
@property (nonatomic) BOOL autoselectCentralItem;

@property (nonatomic) HTHorizontalSelectionIndicatorAnimationMode selectionIndicatorAnimationMode;

@property (nonatomic) UIEdgeInsets buttonInsets;

@property (nonatomic) HTHorizontalSelectionIndicatorStyle selectionIndicatorStyle;

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state;

- (void)reloadData;

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex animated:(BOOL)animated;

// Deprecations

@property (nonatomic) BOOL autocorrectCentralItemSelection __attribute__((deprecated("Use snapToCenter instead.")));

@end

@protocol HTHorizontalSelectionListDataSource <NSObject>

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList;

@optional
- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index;
- (UIView *)selectionList:(HTHorizontalSelectionList *)selectionList viewForItemWithIndex:(NSInteger)index;

@end

@protocol HTHorizontalSelectionListDelegate <NSObject>

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index;

@end
