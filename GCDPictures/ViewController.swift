//
//  ViewController.swift
//  GCDPictures
//
//  Created by Andrey Lazarev on 06.08.2025.
//

import UIKit

protocol IImagesView: AnyObject {
    func setPictures(count: Int)
    func updateImage(_ image: UIImage?, at index: Int)
}

class ViewController: UIViewController, IImagesView {

    private lazy var collectionView: UICollectionView = {
        let layout = createGridLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.prefetchDataSource = self
        return collection
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>?
    private var images: [UIImage?] = []
    
    private let presenter: IImageLoaderPresenter

    // MARK: - Init

    init(presenter: IImageLoaderPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let visibleIndexes = collectionView.indexPathsForVisibleItems.map { $0.item }
        presenter.loadImages(at: visibleIndexes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupDataSource()
        presenter.viewDidLoad()
    }
    
    // MARK: - IImagesView
    
    func setPictures(count: Int) {
        images = Array(repeating: nil, count: count)
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(0..<count))
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func updateImage(_ image: UIImage?, at index: Int) {
        guard index < images.count else { return }
        
        images[index] = image
        
        var snapshot = dataSource?.snapshot()
        snapshot?.reloadItems([index])
        if let snapshot {
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }

    // MARK: - Private

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

        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { collectionView, indexPath, index in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            if let img = self.images[index] {
                cell.configure(with: img)
            } else {
                cell.configurePlaceholder()
            }
            return cell
        }
    }
    
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
}

// MARK: - Prefetching

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        presenter.loadImages(at: indexPaths.map { $0.item })
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        presenter.cancelLoadingImages(at: indexPaths.map { $0.item })
    }
}
