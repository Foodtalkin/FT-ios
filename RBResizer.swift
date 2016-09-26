//
//  RBResizer.swift
//  Locker
//
//  Created by Hampton Catlin on 6/20/14.
//  Copyright (c) 2014 rarebit. All rights reserved.
//

import UIKit

func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
    return RBResizeImage(RBSquareImage(image), targetSize: size)
}

func RBSquareImage(image: UIImage) -> UIImage {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var edge: CGFloat = 0.0
    
    if (originalWidth > originalHeight) {
        // landscape
        edge = originalHeight
        x = (originalWidth - edge) / 2.0
        y = 0.0
        
    } else if (originalHeight > originalWidth) {
        // portrait
        edge = originalWidth
        x = 0.0
        y = (originalHeight - originalWidth) / 2.0
    } else {
        // square
        edge = originalWidth
    }
    
    let cropSquare = CGRectMake(x, y, edge, edge)
    let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
    
    return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
}

func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}