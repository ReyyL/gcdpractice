//
//  ImageLoaderPresenter.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

protocol IImageLoaderPresenter {
    func viewDidLoad()
    func loadImages(at indexes: [Int])
    func cancelLoadingImages(at indexes: [Int])
}

final class ImageLoaderPresenter: IImageLoaderPresenter {
    
    private let service: ILoaderImageService
    private var urls: [URL] = []
    weak var vc: IImagesView?
    
    init(service: ILoaderImageService) {
        self.service = service
    }
    
    func viewDidLoad() {
        urls = (1...20).compactMap {
            URL(string: "https://picsum.photos/id/\($0)/300/300")
        }
        vc?.setPictures(count: urls.count)
    }
    
    func loadImages(at indexes: [Int]) {
        for index in indexes {
            guard index < urls.count else { continue }
            service.loadImage(from: urls[index]) { [weak self] image in
                self?.vc?.updateImage(image, at: index)
            }
        }
    }
    
    func cancelLoadingImages(at indexes: [Int]) {
        for index in indexes {
            guard index < urls.count else { continue }
            
            service.cancelLoad(for: urls[index])
        }
    }
}
