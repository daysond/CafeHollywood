//
//  LocalFileManager.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-11-18.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

class LocalFileManager {
    
    static let shared = LocalFileManager()
    
    private func imageFilePath(forName name: String) -> URL? {
        
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(name)
    }
    
     func store(image: UIImage, named name: String) {
        
        if let pngRepresentation = image.pngData() {
            
            if let filePath = imageFilePath(forName: name) {
                do  {
                    try pngRepresentation.write(to: filePath,
                                                options: .atomic)
                    print("did store image!")
                } catch let err {
                    print("Saving file resulted in error: ", err)
                }
            }
            
        }
    }
    
    
     func retrieveImage(named name: String) -> UIImage? {
        
        if let filePath = self.imageFilePath(forName: name),
           let fileData = FileManager.default.contents(atPath: filePath.path),
           let image = UIImage(data: fileData) {
            return image
        }
        
        
        return nil
    }
    
    func fetchImage(imageURL name: String, completion: @escaping (UIImage?) -> Void) {
        
        if name == "" { completion(nil); return }
        
        if name.hasPrefix("ref") {
            
            let name = "\(name).jpg"
            
            if let image = LocalFileManager.shared.retrieveImage(named: name) {
                print("did get image from local storage")
                completion(image)
            } else {
                NetworkManager.shared.downloadImge(named: name ) { (image) in
                    
                    if let image = image {
    
                        LocalFileManager.shared.store(image: image, named: name)
                        completion(image)

                    }
                }
            }
        } else {
            completion(UIImage(named: name))
        }
        
        
        
    }
    
    /**
     let name = "FMVY.jpg"
     
     if let image = LocalFileManager.shared.retrieveImage(named: name) {
         self.backgroundImageView.image = image
         print("did get image from local storage")
     } else {
         NetworkManager.shared.downloadImge(named: name ) { (image) in
             
             if let image = image {
                 
                 DispatchQueue.main.async {
                     self.backgroundImageView.image = image
                     LocalFileManager.shared.store(image: image, named: name)
                     
                 }
             }
         }
     }
     
     */
    
    
}

