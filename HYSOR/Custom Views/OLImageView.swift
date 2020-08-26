//
//  TNImageView.swift
//  Vinder
//
//  Created by Dayson Dong on 2019-06-27.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
//import AlamofireImage

//let imageCache = AutoPurgingImageCache()
// OnlineImage
class OLImageView: UIImageView {

    var imageUrlString: String?

    override func layoutSubviews() {
        super.layoutSubviews()
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }

//    func downloadImage(at link: String) {
//
//        //try to get image from cache then set image
//        if let cachedImage = imageCache.image(withIdentifier: link) {
//            self.image = cachedImage
//            return
//        }
//
//        //if no image from cache, download image.
//        NetworkManager.shared.downloadPreviewImage(at: link) { (image) in
//            if let image = image {
//                DispatchQueue.main.async {
//                    // add  image to cache
//                    imageCache.add(image, withIdentifier: link)
//                    // set image
//                    self.image = image
//                }
//            }
//        }
//    }
}
