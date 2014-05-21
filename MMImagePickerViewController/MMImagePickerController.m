//
//  Created by Michael May on 2014/03/30.
//  Copyright (c) 2014 Michael May. All rights reserved.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Michael May
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import "MMImagePickerController.h"

@interface MMImagePickerController () <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak, readonly) UIViewController* viewController;
@property (nonatomic, assign) NSInteger photoLibraryActionSheetIndex;
@property (nonatomic, assign) NSInteger cameraActionSheetIndex;
@end

@implementation MMImagePickerController

@synthesize dismissBlock;

#pragma mark -

+(NSArray*)mediaTypesPermitted
{
    return @[(__bridge NSString*)kUTTypeImage];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    UIImagePickerController *imagePickerViewController = [[UIImagePickerController alloc] init];
    [imagePickerViewController setDelegate:self];
    
    if(buttonIndex == [self photoLibraryActionSheetIndex]) {
        [imagePickerViewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if(buttonIndex == [self cameraActionSheetIndex]) {
        [imagePickerViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    NSArray *mediaTypesPermitted = [[self class] mediaTypesPermitted];
    [imagePickerViewController setMediaTypes:mediaTypesPermitted];
    [imagePickerViewController setAllowsEditing:YES];
        
    [[self viewController] presentViewController:imagePickerViewController animated:YES completion:nil];
}

-(void)presentImagePickersOptions
{
    UIActionSheet *imagePickerOptionsActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                 destructiveButtonTitle:nil
                                                                      otherButtonTitles:nil];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        _photoLibraryActionSheetIndex = [imagePickerOptionsActionSheet addButtonWithTitle:NSLocalizedString(@"PhotoLibrary", @"")];
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _cameraActionSheetIndex = [imagePickerOptionsActionSheet addButtonWithTitle:NSLocalizedString(@"CameraSource", @"")];
    }
    
    NSInteger cancelButtonIndex = [imagePickerOptionsActionSheet addButtonWithTitle:NSLocalizedString(@"CancelButton", @"")];
    [imagePickerOptionsActionSheet setCancelButtonIndex:cancelButtonIndex];
    
    UIViewController *viewController = [self viewController];
    UIView *view = [viewController view];
    CGRect frame = [view frame];
    [imagePickerOptionsActionSheet showFromRect:frame
                                         inView:view
                                       animated:YES];
}

#pragma mark - image picking

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    __weak typeof(self) weakSelf = self;
    
    [[self viewController] dismissViewControllerAnimated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        DismissBlock dismissBlockAction = [strongSelf dismissBlock];
        
        if(dismissBlockAction) dismissBlockAction(image);
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    __weak typeof(self) weakSelf = self;
    
    [[self viewController] dismissViewControllerAnimated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        DismissBlock dismissBlockAction = [strongSelf dismissBlock];
        
        if(dismissBlockAction) dismissBlockAction(nil);
    }];
}

#pragma mark - 

-(void)startFlow
{
    _photoLibraryActionSheetIndex = -1;
    _cameraActionSheetIndex = -1;

    [self presentImagePickersOptions];
}

#pragma mark -

-(instancetype)initWithViewController:(UIViewController*)viewController
{
    if (viewController == nil) return nil;
    
    self = [super init];
    
    if(self) {
        _viewController = viewController;
    }
    
    return self;
}


#pragma mark -

+(instancetype)imagePickerFlowFromViewController:(UIViewController*)viewController
{
    return [[self alloc] initWithViewController:viewController];
}

@end
