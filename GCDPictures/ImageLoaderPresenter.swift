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
    func loadImage(for index: Int, completion: @escaping (UIImage?) -> Void)
    func cancelLoadingImages(at indexes: [Int])
    func image(at index: Int) -> UIImage?
}

final class ImageLoaderPresenter: IImageLoaderPresenter {
    
    private let service: ILoaderImageService
    private var urls: [URL] = []
    private var loadedImages: [Int: UIImage] = [:]
    weak var vc: IImagesView?
    
    init(service: ILoaderImageService) {
        self.service = service
    }
    
    func viewDidLoad() {
        urls = (1...20).compactMap { _ in
            URL(string: "https://placebear.com/g/150/200")
        }
        vc?.setPictures(count: urls.count)
    }
    
    func loadImage(for index: Int, completion: @escaping (UIImage?) -> Void) {
        guard index < urls.count else {
            completion(nil)
            return
        }
        
        if let image = loadedImages[index] {
            completion(image)
            return
        }
        
        service.loadImage(from: urls[index]) { [weak self] image in
            guard let self, let image else {
                completion(nil)
                return
            }
            
            loadedImages[index] = image
            completion(image)
        }
    }
    
    func loadImages(at indexes: [Int]) {
        for index in indexes {
            guard index < urls.count else { continue }
            
            if loadedImages[index] == nil {
                service.loadImage(from: urls[index]) { [weak self] image in
                    guard let self, let image else { return }
                    
                    loadedImages[index] = image
                }
            }
        }
    }
    
    func cancelLoadingImages(at indexes: [Int]) {
        for index in indexes {
            guard index < urls.count else { continue }
            service.cancelLoad(for: urls[index])
        }
    }
    
    func image(at index: Int) -> UIImage? {
        return loadedImages[index]
    }
}
