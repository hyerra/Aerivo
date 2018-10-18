//
//  MapWindowController.swift
//  Aerivo MacOS
//
//  Created by Harish Yerra on 9/22/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Cocoa
import MapboxGeocoder

class MapWindowController: NSWindowController {
    
    @IBOutlet weak var placesSearchField: NSSearchField!
    
    private lazy var suggestionsController: SuggestionsWindowController = {
        let suggestionsController = SuggestionsWindowController()
        suggestionsController.target = self
        suggestionsController.action = #selector(update(withSelectedSuggestion:))
        return suggestionsController
    }()
    
    var previousMapSearchTask: URLSessionDataTask?
    var mapSearchResults: [GeocodedPlacemark] = [] { didSet { updateSuggestions(from: placesSearchField) } }

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        placesSearchField.delegate = self
    }
    
    // MARK: - Search Map
    
    @objc private func searchMap(for query: String) {
        let options = ForwardGeocodeOptions(query: query)
        //FIXME: Get user's location
        //options.focalLocation = (pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView.userLocation?.location
        options.maximumResultCount = 10
        options.locale = Locale.autoupdatingCurrent
        
        let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
            self.mapSearchResults = placemarks ?? []
        }
        previousMapSearchTask = task
    }
    
}

// MARK: - Search field delegate
extension MapWindowController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        updateSuggestions(from: sender)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        previousMapSearchTask?.cancel()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchMap(for:)), with: placesSearchField.stringValue, afterDelay: 0.5)
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        /* If the suggestionController is already in a cancelled state, this call does nothing and is therefore always safe to call.
         */
        suggestionsController.cancelSuggestions()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            // Move up in the suggested selections list
            suggestionsController.moveUp(placesSearchField)
            return true
        } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
            // Move down in the suggested selections list
            suggestionsController.moveDown(placesSearchField)
            return true
        } else if commandSelector == #selector(NSResponder.complete(_:)) {
            // The user has pressed the key combination for auto completion. AppKit has a built in auto completion. By overriding this command we prevent AppKit's auto completion and can respond to the user's intention by showing or cancelling our custom suggestions window.
            if let window = suggestionsController.window, window.isVisible {
                suggestionsController.cancelSuggestions()
            }
            
            return true
        }
        // This is a command that we don't specifically handle, let the field editor do the appropriate thing.
        return false
    }
    
    private func update(fieldEditor: NSText?, with suggestion: String?) {
        let selection = NSRange(location: fieldEditor?.selectedRange.location ?? 0, length: suggestion?.count ?? 0)
        fieldEditor?.string = suggestion ?? ""
        fieldEditor?.selectedRange = selection
    }
    
    @objc func update(withSelectedSuggestion sender: Any) {
        let entry = (sender as? SuggestionsWindowController)?.selectedSuggestion()
        if entry != nil {
            let fieldEditor: NSText? = window?.fieldEditor(false, for: placesSearchField)
            if fieldEditor != nil {
                update(fieldEditor: fieldEditor, with: entry?.formattedName)
            }
        }
    }
    
    func updateSuggestions(from searchField: NSSearchField) {
        // Only use the text up to the caret position
        if mapSearchResults.count > 0 {
            // We have at least 1 suggestion. Show the suggestions window.
            suggestionsController.set(suggestions: mapSearchResults)
            if !(suggestionsController.window?.isVisible ?? false) {
                suggestionsController.begin(for: searchField)
            }
        } else {
            suggestionsController.cancelSuggestions()
        }
    }
}
