//
//  WebcamCarouselViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Kingfisher

protocol WebcamCarouselViewProviderDelegate: class {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView)
}

class WebcamCarouselViewProvider: AbstractArrayViewProvider<WebcamSection, WebcamCarouselTableViewCell> {
    weak var delegate: WebcamCarouselViewProviderDelegate?
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 450
        } else {
            return 320
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webcamCarousel(viewProvider: self, scrollViewDidScroll: scrollView)
    }
}

class WebcamCarouselViewController: AbstractRefreshViewController {
    
    @IBOutlet var clearSearchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    lazy var provider: WebcamCarouselViewProvider = {
        let provider = WebcamCarouselViewProvider(tableView: self.tableView)
        provider.delegate = self
        return provider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onSettingsTouched))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(refresh))
        
        clearSearchButton.isHidden = true
        
        provider.objects = [
            WebcamSection.pddSection(),
            WebcamSection.sancySection(),
            WebcamSection.lioranSection()
        ]
        provider.additionalCellConfigurationCustomizer = { [weak self](cell: WebcamCarouselTableViewCell, item: WebcamSection) in
            guard let lastObject = self?.provider.objects?.last else { return }
            
            cell.set(isLast: item == lastObject)
            cell.set(delegate: self)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        coordinator.animate(alongsideTransition: transition,
                            completion: nil)
    }
    
    // MARK: -
    
    func onSettingsTouched() {
        let settingsVC = SettingsViewController()
        let navigationVC = NavigationController(rootViewController: settingsVC)
        
        navigationVC.modalPresentationStyle = .overCurrentContext
        
        present(navigationVC, animated: true, completion: nil)
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
        
        tableView.reloadData()
        lastUpdate = NSDate().timeIntervalSinceReferenceDate
    }
    
    override func translate() {
        super.translate()
        
        title = "Auvergne Webcams"
        searchTextField.attributedPlaceholder = "Rechercher une webcam"
            .withFont(UIFont.proximaNovaLightItalic(withSize: 16))
            .withTextColor(UIColor.awLightGray)
    }
    
    override func update() {
        super.update()
    }
    
    // MARK: - IBActions
    
    @IBAction func onSearchTouched(_ sender: Any) {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func onEditingDidBegin(_ sender: Any) {
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
        
        clearSearchButton.isHidden = false
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
    }
}

// MARK: - WebcamCarouselViewProviderDelegate

extension WebcamCarouselViewController: WebcamCarouselViewProviderDelegate {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView) {
        if searchTextField.isEditing {
            searchTextField.endEditing(true)
        }
    }
}

// MARK: - WebcamCarouselTableViewCellDelegate

extension WebcamCarouselViewController: WebcamCarouselTableViewCellDelegate {
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectWebcam webcam: Webcam) {
        let webcamDetail = WebcamDetailViewController(webcam: webcam)
        navigationController?.pushViewController(webcamDetail, animated: true)
    }
    
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectSection section: WebcamSection) {
        let sectionDetail = WebcamSectionViewController(section: section)
        navigationController?.pushViewController(sectionDetail, animated: true)
    }
}