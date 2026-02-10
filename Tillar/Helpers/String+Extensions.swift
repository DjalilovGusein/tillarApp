//
//  String+Extensions.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//
import Foundation

extension String {
    func localized(_ lang: String = UD.language, arguments: CVarArg...) -> String {
        let localizedBundle: Bundle

        if
            let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            localizedBundle = bundle
        } else {
            localizedBundle = .main
        }

        let localizedString = NSLocalizedString(self, tableName: nil, bundle: localizedBundle, value: "", comment: "")
        
        return String(format: localizedString, arguments: arguments)
    }
}
