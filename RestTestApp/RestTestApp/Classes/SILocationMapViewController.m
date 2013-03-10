//
//  LocationMapViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SILocationMapViewController.h"
#import "SIDataManager.h"
#import "SIShop.h"
#import "SIShopAnnotation.h"

#import <MapKit/MapKit.h>

NSString* const SILocationMapSegueIdentifier = @"Map";

MKCoordinateRegion CoordinateRegionForLocations(NSArray* locations) {
    
    /*
     *  This is inspired from http://stackoverflow.com/questions/1336370/positioning-mkmapview-to-show-multiple-annotations-at-once
     *  (answer by me2)
     */
    
    MKMapRect r = MKMapRectNull;
    for (CLLocation* location in locations)
    {
        assert([location isKindOfClass:[CLLocation class]]);
        if ([location isKindOfClass:[CLLocation class]])
        {
            CLLocationCoordinate2D coordinate = [location coordinate];
            MKMapPoint p = MKMapPointForCoordinate(coordinate);
            r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
        }
    }
    return MKCoordinateRegionForMapRect(r);
}

@interface SILocationMapViewController ()

@property (nonatomic, strong) NSArray* shops; // local cache, obtained via the SIDataManager

@property (nonatomic, strong) NSArray* annotations;

//@property (nonatomic, assign) CLLocationDistance autoAdjustMinimumRegionSize; // used as a lower limit in case of 1 shop
@property (nonatomic, assign) CLLocationDegrees autoAdjustMinimumRegionDegrees; // used as a lower limit in case of 1 shop
@property (nonatomic, assign) MKCoordinateRegion defaultRegion; // used as default region in case of 0 shops

-(void) customInit;

-(void) reloadAnnotations;

-(CLLocationCoordinate2D) shopsCentralCoordinate;

@end

@implementation SILocationMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self customInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    self.autoAdjustMinimumRegionDegrees = 0.5;
    
    CLLocationCoordinate2D orleanCoordinate = CLLocationCoordinate2DMake(47.9025, 1.909);
    MKCoordinateSpan span = MKCoordinateSpanMake(self.autoAdjustMinimumRegionDegrees, self.autoAdjustMinimumRegionDegrees);
    
    self.defaultRegion = MKCoordinateRegionMake(orleanCoordinate, span);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload
{
    self.mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.shops = [[SIDataManager sharedManager] fetchAllShops];
    
    assert(self.mapView);
    
    [self autoAdjustMap:self];
    
    [self reloadAnnotations];
}

-(IBAction)autoAdjustMap:(id)sender
{
    
    if (![self.shops count])
    {
        [self.mapView setRegion:self.defaultRegion animated:YES];
    }
    else
    {
        NSMutableArray* locations = [NSMutableArray arrayWithCapacity:[self.shops count]];
        for (SIShop* shop in self.shops)
        {
            if ([shop isKindOfClass:[SIShop class]])
            {
                if ([shop latitude] && [shop longitude])
                {
                    CLLocation* location = [[CLLocation alloc] initWithLatitude:[[shop latitude] doubleValue]
                                                                      longitude:[[shop longitude] doubleValue]];
                    [locations addObject:location];
                }
                else assert(NO);
            }
            else assert(NO);
        }
        
        MKCoordinateRegion region = self.defaultRegion;
        
        if ([locations count] > 0)
        {
            region = CoordinateRegionForLocations(locations);
        }
        
        MKCoordinateSpan span = region.span;
        
        if (span.latitudeDelta < self.autoAdjustMinimumRegionDegrees) span.latitudeDelta = self.autoAdjustMinimumRegionDegrees;
        if (span.longitudeDelta < self.autoAdjustMinimumRegionDegrees) span.longitudeDelta = self.autoAdjustMinimumRegionDegrees;
        
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
    }
    
}

-(void) reloadAnnotations
{
    if (self.annotations)
    {
        [self.mapView removeAnnotations:self.annotations];
    }
    
    NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:[self.shops count]];

    for (SIShop* shop in self.shops)
    {
        if ([shop isKindOfClass:[SIShop class]])
        {
            if ([shop name] && [shop latitude] && [shop longitude])
            {
                SIShopAnnotation* annotation = [SIShopAnnotation alloc];
                annotation.shop = shop;
                [newAnnotations addObject:annotation];
            }
            else assert(NO);
        }
        else assert(NO);
    }
    
    self.annotations = [NSArray arrayWithArray:newAnnotations];
    
    [self.mapView addAnnotations:self.annotations];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[SIShopAnnotation class]])
    {
        static NSString* const SIShopViewIdentifier = @"SIShopViewIdentifier";
        
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:SIShopViewIdentifier];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SIShopViewIdentifier];
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            /* Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(myShowDetailsMethod:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
             */
        }
        else
        {
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DDLogVerbose(@"%@ didSelectAnnotationView %@", mapView, view);
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    DDLogVerbose(@"%@ didDeselectAnnotationView %@", mapView, view);
}

@end
