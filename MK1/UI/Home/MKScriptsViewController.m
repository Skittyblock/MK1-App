// MKScriptsViewController.m

#import "MKScriptsViewController.h"
#import "MKScript.h"
#import "MKAppDelegate.h"
#import "MKScriptCollectionViewCell.h"
#import "MKSettingsViewController.h"
#import "MKNewScriptViewController.h"
#import "MKScriptViewController.h"
#import "MKManager.h"

@implementation MKScriptsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Scripts";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    // If not in /Applications folder, display a fake wallpaper
    if (![[[NSBundle mainBundle] bundlePath] isEqualToString:@"/Applications/MK1.app"]) {
        if (@available(iOS 13.0, *)) {
            self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
        } else {
            self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
        UIImageView *wallpaper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wallpaper"]];
        wallpaper.frame = self.view.bounds;
        wallpaper.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:wallpaper];
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        effectView.frame = self.view.bounds;
        [self.view addSubview:effectView];
    }
    
    UIImage *gearImage;
    if (@available(iOS 13, *)) {
        gearImage = [UIImage systemImageNamed:@"gear"];
    } else {
        // gearImage = [UIImage imageNamed:@"gear"];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:gearImage style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewScript)];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.navigationItem.searchController = self.searchController;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[MKScriptCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    self.scripts = [[NSMutableArray alloc] init];
    [self refreshScripts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScripts) name:@"xyz.skitty.mk1.refreshscripts" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshScripts];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    [self refreshScripts];
}

- (void)openSettings {
    MKSettingsViewController *settingsViewController = [[MKSettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self.navigationController presentViewController:settingsNavController animated:YES completion:nil];
}

- (void)addNewScript {
    MKNewScriptViewController *newScriptViewController = [[MKNewScriptViewController alloc] init];
    UINavigationController *newScriptNavController = [[UINavigationController alloc] initWithRootViewController:newScriptViewController];
    [self.navigationController presentViewController:newScriptNavController animated:YES completion:nil];
}

- (void)refreshScripts {
    [self.scripts removeAllObjects];
    
    self.scripts = [[[MKManager sharedInstance] scripts] mutableCopy];
    
    [self.collectionView reloadData];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [((MKAppDelegate *)[[UIApplication sharedApplication] delegate]) traitCollectionDidChange:previousTraitCollection];
}

// Collection View Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.searching) return self.filteredScripts.count;
    return self.scripts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MKScriptCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    MKScript *script = self.scripts[indexPath.row];
    if (self.searching) {
        script = self.filteredScripts[indexPath.row];
    }
    
    cell.script = script;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightMultiplier = 97 / 163.5; // 0.593272
    // Properly detect orientation
    // This is probably a little too long
    BOOL portrait = YES;
    if (@available(iOS 13.0, *)) {
        UIWindow *key;
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            if (window.keyWindow) key = window;
        }
        portrait = key.windowScene.interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        portrait = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (portrait) { // 2 in a row
            CGFloat width = [UIScreen mainScreen].bounds.size.width/2 - 24;
            return CGSizeMake(width, width * heightMultiplier + 51);
        } else { // 3 in a row
            CGFloat width = [UIScreen mainScreen].bounds.size.width/3 - (64/3);
            return CGSizeMake(width, width * heightMultiplier + 51);
        }
    } else {
        if (portrait) { // 3 in a row
            CGFloat width = [UIScreen mainScreen].bounds.size.width/3 - (64/3);
            return CGSizeMake(width, width * heightMultiplier + 51);
        } else { // 4 in a row
            CGFloat width = [UIScreen mainScreen].bounds.size.width/4 - 20.5;
            return CGSizeMake(width, width * heightMultiplier + 51);
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16, 16, 16, 16);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MKScriptViewController *scriptViewController = [[MKScriptViewController alloc] initWithScript:self.scripts[indexPath.row]];
    [self.navigationController pushViewController:scriptViewController animated:YES];
}

// Search Controller Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    
    if (searchString.length == 0) {
        self.filteredScripts = self.scripts;
    } else {
        self.filteredScripts = [NSMutableArray array];
        for (MKScript *script in self.scripts) {
            if ([script.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [self.filteredScripts addObject:script];
            }
        }
    }
        
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searching = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searching = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
}

@end
