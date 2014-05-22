MMImagePickerViewController
===========================

It's not big, and it's not clever, but it does make throwing a simple square image picker (camera or photo album) into your apps really quick and easy.

To use it:

#####CocoaPods

pod 'MMImagePickerViewController', :podspec => 'http://michael-r-may.github.io/MMImagePickerViewController/MMImagePickerViewController.podspec'

#####Git
You can simply clone it with
git clone https://github.com/michael-r-may/MMImagePickerViewController.git

I would recommend using a git submodule inside your project in this case, though, as it's easier to maintain.

git submodule add https://github.com/michael-r-may/MMImagePickerViewController.git

Then simply drag the project file in to your app and link to the libMMImagePickerViewController.a file.

The code itself is just a few lines long:

```
    [[self imagePickerController] setDismissBlock:^(NSObject* image) {
        if([image isKindOfClass:[UIImage class]] == NO) return;

        UITableViewCell* currentCell = [self currentCell];
        [currentCell setImage:(UIImage*)image];
    }];
    
    [[self imagePickerController] startFlow];
```

