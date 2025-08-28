//
//  LoaderAssembly.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

public final class LoaderAssembly {
    func assemble() -> UIViewController {
        let service = LoaderImageService()
        let presenter = ImageLoaderPresenter(service: service)
        let controller = ViewController(presenter: presenter)
        
        presenter.vc = controller
        
        return UINavigationController(rootViewController: controller)
    }
}
