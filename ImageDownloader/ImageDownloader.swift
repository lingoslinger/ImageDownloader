//
//  ImageDownloader.swift
//  RadioStations
//
//  Created by Allan Evans on 11/18/18.
//  Copyright © 2018 lingo-slingers.org. All rights reserved.
//

import Foundation
import UIKit

public typealias ImageDownloadCompletion = (_ image: UIImage?, _ url: URL, _ error: Error?) -> Void

public class ImageDownloadManager {
    public static let shared = ImageDownloadManager()
    let imageCache = NSCache<NSString, UIImage>()
    lazy var imageDownloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.lingo-slingers.imageDownloadQueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
   
    private init () {}
    
    public func downloadImage(imageURL: URL, completionHandler: @escaping ImageDownloadCompletion) {
        if let cachedImage = imageCache.object(forKey: imageURL.absoluteString as NSString) {
          completionHandler(cachedImage, imageURL, nil)
        } else {
            if let operation = operationInQueueWithURL(imageURL) {
                operation.queuePriority = .veryHigh
                operation.isVisible = true
            } else {
                let operation = ImageOperation(url: imageURL)
                operation.queuePriority = .high
                operation.imageDownloadCompletion = { (image, url, error) in
                    if let newImage = image {
                        self.imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                        if operation.isVisible { completionHandler(newImage, url, error) }
                    }
                }
                imageDownloadQueue.addOperation(operation)
            }
        }
    }
    
    public func imageNotVisible(imageURL: URL) {
        guard let operation = operationInQueueWithURL(imageURL) else { return }
        operation.queuePriority = .veryLow
        operation.isVisible = false
    }
    
    public func cancelDownload(imageURL: URL) {
        guard let operation = operationInQueueWithURL(imageURL) else { return }
        operation.cancel()
    }
    
    func operationInQueueWithURL(_ imageURL: URL) -> ImageOperation? {
        if let operations = (imageDownloadQueue.operations as? [ImageOperation])?.filter({ $0.imageURL.absoluteString == imageURL.absoluteString && $0.isFinished == false && $0.isExecuting == true })  {
            return operations.first
        } else {
            return nil
        }
    }
}
