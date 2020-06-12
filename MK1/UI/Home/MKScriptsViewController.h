// MKScriptsViewController.h

#import <UIKit/UIKit.h>

@class MKScript;

@interface MKScriptsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray<MKScript *> *scripts;
@property (nonatomic, strong) NSMutableArray<MKScript *> *filteredScripts;
@property (nonatomic, assign) BOOL searching;

- (void)refreshScripts;

@end

