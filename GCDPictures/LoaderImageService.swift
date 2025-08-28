//
//  LoaderImageService.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

protocol ILoaderImageService: AnyObject {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
    func cancelLoad(for url: URL)
}

final class LoaderImageService: ILoaderImageService {
    
    private let session: URLSession
    private var tasks: [URL: URLSessionDataTask] = [:]
    private let tasksQueue = DispatchQueue(label: "tasksQueue", attributes: .concurrent)
    
    private let cache = NSCache<NSURL, UIImage>()
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 6
        self.session = URLSession(configuration: configuration)
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }
        
        tasksQueue.sync {
            if tasks[url] != nil { return }
        }
        
        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            
            tasksQueue.async(flags: .barrier) {
                self.tasks.removeValue(forKey: url)
            }
            
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let resized = self.resizeImage(image, to: CGSize(width: 200, height: 200))
                let mono = self.convertToMono(resized)
                
                if let mono {
                    self.cache.setObject(mono, forKey: url as NSURL)
                }
                
                DispatchQueue.main.async {
                    completion(mono)
                }
            }
        }
        
        tasksQueue.async(flags: .barrier) {
            self.tasks[url] = task
        }
        task.resume()
    }
    
    func cancelLoad(for url: URL) {
        tasksQueue.async(flags: .barrier) {
            self.tasks[url]?.cancel()
            self.tasks.removeValue(forKey: url)
        }
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func convertToMono(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
