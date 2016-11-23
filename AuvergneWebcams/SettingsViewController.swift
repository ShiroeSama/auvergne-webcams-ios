//
//  SettingsViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 13/11/2016.
//
//

import UIKit
import Eureka
import SafariServices
import SwiftyUserDefaults

enum SettingTag: String {
    case theme
    case autoRefresh
    case autoRefreshDelay
    case about
    case openium
    case rateApp
}

class SettingsViewController: FormViewController {    
    private var foregroundNotification: Any?
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(style),
                                               name: NSNotification.Name.SettingsDidUpdateTheme,
                                               object: nil)
        
        setupForm()
        style()
        translate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let navigationController = navigationController {
            let inset = UIApplication.shared.statusBarFrame.height + navigationController.navigationBar.frame.height
            
            tableView?.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        }
    }
    
    // MARK: - Form
    
    func setupForm() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        form =
            Section("General")
            <<< SwitchRow(SettingTag.theme.rawValue) {
                $0.title = "Thème sombre"
                $0.value = Defaults[.isDarkTheme]
            }.onChange { row in
                Defaults[.isDarkTheme] = row.value ?? false
                NotificationCenter.default.post(name: NSNotification.Name.SettingsDidUpdateTheme,
                                                object: self)
            }
            <<< SwitchRow(SettingTag.autoRefresh.rawValue) {
                $0.title = "Rafraîchissement automatique"
                $0.value = Defaults[.shouldAutorefresh]
            }.onChange { row in
                Defaults[.shouldAutorefresh] = row.value ?? false
                NotificationCenter.default.post(name: NSNotification.Name.SettingsDidUpdateAutorefresh,
                                                object: self)
            }
            <<< IntRow(SettingTag.autoRefreshDelay.rawValue) {
                $0.title = "Délai de rafraîchissement (minutes)"
                $0.value = Int(Defaults[.autorefreshInterval] / 60)
                $0.hidden = Condition.function([SettingTag.autoRefresh.rawValue], { form in
                    return !((form.rowBy(tag: SettingTag.autoRefresh.rawValue) as? SwitchRow)?.value ?? false)
                })
                $0.validationOptions = .validatesOnDemand
                $0.add(rule: RuleGreaterOrEqualThan(min: 1))
                $0.add(rule: RuleSmallerOrEqualThan(max: 120))
                $0.add(rule: RuleRequired())
            }.cellSetup { cell, row in
            }.cellUpdate { cell, row in

            }.onChange { row in
                
            }.onCellHighlightChanged { cell, row in
                row.validate()
                
                if row.isValid {
                    Defaults[.autorefreshInterval] = Double(row.value ?? 0) * 60
                } else {
                    let message = "Le délai de rafraîchissement doit être suppérieur à 0 et inférieur à 120"
                    let alertController = UIAlertController(title: "Erreur",
                                                            message: message,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .cancel,
                                                 handler: nil)
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    row.value = Int(Defaults[.autorefreshInterval])
                    row.updateCell()
                }
            }
            
            +++ Section(header: "Auvergne Webcams", footer: "Version \(version) (\(build))")
            <<< LabelRow() {
                $0.title = "À propos"
            }.onCellSelection { _, _ in
                self.showAbout()
            }
            <<< LabelRow() {
                $0.title = "Openium"
            }.onCellSelection { _, _ in
                self.showOpeniumWebsite()
            }
            <<< LabelRow() {
                $0.title = "Noter l'application"
            }.onCellSelection { _, _ in
                self.rateApp()
            }
    }
    
    // MARK: -
    
    func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/xxxxxxx") else { return }
        UIApplication.shared.openURL(url)
    }
    
    func showOpeniumWebsite() {
        guard let url = URL(string : "http://openium.fr") else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    func showAbout() {
        let avc = AboutViewController()
        navigationController?.pushViewController(avc, animated: true)
    }
    
    func translate() {
        navigationItem.title = "Paramètres"
    }
    
    func style() {
        let tintColor: UIColor = ThemeUtils.tintColor()
        
        if Defaults[.isDarkTheme] {
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            blurView.effect = UIBlurEffect(style: .extraLight)
        }
        
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor.clear
        tableView?.tintColor = tintColor
        
        IntRow.defaultCellUpdate = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = tintColor
            cell.textField.textColor = tintColor
            cell.accessoryType = .disclosureIndicator
        }
        
        LabelRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
        }
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = tintColor
            cell.accessoryType = .disclosureIndicator
        }
        
        SwitchRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
        }
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.switchControl?.tintColor = tintColor
            cell.switchControl?.onTintColor = tintColor
            cell.textLabel?.textColor = tintColor
        }
        
//        tableView?.reloadData()
        setupForm()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareDisclosureIndicator()
    }
}
