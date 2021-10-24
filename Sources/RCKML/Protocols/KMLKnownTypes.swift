//
//  KMLKnownTypes.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

// MARK: - Known Geometry Types

/// Helper enum to map between Geometry types in a KML file and the corresponding types
/// in this library.
/// - Important: Whenever a Geometry type is added to this library, you must also add
/// a corresponding case to this enum.
public enum KMLGeometryType: String, CaseIterable {
    case LineString
    case Polygon
    case Point
    case MultiGeometry

    /// The RCKML type that corresponds to this KML Geometry class.
    var concreteType: KMLGeometry.Type {
        switch self {
        case .LineString:
            return KMLLineString.self
        case .Polygon:
            return KMLPolygon.self
        case .Point:
            return KMLPoint.self
        case .MultiGeometry:
            return KMLMultiGeometry.self
        }
    }
}

// MARK: - Known Feature Types

/// Helper enum to map between Feature types in a KML file and the corresponding
/// types in this library.
/// - Important: Whenever a Feature type is added to this library, you must also add
/// a corresponding case to this enum
public enum KMLFeatureType: String, CaseIterable {
    case Folder
    case Placemark

    /// The RCKML type that corresponds to this KML feature class.
    var concreteType: KMLFeature.Type {
        switch self {
        case .Folder:
            return KMLFolder.self
        case .Placemark:
            return KMLPlacemark.self
        }
    }

    /// Tests whether an XML element is a recognized KML type for this library
    static func elementIsRecognizedType(_ xml: AEXMLElement) -> Bool {
        guard let type = KMLFeatureType(rawValue: xml.name) else {
            return false
        }

        if type == .Placemark,
           xml.children.first(where: { KMLGeometryType(rawValue: $0.name) != nil }) == nil
        {
            return false
        }

        return true
    }
}
