//
//  DateArrayTransformer.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import Foundation

@objc(DateArrayTransformer)
class DateArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let dateArray = value as? [Date] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: dateArray, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Date]
    }
}
