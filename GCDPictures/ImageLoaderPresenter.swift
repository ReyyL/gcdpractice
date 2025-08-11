//
//  ImageLoaderPresenter.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import Foundation

protocol IImageLoaderPresenter {
    func viewDidLoad()
}

final class ImageLoaderPresenter: IImageLoaderPresenter {
    
    private let service: ILoaderImageService
    
    weak var vc: ViewController?
    
    init(service: ILoaderImageService) {
        self.service = service
    }
    
    func viewDidLoad() {
        loadPictures()
    }
    
    func loadPictures() {
        let urls = (1...20).compactMap {
            URL(string: "https://picsum.photos/id/\($0)/300/300")
        }
        service.loadImages(from: urls) { [weak self] images in
            self?.vc.map { $0.setPictures(images: images) }
        }
    }
}
