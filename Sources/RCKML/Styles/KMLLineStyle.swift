//
//  KMLLineStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A style used to draw lines or polygon boundaries with a given width and color.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#linestyle)
public struct KMLLineStyle {
    public var id: String?
    public var width: Double
    public var color: KMLColor?

    public init(id: String? = nil,
         width: Double = 1.0,
         color: KMLColor? = nil)
    {
        self.id = id
        self.width = width
        self.color = color
    }
}

// MARK: - KmlElement

extension KMLLineStyle: KmlElement {
    public static var kmlTag: String {
        "LineStyle"
    }

    public init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        self.id = xml.attributes["id"]
        self.width = xml.optionalXmlChild(name: "width")?.double! ?? 1.0
        self.color = xml.optionalKmlChild(ofType: KMLColor.self)
    }

    public var xmlElement: AEXMLElement {
        let element = AEXMLElement(name: Self.kmlTag, attributes: Self.xmlAttributesWithId(id))
        element.addChild(name: "width", value: String(format: "%.1f", width))
        _ = color.map { element.addChild($0.xmlElement) }
        return element
    }
}

// MARK: - KMLColorStyle

extension KMLLineStyle: KMLColorStyle {}
