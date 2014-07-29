//
//  MMRequest.h
//  MMSDK
//
//  Copyright (c) 2013 Millennial Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    MMEducationUnknown = 0,
    MMEducationNone,
    MMEducationHighSchool,
    MMEducationSomeCollege,
    MMEducationBachelors,
    MMEducationMasters,
    MMEducationDoctorate
} MMEducation;

typedef enum {
    MMGenderUnknown = 0,
    MMGenderMale,
    MMGenderFemale
} MMGender;

typedef enum {
    MMEthnicityUnknown = 0,
    MMEthnicityMiddleEastern,
    MMEthnicityAsian,
    MMEthnicityBlack,
    MMEthnicityHispanic,
    MMEthnicityIndian,
    MMEthnicityNativeAmerican,
    MMEthnicityPacificIslander,
    MMEthnicityWhite,
    MMEthnicityOther
} MMEthnicity;

typedef enum {
    MMMaritalUnknown = 0,
    MMMaritalSingle,
    MMMaritalMarried,
    MMMaritalDivorced,
    MMMaritalEngaged
} MMMaritalStatus;

typedef enum {
    MMSexualOrientationUnknown = 0,
    MMSexualOrientationGay,
    MMSexualOrientationStraight,
    MMSexualOrientationBisexual,
    MMSexualOrientationTransgender
} MMSexualOrientation;

@interface MMRequest : NSObject

// Creates an MMRequest object
+ (MMRequest *)request;

#pragma mark - Location Information

// Creates an MMRequest object with location
+ (MMRequest *)requestWithLocation:(CLLocation *)location;

// Set location for the ad request
@property (nonatomic, retain) CLLocation *location;

#pragma mark - Demographic Information

// Set demographic information for the ad request
@property (nonatomic, assign) MMEducation education;
@property (nonatomic, assign) MMGender gender;
@property (nonatomic, assign) MMEthnicity ethnicity;
@property (nonatomic, assign) MMMaritalStatus maritalStatus;
@property (nonatomic, assign) MMSexualOrientation orientation;
@property (nonatomic, retain) NSNumber *age;
@property (nonatomic, copy) NSString *zipCode;

#pragma mark - Contextual Information

// Set an array of keywords (must be NSString values)
@property (nonatomic, retain) NSMutableArray *keywords;

// Add keywords one at a time to the array
- (void)addKeyword:(NSString *)keyword;

#pragma mark - Additional Information

// Set additional parameters for the ad request. Value must be NSNumber or NSString.
- (void)setValue:(id)value forKey:(NSString *)key;

#pragma mark - Request parameters (read-only)
@property (nonatomic, retain, readonly) NSMutableDictionary *dataParameters;

@end
