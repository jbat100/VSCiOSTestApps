//
//  ProductTypeSelectionViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

/*
 *  Note: using PSUICollectionView (and associates) instead of UICollectionView allows the code to 
 *  run on iOS 5, using the PSTCollectionView library in the pods. The API is according to the 
 *  project Github page, 100% compatible.
 */

@interface SICategorySelectionViewController : UIViewController <PSUICollectionViewDelegate, PSUICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet PSUICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet UIView* adView;

@end
