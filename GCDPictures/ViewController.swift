//
//  ViewController.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

protocol IImagesView {
    func setPictures(images: [UIImage?])
}

class ViewController: UIViewController, IImagesView {

    private lazy var collectionView: UICollectionView = {
        let layout = createGridLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Int, UIImage>?
    
    private var images: [UIImage?] = []
    
    private let presenter: IImageLoaderPresenter

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupDataSource()
        presenter.viewDidLoad()
    }
    
    // MARK: - Init

    init(presenter: IImageLoaderPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPictures(images: [UIImage?]) {
        self.images = images
        applyInitialSnapshot()
    }

    // MARK: - Layout

    private func createGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/2)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Setup

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupDataSource() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")

        dataSource = UICollectionViewDiffableDataSource<Int, UIImage>(collectionView: collectionView) { collectionView, indexPath, image in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configure(with: image)
            cell.backgroundColor = .secondarySystemBackground
            cell.layer.cornerRadius = 12
            return cell
        }
    }

    private func applyInitialSnapshot() {
        let validImages = images.compactMap { $0 }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIImage>()
        snapshot.appendSections([0])
        snapshot.appendItems(validImages)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}


final class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor)
        ])
    }

    func configure(with image: UIImage) {
        imageView.image = image
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
    }
}


