//
//  VideoListViewController.swift
//  Famer
//
//  Created Aleksandr Zhovtyi on 08.11.2019.
//  Copyright © 2019 Aleksandr Zhovtyi. All rights reserved.
//

import UIKit
import CoreData

extension VideoListViewController: VideoListPresenterOutput, TabItemController {}

final class VideoListViewController: CollectionViewController {
    // MARK: Public variables
    weak var tabContaierController: TabContaierController?
    var scrollView: UIScrollView? { return self.collectionView }
    var initialContentOffsetY: CGFloat?
    
    var presenter: VideoListPresenterInput?
    
    // MARK: Outlets
    @IBOutlet private weak var backButton: UIButton!
    
    

    
    // MARK: Private variables
    private(set) var viewModel: VideoList.ViewModel!
    
    class func instantiate(display mode: VideoList.DisplayMode, viewContext moc: NSManagedObjectContext) -> VideoListViewController {
        let vc = VideoListViewController.controllerFromStoryboard(.vidoes)
        vc.viewModel = VideoList.ViewModel(display: mode, viewContext: moc, delegate: vc)
        return vc
    }
    
    deinit {
        printDeinit()
    }
	
}

// MARK: - View life cycle
extension VideoListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        outlets.forEach(setup(outlet:))
        outlets.forEach(configure(outlet:))
        collectionView.contentInsetAdjustmentBehavior = .never
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let offsetY = initialContentOffsetY {
            scrollView?.contentOffset.y = offsetY
            initialContentOffsetY = nil
        }

        if let containerController = tabContaierController {
            scrollView?.contentInset = containerController.contentInset
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}


// MARK: - Public methods
extension VideoListViewController { 
}

// MARK: - Private methods
private extension VideoListViewController {
    func setup(outlet: UIView?) {
        switch outlet {
        case backButton:
            backButton.onTouchUpInSide = presenter?.goBack
        default: break
        }
    }
    
    func configure(outlet: UIView?) {
        switch outlet {
        default: break
        }
    }
}

// MARK: - Collection view
extension VideoListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
     // MARK: Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(VideoListCollectionViewCell.self, for: indexPath)
    }
    
    // MARK: Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat( floor(collectionView.bounds.width / 2.0)) - 3
        let coef: CGFloat = 260.0/206.0  // Designer's magic number
        return CGSize(width: width, height: width * coef)
    }

    // MARK: Displaying
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        configure(cell, cellForRowAt: indexPath)
        presenter?.loadMore(for: indexPath)
        
    }
    
    // MARK: Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.selectItem(at: indexPath)
    }
}

// MARK: - Content listener
extension VideoListViewController {
    override func contentDidChanged(numberOfObjects count: Int) {
        self.setEmptyViewHidden(count > 0, animated: true)
        
    }
    
    override func configure(_ view: UIView, cellForRowAt indexPath: IndexPath) {
        let model = viewModel.object(at: indexPath)
        model.configure(view)        
    }
    
}


// MARK: - Scroll view
extension VideoListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tabContaierController?.scrollViewDidScroll(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        tabContaierController?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tabContaierController?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

// MARK: - Empty view customization
extension VideoListViewController: EmptyViewCustomization {
    
    
    func image(for emptyView: EmptyView) -> UIImage? {
        return nil
    }
    
    func title(for emptyView: EmptyView) -> String? {
         return NSLocalizedString("No videos yet", comment: "")
    }
}
