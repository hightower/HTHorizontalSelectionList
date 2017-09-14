HTHorizontalSelectionList
=========================

A simple, horizontally-scrolling list of items that can be used as a more flexible replacement for UISegmentedControl

## Example

A simple side-scrolling list of items (perhaps filters for a UITableView below).
![alt tag](docs/car_list.gif)

## Setup via CocoaPods

Add HTHorizontalSelectionList pod into your Podfile
```
pod 'HTHorizontalSelectionList', '~> 0.7.4'
```

## Usage
### Setup and Initialization

To begin using HTHorizontalSelectionList, import the main header:
```objc
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
```

The horizontal selection list uses a data-source/delegate model (similar to UITableView or UIPickerView).  To setup a simple horizontal selection list, init the view and set it's delegate and data source:
```objc
@interface CarListViewController () <HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic, strong) NSArray *carMakes;

@end

@implementation CarListViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
	self.selectionList.delegate = self;
	self.selectionList.dataSource = self;

	self.carMakes = @[@"ALL CARS",
                      @"AUDI",
                      @"BITTER",
                      @"BMW",
                      @"BÜSSING",
                      @"GUMPERT",
                      @"MAN"];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return self.carMakes.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return self.carMakes[index];
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList badgeValueForItemWithIndex:(NSInteger)index {
    /**
     * Updates the badge value text for the corresponding index. For example: If you had 100 (all cars), 50 Audis, and
     * 50 Bitters, you could set a badge to three of the tabs by doing the following:
    /**
    switch (index) {
    	case 0:
	    return @"100";
	case 1:
            return @"50";
	case 2:
	    return @"50";
    }
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
}

```

### Customizing the appearance

The HTHorizontalSelectionList has a number of configurable properties.

To adjust the font and color of the buttons use the following methods:
```objc
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state;
```

Default (unselected) state is configured with UIControlStateNormal.
The selection list can be configured for three states: UIControlStateNormal, UIControlStateHightlighted and UIControlStateSelected.
If no explicit colors or fonts are specified for the selected or highlighted states, the control will fallback on the normal style.

The appearance of the selection indicator can be configured with the following properties:
```objc
@property (nonatomic, strong) UIColor *selectionIndicatorColor;

@property (nonatomic) HTHorizontalSelectionIndicatorStyle selectionIndicatorStyle;
```

There are three selection styles:
```objc
typedef NS_ENUM(NSInteger, HTHorizontalSelectionIndicatorStyle) {
    HTHorizontalSelectionIndicatorStyleBottomBar,           // Default
    HTHorizontalSelectionIndicatorStyleButtonBorder,
    HTHorizontalSelectionIndicatorStyleNone
};
```

To configure the height of the bottom bar use:
```objc
@property (nonatomic) CGFloat selectionIndicatorHeight;
```

Default height is 3 points.  To adjust how wide this bottom bar extends beyond the label use:
```objc
@property (nonatomic) CGFloat selectionIndicatorHorizontalPadding;

```
The default horizontal padding for the bottom bar is 7.5 points.  These properties only take effect if selection style is HTHorizontalSelectionIndicatorStyleBottomBar.


The selection indicator bounce effect can be adjusted with this property:
```objc
@property (nonatomic) HTHorizontalSelectionIndicatorAnimationMode selectionIdicatorAnimationMode;
```

You can adjust the content insets of each button with:
```objc
@property (nonatomic) UIEdgeInsets buttonInsets;
```

Setting `bottomTrimColor` changes the appearance of the thin bottom border:
```objc
@property (nonatomic, strong) UIColor *bottomTrimColor;
@property (nonatomic) BOOL bottomTrimHidden;
```
