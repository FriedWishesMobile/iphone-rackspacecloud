//
//  AddObjectViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/19/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "AddObjectViewController.h"
#import "RackspaceAppDelegate.h"
#import "CloudFilesObject.h"
#import "CFAccount.h"
#import "Container.h"
#import "ListObjectsViewController.h"

@implementation AddObjectViewController

@synthesize account, container, listObjectsViewController;

- (void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"Choose a file type", @"Choose a file type table section header");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 1;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		rows++;
	}
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		rows++;
	}	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Text File", @"Text File button");
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Image from Photo Library", @"Image from Photo Library button");
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"Image from Camera", @"Image from Camera button");
			break;
		default:
			break;
	}
	
	return cell;		
}


// TODO: make sure you cover ipod touch with the camera stuff

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		
	} else if (indexPath.row == 1) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			UIImagePickerController *camera = [[UIImagePickerController alloc] init];		
			camera.delegate = self;
			camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:camera animated:YES];
			[camera release];
		}
	} else if (indexPath.row == 2) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *camera = [[UIImagePickerController alloc] init];		
			camera.delegate = self;
			camera.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:camera animated:YES];
			[camera release];
		}
	}
	
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Image Correction

// Return the image rotated to the correct orientation
- (UIImage *)scaleAndRotateImage:(UIImage *)image {
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	CGFloat maxWidth = width;
	CGFloat maxHeight = height;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > maxWidth || height > maxHeight) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = maxWidth;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = maxHeight;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			break;
			//[NSException raise :NSInternalInconsistencyExceptionformat:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

#pragma mark Camera Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {	
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	[picker dismissModalViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	image = [self scaleAndRotateImage:image];
	
	NSData *imageData = UIImagePNGRepresentation(image);
	CloudFilesObject *co = [[CloudFilesObject alloc] init];
	co.name = [NSString stringWithFormat:@"cloudapp_upload_%@.png", [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	co.contentType = @"image/png";
	co.data = imageData;
	[co createFileWithAccountName:app.cloudFilesAccountName andContainerName:self.container.name];
	
	// refresh files list in container view
	[self.listObjectsViewController refreshFileList];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[account release];
	[container release];
	[listObjectsViewController release];
    [super dealloc];
}


@end
