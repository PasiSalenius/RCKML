//
//  KMLElement.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import Foundation
import AEXML

//MARK:- KML Element


/// Any type of element found in a KML file, as described in the
/// [KML specification](https://developers.google.com/kml/documentation/kmlreference)
/// or [OGC KML Standard](https://www.ogc.org/standards/kml/)
///
/// The basic functions of this protocol are to provide encoding and decoding support
/// to a class or type of KML Element (for example, **Feature**, **Geometry**, or **Style**).
///
///
public protocol KmlElement {
    /// The XML element name for this type of KML Element, such as
    /// **Feature**, **Document**, **Geometry**, **Style**, etc.
    static var kmlTag: String { get }
    
    /// Initializes the KmlElement using an AEXMLElement read from a KML file.
    /// - Parameter xml: xml element read from a valid KML file.
    init(xml: AEXMLElement) throws
    
    /// A representation of the KML element as AEXMLElement, for writing to KML file.
    var xmlElement: AEXMLElement { get }
}

//MARK: Initializer Helpers
internal extension KmlElement {
    /// Call this function at the beginning of any `KmlElement.init(xml:)` to
    /// ensure that the xml tag being used to create the object is of the correct
    /// type
    ///
    /// - Parameter xml: the xml element being used to check against.
    /// - Throws: If the xml tag name is different from Self.kmlTag, throws a xmlTagMismatch error.
    static func verifyXmlTag(_ xml:AEXMLElement) throws {
        guard xml.name == kmlTag else {
            throw KMLError.xmlTagMismatch
        }
    }
    
    /// Shorthand to generate an attributes dictionary for use in `self.xmlElement`,
    /// using the element's optional id as the first entry in the dictionary.
    ///
    /// - Parameter id: The optional id of this KML element.
    /// - Returns: A dictionary of `["id":self.id]` if `self.id` exists, or an empty dictionary if it doesn't.
    static func xmlAttributesWithId(_ id:String?) -> [String : String] {
        id != nil ? ["id":id!] : [:]
    }
}

//MARK:- KML Extension for AEXMLElement

internal extension AEXMLElement {
    
    /// For use in creating KMLElement from AEXMLElement, this function is shorthand
    /// for getting a known KMLElement child from the XML element.
    ///
    /// Only call this function if the child item type is absolutely certain
    /// to be present as a child of this XML element.
    ///
    /// - Parameter type: the Swift type (implementing KmlElement protocol) of the returned child.
    /// - Throws: XML error, or any type of `KMLError`
    /// - Returns: The first child element of this XML element of the given type, formatted as type `type`.
    func requiredKmlChild<T: KmlElement>(ofType type:T.Type) throws -> T {
        let subItem = try requiredXmlChild(name: T.kmlTag)
        let item = try T(xml: subItem)
        return item
    }
    
    /// Shorthand for getting a known child element from AEXMLElement.
    ///
    /// Only call this function if you are certain that this XML element
    /// contains a child of the given name.
    ///
    /// - Parameter name: the name of the child tag to be returned.
    /// - Throws: XML error
    /// - Returns: The first child element of this XML element that has the given name.
    func requiredXmlChild(name: String) throws -> AEXMLElement {
        let subItem = self[name]
        if let error = subItem.error {
            throw error
        }
        return subItem
    }
    
    /// Shorthand for getting an optional child element from AEXMLElement, bypassing
    /// error-throwing and returning nil instead.
    ///
    /// - Parameter name: The name of the child tag to be returned.
    /// - Returns: The first XML Element with the given name, or nil if not present or any error is thrown.
    func optionalXmlChild(name: String) -> AEXMLElement? {
        let subItem = self[name]
        if subItem.error != nil {
            return nil
        }
        return subItem
    }
    
    /// For use in creating KMLElement from AEXMLElement, this function is shorthand
    /// for getting a possible KMLElement child from the XML element.
    ///
    /// - Parameter type: the Swift type (implementing KmlElement protocol) of the returned child.
    /// - Returns: The first child element of this XML element of the given type,
    /// formatted as type `type`, or nil if no child of that type exists.
    func optionalKmlChild<T: KmlElement>(ofType type:T.Type) -> T? {
        let subItem = self[T.kmlTag]
        if subItem.error != nil {
            return nil
        }
        return try? T(xml: subItem)
    }
    
    /// For use in creating KMLElement from AEXMLElement, this function is shorthand for getting
    /// all possible KMLElement children of a given type from this XMLElement.
    ///
    /// - Parameter type: The Swift type (implementing KmlElement protocol) of the returned children.
    /// - Throws: KMLErrors generated by `KmlElement.init(xml:)` calls.
    /// - Returns: An array of KMLElement type `type`
    func allKmlChildren<T: KmlElement>(ofType type:T.Type) throws -> [T] {
        let childs = try children.filter({ $0.name == T.kmlTag }).compactMap({ try T(xml: $0) })
        return childs
    }

}
