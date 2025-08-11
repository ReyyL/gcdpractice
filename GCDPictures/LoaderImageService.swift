//
//  LoaderImageService.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

protocol ILoaderImageService: AnyObject {
    func loadImages(from urls: [URL], completion: @escaping ([UIImage?]) -> Void)
}

final class LoaderImageService: ILoaderImageService {

    func loadImages(from urls: [URL], completion: @escaping ([UIImage?]) -> Void) {
        var images = Array<UIImage?>(repeating: nil, count: urls.count)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "imageQueue")
        
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 6
        let session = URLSession(configuration: configuration)

        for (index, url) in urls.enumerated() {
            group.enter()
            session.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                
                guard let data, let image = UIImage(data: data) else { return }
                
                let modified = self.modifyImage(image)
                
                queue.async {
                    images[index] = modified
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(images)
        }
        
    }

    private func modifyImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }

        let finalImage = UIImage(cgImage: cgImage).resize(to: CGSize(width: 200, height: 200))
        return finalImage
    }
}

private extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

