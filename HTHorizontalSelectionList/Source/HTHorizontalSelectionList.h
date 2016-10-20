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

NS_ASSUME_NONNULL_BEGIN

@interface HTHorizontalSelectionList : UIView

/**
    Returns selected button index or -1 if nothing selected.  To animate changing the selected button, use -setSelectedButtonIndex:animated:.
    NOTE: this value will persist between calls to -reloadData.
 */
@property (nonatomic) NSInteger selectedButtonIndex;

@property (nonatomic, weak, nullable) id<HTHorizontalSelectionListDataSource> dataSource;
@property (nonatomic, weak, nullable) id<HTHorizontalSelectionListDelegate> delegate;

@property (nonatomic) CGFloat horizontalMargin;
@property (nonatomic) CGFloat selectionIndicatorHeight;
@property (nonatomic) CGFloat selectionIndicatorHorizontalPadding;
@property (nonatomic, strong) UIColor *selectionIndicatorColor;
@property (nonatomic, strong) UIColor *bottomTrimColor;

/// Default is NO
@property (nonatomic) BOOL bottomTrimHidden;

/// Default is NO.  If set to YES, the buttons will fade away near the edges of the list.
@property (nonatomic) BOOL showsEdgeFadeEffect;

/// Default is NO.  Centers buttons within the selection list.  Has no effect if the buttons do not fill the space horizontally.
@property (nonatomic) BOOL centerButtons;

/// Default is YES.  Controls how buttons are aligned when centered.  Has no effect if `centerButtons` is NO.
/// When set to YES, buttons will be spaced evenly within the selection list.
/// If NO, buttons will clustered together in the center of the selection list (with the standard button padding between adjacent items).
@property (nonatomic) BOOL evenlySpaceButtons;

/// Default is NO.  If YES, the selected button will be centered on selection.
@property (nonatomic) BOOL centerOnSelection;

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

@end

@protocol HTHorizontalSelectionListDataSource <NSObject>

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList;

@optional
- (nullable NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index;
- (nullable UIView *)selectionList:(HTHorizontalSelectionList *)selectionList viewForItemWithIndex:(NSInteger)index;

- (nullable NSString *)selectionList:(HTHorizontalSelectionList *)selectionList badgeValueForItemWithIndex:(NSInteger)index;

@end

@protocol HTHorizontalSelectionListDelegate <NSObject>

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
