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
#import "TextFieldCell.h"

#define kChoosingFileType 0
#define kNamingImageFile  1
#define kNamingTextFile   2

@implementation AddObjectViewController

@synthesize account, container, listObjectsViewController, tableView, footerView, uploadButton, uploadSpinner;

NSUInteger state = kChoosingFileType;
BOOL imageIsPng = YES;
NSTimeInterval placeholderTimeInterval;
UIImage *selectedImage = nil;

#pragma mark -
#pragma mark View Methods

- (void)viewDidLoad {
	state = kChoosingFileType;
	
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, footerView.frame.size.height);
	footerView.backgroundColor = [UIColor clearColor];
	footerView.frame = newFrame;
	self.tableView.tableFooterView = self.footerView;	// note this will override UITableView's 'sectionFooterHeight' property
	
	[super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/*
- (void)viewWillAppear:(BOOL)animated {
	// overriding so that we can reload the table based on the view controller state
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}
*/

#pragma mark -
#pragma mark Button Handlers

- (void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) uploadButtonPressed:(id)sender {
	
	[self.uploadSpinner startAnimating];
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	selectedImage = [self scaleAndRotateImage:selectedImage];
	
	NSData *imageData = nil;
	
	if (imageIsPng) {
		imageData = UIImagePNGRepresentation(selectedImage);
	} else {
		imageData = UIImageJPEGRepresentation(selectedImage, 0.7); // TODO: should we provide a slider to choose quality?
	}
	
	CloudFilesObject *co = [[CloudFilesObject alloc] init];
	
	// TODO: get file name from text field!
	co.name = [NSString stringWithFormat:@"cloudapp_upload_%@.png", [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	co.contentType = @"image/png";
	co.data = imageData;
	[co createFileWithAccountName:app.cloudFilesAccountName andContainerName:self.container.name];
	
	// refresh files list in container view
	[self.listObjectsViewController refreshFileList];
	
	[self.uploadSpinner stopAnimating];
}

#pragma mark -
#pragma mark Text Field Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// hide the keyboard when Done is pressed
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (state == kChoosingFileType) {
		return NSLocalizedString(@"Choose a file type", @"Choose a file type table section header");
	} else {
		// TODO: localize these strings
		if (section == 0) {
			return @"Name and Upload File";
		} else {
			return @"File Type";
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (state == kChoosingFileType) {
		return 1;
	} else if (state == kNamingImageFile) {
		return 2; // file name and type
	} else if (state == kNamingTextFile) {
		return 1;
	} else {
		return 0;
	}	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (state == kNamingTextFile) {
		return 1;
	} else if (state == kNamingImageFile) {
		if (section == 0) {
			return 1;
		} else {
			return 2;
		}
	} else {	
		NSInteger rows = 1;
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			rows++;
		}
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			rows++;
		}
		return rows;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView fileTypeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (UITableViewCell *)tableView:(UITableView *)aTableView imageFileCellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: allow choice between jpeg and png in second table section
	
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"ImageFileCell";
		TextFieldCell *cell = (TextFieldCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			// TODO: localize string
			cell.textLabel.text = @"File Name";
			cell.textField.keyboardType = UIKeyboardTypeDefault;
			cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			cell.textField.returnKeyType = UIReturnKeyDone;
			cell.textField.delegate = self;
			placeholderTimeInterval = [[NSDate date] timeIntervalSince1970];
		}
		
		if (imageIsPng) {
			cell.textField.placeholder = [NSString stringWithFormat:@"upload_%.0f.png", placeholderTimeInterval];
		} else {
			cell.textField.placeholder = [NSString stringWithFormat:@"upload_%.0f.jpeg", placeholderTimeInterval];
		}
		return cell;
	} else { // if (indexPath.section == 1) {
		static NSString *CellIdentifier = @"ImageFileTypeCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		if (indexPath.row == 0) {
			cell.textLabel.text = @"jpeg";
			if (imageIsPng) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"png";
			if (imageIsPng) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		
		return cell;		
	}	
}

- (UITableViewCell *)tableView:(UITableView *)aTableView textFileCellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TextFileCell";
	TextFieldCell *cell = (TextFieldCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		// TODO: localize string
		cell.textLabel.text = @"File Name";
		cell.textField.placeholder = [NSString stringWithFormat:@"upload_%d.txt", [[NSDate date] timeIntervalSince1970]];		
		cell.textField.keyboardType = UIKeyboardTypeDefault;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textField.returnKeyType = UIReturnKeyDone;
		cell.textField.delegate = self;
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (state == kChoosingFileType) {
		return [self tableView:aTableView fileTypeCellForRowAtIndexPath:indexPath];
	} else if (state == kNamingImageFile) {
		return [self tableView:aTableView imageFileCellForRowAtIndexPath:indexPath];
	} else { // if (state == kNamingTextFile) {
		return [self tableView:aTableView textFileCellForRowAtIndexPath:indexPath];
	}
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			// TODO: handle text files
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
	} else {
		imageIsPng = indexPath.row == 1;
		[self.tableView reloadData];
	}
	
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
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

#pragma mark -
#pragma mark Camera Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {	
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	state = kNamingImageFile;
	[self.tableView reloadData];
	
	selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	[picker dismissModalViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[account release];
	[container release];
	[listObjectsViewController release];
	[tableView release];
	[footerView release];
	[uploadButton release];
	[uploadSpinner release];
    [super dealloc];
}


@end
