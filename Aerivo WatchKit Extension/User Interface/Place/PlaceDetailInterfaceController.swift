//
//  PlaceDetailInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import AerivoKit
import Foundation

class PlaceDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "placeDetailIC"
    
    var placemark: Placemark!
    
    @IBOutlet var location: WKInterfaceLabel!
    @IBOutlet var contactOfficialButton: WKInterfaceButton!
    
    @IBOutlet var airQualityHeading: WKInterfaceLabel!
    @IBOutlet var airQualityTable: WKInterfaceTable!
    
    @IBOutlet var waterQualityHeading: WKInterfaceLabel!
    @IBOutlet var waterQualityTable: WKInterfaceTable!
    
    lazy var civicInformationClient = CivicInformationClient()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Back", comment: "Allows the user to go back to the previous screen."))
        self.placemark = context as? Placemark
        location.setText(placemark.displayName)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Actions
    
    @IBAction func contactOfficial() {
        contactOfficialButton.setEnabled(false)
        
        var representativeInfoParams = RepresentativeInfoByAddressParameters()
        representativeInfoParams.address = placemark.addressLines?.joined(separator: " ")
        representativeInfoParams.levels = [.administrativeArea1, .administrativeArea2, .locality, .regional, .special, .subLocality1, .subLocality2]
        representativeInfoParams.roles = [.deputyHeadOfGovernment, .executiveCouncil, .governmentOfficer, .headOfGovernment, .headOfState, .legislatorLowerBody, .legislatorUpperBody]
        civicInformationClient.fetchRepresentativeInfo(using: representativeInfoParams) { result in
            self.contactOfficialButton.setEnabled(true)
            
            if case let .success(representativeInfo) = result {
                func showNoDataAlert() {
                    let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                    let localizedMessage = String.localizedStringWithFormat("%@ doesn't have enough information about government officials for your area. Try using the iPhone app for more options of communication.", appName)
                    let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                    self.presentAlert(withTitle: NSLocalizedString("Oops 😣", comment: "Title of alert control for not enough data error."), message: localizedMessage, preferredStyle: .alert, actions: [cancelAction])
                }
                
                guard let officials = representativeInfo.officials else { showNoDataAlert(); return }
                let filteredOfficials = officials.filter { !($0.phones ?? []).isEmpty }
                guard !filteredOfficials.isEmpty else { showNoDataAlert(); return }
                
                var actions: [WKAlertAction] = []
                
                for official in filteredOfficials {
                    let title = official.name + (official.party != nil ? "" : "")
                    let action = WKAlertAction(title: title, style: .default) {
                        var actions: [WKAlertAction] = []
                        
                        if let phones = official.phones, !phones.isEmpty {
                            for phone in phones {
                                let action = WKAlertAction(title: phone, style: .default) {
                                    var components = URLComponents()
                                    components.scheme = "tel"
                                    components.path = phone
                                    guard let url = components.url else { return }
                                    WKExtension.shared().openSystemURL(url)
                                }
                                actions.append(action)
                            }
                            
                            let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                            actions.append(cancelAction)
                            self.presentAlert(withTitle: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), message: NSLocalizedString("Choose a number to call your government official.", comment: "Message that tells the user to select a phone number."), preferredStyle: .actionSheet, actions: actions)
                        }
                    }
                    actions.append(action)
                }
                
                let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                actions.append(cancelAction)
                self.presentAlert(withTitle: NSLocalizedString("Government Officials", comment: "Title for a list of governement officials a user can contact."), message: NSLocalizedString("Choose one of the government officials you wish to contact.", comment: "Message for a list of government officials a user can contact."), preferredStyle: .actionSheet, actions: actions)
            } else {
                let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                let localizedMessage = String.localizedStringWithFormat("%@ is having trouble getting government representative information. This may be caused by a network error or because the app doesn't have enough information about government officials for your area.", appName)
                let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                self.presentAlert(withTitle: NSLocalizedString("Oops 😣", comment: "Title of alert control for network error."), message: localizedMessage, preferredStyle: .alert, actions: [cancelAction])
            }
        }
    }
}
