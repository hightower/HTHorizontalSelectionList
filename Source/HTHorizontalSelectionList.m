//
//  HTHorizontalSelectionList.m
//  Hightower
//
//  Created by Erik Ackermann on 7/31/14.
//  Copyright (c) 2014 Hightower Inc. All rights reserved.
//

#import "HTHorizontalSelectionList.h"
#import "HTHorizontalSelectionListLabelCell.h"
#import "HTHorizontalSelectionListCustomViewCell.h"

@interface HTHorizontalSelectionList () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) UIView *selectionIndicatorBar;
@property (nonatomic, strong) UIView *bottomTrim;

@property (nonatomic, strong) NSMutableDictionary *titleColorsByState;
@property (nonatomic, strong) NSMutableDictionary *titleFontsByState;

@property (nonatomic, strong) UIView *edgeFadeGradientView;
@property (assign, nonatomic) BOOL scrollingDirectly;

@end

const CGFloat kHTHorizontalSelectionListTrimHeight = 0.5;
const CGFloat kHTHorizontalSelectionListLabelCellInternalPadding = 15;

static NSString *LabelCellIdentifier = @"LabelCell";
static NSString *ViewCellIdentifier = @"ViewCell";

@implementation HTHorizontalSelectionList

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGSize )intrinsicContentSize {
#ifdef __IPHONE_11_0
    if(@available(iOS 11.0, *))
    {
        if([self.superview.superview isKindOfClass: [UINavigationBar class]])
            return UILayoutFittingExpandedSize;
    }
#endif
    return UILayoutFittingCompressedSize;
}

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.scrollsToTop = NO;
    _collectionView.canCancelContentTouches = YES;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_collectionView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_collectionView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_collectionView)]];

    [_collectionView registerClass:[HTHorizontalSelectionListLabelCell class] forCellWithReuseIdentifier:LabelCellIdentifier];
    [_collectionView registerClass:[HTHorizontalSelectionListCustomViewCell class] forCellWithReuseIdentifier:ViewCellIdentifier];

    _edgeFadeGradientView = [[UIView alloc] init];
    _edgeFadeGradientView.backgroundColor = self.backgroundColor;
    _edgeFadeGradientView.hidden = YES;
    _edgeFadeGradientView.userInteractionEnabled = NO;
    _edgeFadeGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_edgeFadeGradientView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_edgeFadeGradientView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_edgeFadeGradientView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_edgeFadeGradientView]-trimHeight-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:@{@"trimHeight" : @(kHTHorizontalSelectionListTrimHeight)}
                                                                   views:NSDictionaryOfVariableBindings(_edgeFadeGradientView)]];

    [_collectionView addObserver:self
                      forKeyPath:@"contentSize"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];

    _contentView = [[UIScrollView alloc] init];
    _contentView.userInteractionEnabled = NO;
    _contentView.scrollsToTop = NO;
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_contentView)]];
    _bottomTrim = [[UIView alloc] init];
    _bottomTrim.backgroundColor = [UIColor blackColor];
    _bottomTrim.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomTrim];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomTrim]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_bottomTrim)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomTrim(height)]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:@{@"height" : @(kHTHorizontalSelectionListTrimHeight)}
                                                                   views:NSDictionaryOfVariableBindings(_bottomTrim)]];

    _buttonInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    _selectionIndicatorHeight = 3;
    _selectionIndicatorHorizontalPadding = kHTHorizontalSelectionListLabelCellInternalPadding/2;
    _selectionIndicatorStyle = HTHorizontalSelectionIndicatorStyleBottomBar;
    _selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeHeavyBounce;

    _selectionIndicatorBar = [[UIView alloc] init];
    _selectionIndicatorBar.translatesAutoresizingMaskIntoConstraints = NO;
    _selectionIndicatorBar.backgroundColor = [UIColor blackColor];

    _titleColorsByState = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal) : [UIColor blackColor]}];
    _titleFontsByState = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal) : [UIFont systemFontOfSize:13]}];

    _centerOnSelection = NO;
    _centerButtons = NO;
    _evenlySpaceButtons = YES;
    _scrollingDirectly = NO;
    _snapToCenter = NO;
    _autoselectCentralItem = NO;
    _horizontalMargin = 10;
}

- (void)layoutSubviews {
    [self reloadData];

    if (self.showsEdgeFadeEffect) {
        CAGradientLayer *maskLayer = [CAGradientLayer layer];

        CGColorRef outerColor = [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor];
        CGColorRef innerColor = [[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];

        maskLayer.colors = @[(__bridge id)outerColor,
                             (__bridge id)innerColor,
                             (__bridge id)innerColor,
                             (__bridge id)outerColor];

        maskLayer.locations = @[@0.0, @0.04, @0.96, @1.0];

        [maskLayer setStartPoint:CGPointMake(0, 0.5)];
        [maskLayer setEndPoint:CGPointMake(1, 0.5)];

        maskLayer.bounds = _collectionView.bounds;
        maskLayer.anchorPoint = CGPointZero;

        self.edgeFadeGradientView.layer.mask = maskLayer;

        [self bringSubviewToFront:self.edgeFadeGradientView];
    }

    [super layoutSubviews];
}

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - Custom Getters and Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    self.edgeFadeGradientView.backgroundColor = backgroundColor;
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex {
    [self setSelectedButtonIndex:selectedButtonIndex animated:NO];
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor {
    self.selectionIndicatorBar.backgroundColor = selectionIndicatorColor;

    if (!self.titleColorsByState[@(UIControlStateSelected)]) {
        self.titleColorsByState[@(UIControlStateSelected)] = selectionIndicatorColor;
    }
}

- (UIColor *)selectionIndicatorColor {
    return self.selectionIndicatorBar.backgroundColor;
}

- (void)setBottomTrimColor:(UIColor *)bottomTrimColor {
    self.bottomTrim.backgroundColor = bottomTrimColor;
}

- (UIColor *)bottomTrimColor {
    return self.bottomTrim.backgroundColor;
}

- (void)setBottomTrimHidden:(BOOL)bottomTrimHidden {
    self.bottomTrim.hidden = bottomTrimHidden;
}

- (BOOL)bottomTrimHidden {
    return self.bottomTrim.hidden;
}

- (void)setShowsEdgeFadeEffect:(BOOL)showEdgeFadeEffect {
    self.edgeFadeGradientView.hidden = !showEdgeFadeEffect;
}

- (BOOL)showsEdgeFadeEffect {
    return !self.edgeFadeGradientView.hidden;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];

    self.collectionView.allowsSelection = userInteractionEnabled;
}

#pragma mark - Public Methods

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    self.titleColorsByState[@(state)] = color;
}

- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state {
    self.titleFontsByState[@(state)] = font;
}

- (void)reloadData {
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    NSInteger totalButtons = [self.dataSource numberOfItemsInSelectionList:self];

    if (totalButtons < 1) {
        return;
    }

    if (_selectedButtonIndex > totalButtons - 1) {
        _selectedButtonIndex = -1;
    }

    if (self.selectionIndicatorStyle == HTHorizontalSelectionIndicatorStyleBottomBar) {
        [self.contentView layoutIfNeeded];
        self.selectionIndicatorBar.frame = CGRectMake(0,
                                                      self.contentView.frame.size.height - self.selectionIndicatorHeight,
                                                      0,
                                                      self.selectionIndicatorHeight);

        [self.contentView addSubview:self.selectionIndicatorBar];
    } else {
        [self.selectionIndicatorBar removeFromSuperview];
    }

    if (totalButtons > 0 && self.selectedButtonIndex >= 0 && self.selectedButtonIndex < totalButtons) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedButtonIndex inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:selectedIndexPath];

        ((id<HTHorizontalSelectionListCell>)cell).state = UIControlStateSelected;

        switch (self.selectionIndicatorStyle) {
            case HTHorizontalSelectionIndicatorStyleBottomBar: {
                [self alignSelectionIndicatorWithCellAtIndexPath:selectedIndexPath];
                break;
            }

            case HTHorizontalSelectionIndicatorStyleButtonBorder: {
                if ([self.delegate respondsToSelector:@selector(selectionList:viewForItemWithIndex:)]) {
                    ((HTHorizontalSelectionListCustomViewCell *)cell).customView.layer.borderColor = self.selectionIndicatorColor.CGColor;
                } else {
                    cell.layer.borderColor = self.selectionIndicatorColor.CGColor;
                }
                break;
            }

            default:
                break;
        }
    }

    [self sendSubviewToBack:self.bottomTrim];

    [self updateConstraintsIfNeeded];
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex animated:(BOOL)animated {

    NSInteger buttonCount = [self.dataSource numberOfItemsInSelectionList:self];

    NSInteger oldSelectedIndex = _selectedButtonIndex;
    if (selectedButtonIndex < buttonCount && selectedButtonIndex >= 0) {
        _selectedButtonIndex = selectedButtonIndex;
    } else {
        _selectedButtonIndex = -1;
    }

    NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForItem:oldSelectedIndex inSection:0];
    NSIndexPath *selectedIndexPath = self.selectedButtonIndex >= 0 ? [NSIndexPath indexPathForItem:self.selectedButtonIndex inSection:0] : nil;

    UICollectionViewLayoutAttributes *selectedCellAttributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:selectedIndexPath];
    CGRect selectedCellFrame = selectedCellAttributes.frame;

    [self layoutIfNeeded];
    [UIView animateWithDuration:animated ? 0.4 : 0.0
                          delay:0
         usingSpringWithDamping:[self selectionIndicatorBarSpringDamping]
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         UICollectionViewCell *oldSelectedCell = [self.collectionView cellForItemAtIndexPath:oldSelectedIndexPath];
                         UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:selectedIndexPath];

                         ((id<HTHorizontalSelectionListCell>)selectedCell).state = UIControlStateSelected;

                         if (oldSelectedCell != selectedCell) {
                             ((id<HTHorizontalSelectionListCell>)oldSelectedCell).state = UIControlStateNormal;
                         }

                         switch (self.selectionIndicatorStyle) {
                             case HTHorizontalSelectionIndicatorStyleBottomBar: {
                                 [self alignSelectionIndicatorWithCellAtIndexPath:selectedIndexPath];
                                 break;
                             }

                             case HTHorizontalSelectionIndicatorStyleButtonBorder: {
                                 if ([self.delegate respondsToSelector:@selector(selectionList:viewForItemWithIndex:)]) {
                                     ((HTHorizontalSelectionListCustomViewCell *)selectedCell).customView.layer.borderColor = self.selectionIndicatorColor.CGColor;

                                     if (oldSelectedCell != selectedCell) {
                                         ((HTHorizontalSelectionListCustomViewCell *)oldSelectedCell).customView.layer.borderColor = [UIColor clearColor].CGColor;
                                     }
                                 } else {
                                     selectedCell.layer.borderColor = self.selectionIndicatorColor.CGColor;

                                     if (oldSelectedCell != selectedCell) {
                                         oldSelectedCell.layer.borderColor = [UIColor clearColor].CGColor;
                                     }
                                 }
                                 break;
                             }

                             case HTHorizontalSelectionIndicatorStyleNone: {
                                 selectedCell.layer.borderColor = [UIColor clearColor].CGColor;

                                 if (oldSelectedCell != selectedCell) {
                                     oldSelectedCell.layer.borderColor = [UIColor clearColor].CGColor;
                                 }
                                 break;
                             }
                         }

                         [self.collectionView scrollToItemAtIndexPath:selectedIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

                         if (self.centerOnSelection) {
                             [self.collectionView scrollToItemAtIndexPath:selectedCellAttributes.indexPath
                                                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                 animated:NO];
                         }

                         if (!self.autoselectCentralItem) {
                             [self.collectionView scrollRectToVisible:CGRectInset(selectedCellFrame, -self.horizontalMargin, 0)
                                                             animated:animated];
                         }
                     }
                     completion:nil];
}

#pragma mark - UICollectionViewDataSource Protocol Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSelectionList:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;

    BOOL isSelected = (indexPath.item == self.selectedButtonIndex);

    if ([self.dataSource respondsToSelector:@selector(selectionList:viewForItemWithIndex:)]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:ViewCellIdentifier
                                                         forIndexPath:indexPath];

        [((HTHorizontalSelectionListCustomViewCell *)cell) setCustomView:[self.dataSource selectionList:self viewForItemWithIndex:indexPath.item]
                                                                  insets:self.buttonInsets];
    } else if ([self.dataSource respondsToSelector:@selector(selectionList:titleForItemWithIndex:)]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LabelCellIdentifier
                                                         forIndexPath:indexPath];

        ((HTHorizontalSelectionListLabelCell *)cell).title = [self.dataSource selectionList:self titleForItemWithIndex:indexPath.item];

        for (NSNumber *controlState in [self.titleColorsByState allKeys]) {
            [((HTHorizontalSelectionListLabelCell *)cell) setTitleColor:self.titleColorsByState[controlState]
                                                               forState:controlState.integerValue];
        }

        for (NSNumber *controlState in [self.titleFontsByState allKeys]) {
            [((HTHorizontalSelectionListLabelCell *)cell) setTitleFont:self.titleFontsByState[controlState]
                                                              forState:controlState.integerValue];
        }
    }

    if ([self.dataSource respondsToSelector:@selector(selectionList:badgeValueForItemWithIndex:)]) {
        NSString *badgeValue = [self.dataSource selectionList:self badgeValueForItemWithIndex:indexPath.item];
        ((HTHorizontalSelectionListLabelCell *)cell).badgeValue = badgeValue;
    }

    if (self.selectionIndicatorStyle == HTHorizontalSelectionIndicatorStyleButtonBorder) {
        if ([self.delegate respondsToSelector:@selector(selectionList:viewForItemWithIndex:)]) {
            ((HTHorizontalSelectionListCustomViewCell *)cell).customView.layer.borderWidth = 1.0;
            ((HTHorizontalSelectionListCustomViewCell *)cell).customView.layer.cornerRadius = 3.0;
            ((HTHorizontalSelectionListCustomViewCell *)cell).customView.layer.borderColor = isSelected ? self.selectionIndicatorColor.CGColor : [UIColor clearColor].CGColor;
            ((HTHorizontalSelectionListCustomViewCell *)cell).customView.layer.masksToBounds = YES;
        } else {
            cell.layer.borderWidth = 1.0;
            cell.layer.cornerRadius = 3.0;
            cell.layer.borderColor = isSelected ? self.selectionIndicatorColor.CGColor : [UIColor clearColor].CGColor;
            cell.layer.masksToBounds = YES;
        }
    }

    if (isSelected) {
        ((id<HTHorizontalSelectionListCell>)cell).state = UIControlStateSelected;
    } else {
        ((id<HTHorizontalSelectionListCell>)cell).state = UIControlStateNormal;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Protocol Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat verticalPadding = self.buttonInsets.top + self.buttonInsets.bottom;
    CGFloat horizontalPadding = self.buttonInsets.left + self.buttonInsets.right;

    CGFloat collectionViewHeight = collectionView.frame.size.height;

    if ([self.dataSource respondsToSelector:@selector(selectionList:viewForItemWithIndex:)]) {
        UIView *view = [self.dataSource selectionList:self viewForItemWithIndex:indexPath.item];

        CGFloat buttonHeight = view.frame.size.height;
        CGFloat buttonWidth = view.frame.size.width;

        if (buttonHeight) {
            CGFloat itemHeight = collectionViewHeight - verticalPadding;

            CGFloat scaleFactor = itemHeight / buttonHeight;

            CGFloat itemWidth = (buttonWidth * scaleFactor) + horizontalPadding;

            return CGSizeMake(itemWidth, collectionViewHeight);
        } else {
            return CGSizeMake(buttonWidth, collectionViewHeight);
        }
    } else if ([self.dataSource respondsToSelector:@selector(selectionList:titleForItemWithIndex:)]) {
        NSString *title = [self.dataSource selectionList:self titleForItemWithIndex:indexPath.item];
        CGSize titleSize = [HTHorizontalSelectionListLabelCell sizeForTitle:title withFont:self.titleFontsByState[@(UIControlStateNormal)]];

        CGFloat width = titleSize.width + horizontalPadding + kHTHorizontalSelectionListLabelCellInternalPadding;

        return CGSizeMake(width, MAX(0, MIN(collectionViewHeight, collectionViewHeight - verticalPadding)));
    }

    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewFlowLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {

    NSInteger numberOfItems = [self.dataSource numberOfItemsInSelectionList:self];

    if (self.centerOnSelection) {

        if (numberOfItems > 0) {
            CGFloat firstItemWidth = [self collectionView:collectionView
                                                   layout:collectionViewLayout
                                   sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].width;

            CGFloat lastItemWidth = [self collectionView:collectionView
                                                  layout:collectionViewLayout
                                  sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems-1 inSection:section]].width;

            CGFloat halfWidth = CGRectGetWidth(collectionView.frame) / 2;

            return UIEdgeInsetsMake(0, halfWidth - (firstItemWidth / 2), 0, halfWidth - (lastItemWidth / 2));
        }

    } else if (self.centerButtons) {
        CGFloat extraSpace = collectionView.frame.size.width - 2*self.horizontalMargin;

        for (NSInteger item = 0; item < numberOfItems; item++) {
            extraSpace -= [self collectionView:collectionView
                                        layout:collectionViewLayout
                        sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]].width;

            if (extraSpace < 0) {
                break;
            }
        }

        if (self.evenlySpaceButtons) {
            if (extraSpace > 0 && numberOfItems > 0) {
                CGFloat inset = (extraSpace / (2 * numberOfItems)) + self.horizontalMargin;

                return UIEdgeInsetsMake(0, inset, 0, inset);
            }
        } else {
            extraSpace -= numberOfItems * self.horizontalMargin;

            if (extraSpace > 0 && numberOfItems > 0) {
                CGFloat inset = extraSpace / 2 + self.horizontalMargin;

                return UIEdgeInsetsMake(0, inset, 0, inset);
            }
        }
    }

    return UIEdgeInsetsMake(0, self.horizontalMargin, 0, self.horizontalMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

    return [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

    if (self.centerButtons) {
        if (!self.evenlySpaceButtons) {
            return self.horizontalMargin;
        }

        NSInteger numberOfItems = [self.dataSource numberOfItemsInSelectionList:self];

        CGFloat lineSpacing = collectionView.frame.size.width - 2*self.horizontalMargin;

        for (NSInteger item = 0; item < numberOfItems; item++) {
            lineSpacing -= [self collectionView:collectionView
                                         layout:collectionViewLayout
                         sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]].width;

            if (lineSpacing < 0) {
                break;
            }
        }

        if (lineSpacing > 0 && numberOfItems > 0) {
            return lineSpacing / numberOfItems;
        }
    }

    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.centerOnSelection) {
        self.scrollingDirectly = YES;
    }

    if (indexPath.item == self.selectedButtonIndex) {
        if (self.selectionIndicatorStyle == HTHorizontalSelectionIndicatorStyleNone) {
            if ([self.delegate respondsToSelector:@selector(selectionList:didSelectButtonWithIndex:)]) {
                [self.delegate selectionList:self didSelectButtonWithIndex:indexPath.item];
            }
        }

        return;
    }

    [self setSelectedButtonIndex:indexPath.item animated:YES];

    if ([self.delegate respondsToSelector:@selector(selectionList:didSelectButtonWithIndex:)]) {
        [self.delegate selectionList:self didSelectButtonWithIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    id<HTHorizontalSelectionListCell> cell = (id<HTHorizontalSelectionListCell>)[collectionView cellForItemAtIndexPath:indexPath];

    if (cell.state == UIControlStateSelected && self.selectionIndicatorStyle == HTHorizontalSelectionIndicatorStyleNone) {
        cell.state = UIControlStateHighlighted;
    } else if (cell.state != UIControlStateSelected) {
        cell.state = UIControlStateHighlighted;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    id<HTHorizontalSelectionListCell> cell = (id<HTHorizontalSelectionListCell>)[collectionView cellForItemAtIndexPath:indexPath];

    if (self.selectedButtonIndex == indexPath.item) {
        cell.state = UIControlStateSelected;
    } else {
        cell.state = UIControlStateNormal;
    }
}
#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        CGPoint offset = self.contentView.contentOffset;
        offset.x = scrollView.contentOffset.x;
        [self.contentView setContentOffset:offset];

        if (self.autoselectCentralItem && !self.scrollingDirectly) {

            CGPoint centerPoint = CGPointMake(self.collectionView.frame.size.width / 2 + scrollView.contentOffset.x,
                                              self.collectionView.frame.size.height /2 + scrollView.contentOffset.y);

            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];

            if (indexPath && self.selectedButtonIndex != indexPath.item) {

                [self setSelectedButtonIndex:indexPath.item animated:YES];

                if ([self.delegate respondsToSelector:@selector(selectionList:didSelectButtonWithIndex:)]) {
                    [self.delegate selectionList:self didSelectButtonWithIndex:indexPath.item];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.scrollingDirectly = NO;

        if (self.snapToCenter) {
            [self correctSelection:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.scrollingDirectly = NO;

    if (self.snapToCenter) {
        [self correctSelection:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollingDirectly = NO;
}

- (void)correctSelection:(UIScrollView *)scrollView {
    CGPoint centerPoint = CGPointMake(self.collectionView.frame.size.width / 2 + scrollView.contentOffset.x, self.collectionView.frame.size.height /2 + scrollView.contentOffset.y);

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];

    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        self.contentView.contentSize = [(NSValue *)change[NSKeyValueChangeNewKey] CGSizeValue];
    }
}

#pragma mark - Private Methods

- (void)alignSelectionIndicatorWithCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGRect cellRect = attributes.frame;

        self.selectionIndicatorBar.frame = CGRectMake(cellRect.origin.x + self.buttonInsets.left + kHTHorizontalSelectionListLabelCellInternalPadding/2 - self.selectionIndicatorHorizontalPadding,
                                                      self.contentView.frame.size.height - self.selectionIndicatorHeight,
                                                      cellRect.size.width - self.buttonInsets.left - self.buttonInsets.right - kHTHorizontalSelectionListLabelCellInternalPadding + 2*self.selectionIndicatorHorizontalPadding,
                                                      self.selectionIndicatorHeight);
    }
}

- (CGFloat)selectionIndicatorBarSpringDamping {
    switch (self.selectionIndicatorAnimationMode) {
        case HTHorizontalSelectionIndicatorAnimationModeHeavyBounce:
        default:
            return 0.5;

        case HTHorizontalSelectionIndicatorAnimationModeLightBounce:
            return 0.8;

        case HTHorizontalSelectionIndicatorAnimationModeNoBounce:
            return 1.0;
    }
}

@end
