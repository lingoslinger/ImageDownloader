//
//  ImageOperation.swift
//  RadioStations
//
//  Created by Allan Evans on 11/18/18.
//  Copyright © 2018 lingo-slingers.org. All rights reserved.
//

import UIKit

public class ImageOperation: Operation {
    var imageDownloadCompletion: ImageDownloadCompletion?
    var imageURL: URL!
    public var isVisible: Bool = true
    
    override public var isAsynchronous: Bool {
        get { return true }
    }
    
    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    
    override public var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    override public var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    required init (url: URL) {
        self.imageURL = url
    }
    
    override public func main() {
        guard isCancelled == false else {
            finish(true)
            executing(false)
            return
        }
    }
    
    override public func start() {
        finish(false)
        executing(true)
        downloadImageFromURL()
    }
    
    // MARK - image downloading
    public func downloadImageFromURL () {
        let newSession = URLSession.shared
        let downloadTask = newSession.downloadTask(with: self.imageURL) { (location, response, error) in
            if let locationURL = location, let data = try? Data(contentsOf: locationURL) {
                let image = UIImage(data: data)
                self.imageDownloadCompletion?(image, self.imageURL, error)
            }
            self.finish(true)
            self.executing(false)
        }
        downloadTask.resume()
    }
}
