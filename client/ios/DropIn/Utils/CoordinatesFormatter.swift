//
//  CoordinatesFormatter.swift
//  dropin
//
//  Created by Michael Voemel on 01.05.2025.
//

import Foundation
import CoreLocation

func formatCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
    let latDirection = latitude >= 0 ? "N" : "S"
    let lonDirection = longitude >= 0 ? "E" : "W"
    let latAbs = abs(latitude)
    let lonAbs = abs(longitude)
    return String(format: "%.5f° %@, %.5f° %@", latAbs, latDirection, lonAbs, lonDirection)
}
