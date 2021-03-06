//
//  WebcamSectionViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit
import Kingfisher

class WebcamSectionViewController: AbstractRefreshViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var section: WebcamSection
    
    lazy var provider: WebcamSectionViewProvider = {
       return WebcamSectionViewProvider(collectionView: self.collectionView)
    }()
    
    init(section: WebcamSection) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(refresh))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFavoriteWebcamDidUpdate),
                                               name: Notification.Name.favoriteWebcamDidUpdate,
                                               object: nil)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        provider.itemSelectionHandler = { [weak self] webcam, indexPath in
            let webcamDetail = WebcamDetailViewController(webcam: webcam)
            self?.navigationController?.pushViewController(webcamDetail, animated: true)
        }
        
        update()
        AnalyticsManager.logEvent(showSection: section)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.favoriteWebcamDidUpdate,
                                                  object: nil)
    }
    
    // MARK: - Actions
    
    func onFavoriteWebcamDidUpdate(notification: Notification) {
        update()
    }
    
    // MARK: -
    
    override func style() {
        super.style()
    }
    
    override func refresh(force: Bool) {
        if isReachable() {
            ImageCache.default.clearDiskCache()
            ImageCache.default.clearMemoryCache()
        }
        
        collectionView.reloadData()
        lastUpdate = NSDate().timeIntervalSinceReferenceDate
    }
    
    override func translate() {
        super.translate()
        
        title = section.title
    }
    
    override func update() {
        super.update()
        
        let webcams = Array(section.sortedWebcams())
        
        provider.section = section
        provider.objects = webcams
        
        if let navigationController = navigationController {
            if let index = navigationController.viewControllers.index(of: self), webcams.isEmpty {
                navigationController.viewControllers.remove(at: index)
            } else if !navigationController.viewControllers.contains(self), !webcams.isEmpty {
                navigationController.viewControllers.insert(self, at: 1)
            }
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension WebcamSectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let pointConverted = collectionView.convert(location, from: view)
        
        if let indexPath = collectionView.indexPathForItem(at: pointConverted) {
            
            let cell: WebcamCollectionViewCell = collectionView.cellForItem(at: indexPath) as! WebcamCollectionViewCell
            previewingContext.sourceRect = view.convert(cell.frame, from: collectionView)
            
            if let webcam = provider.objects?[indexPath.row] {
                let detail = WebcamDetailViewController(webcam: webcam)
                detail.initiatingPreviewActionController = self
                return detail
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
