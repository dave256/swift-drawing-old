//
//  Shapes.swift
//  
//
//  Created by David Reed on 12/4/23.
//

import SwiftUI

/// square with sides of  length one centered at  (0, 0)
public struct UnitSquare: PathDrawable, Equatable {
    /// init
    /// - Parameters:
    ///   - drawStyle: how to draw the shape
    ///   - transforms: transforms to apply to the shape in the order they are in the array
    public init(drawStyle: DrawStyle, transforms: [Transform]) {
        self.drawStyle = drawStyle
        self.transforms = transforms
    }

    public var drawStyle: DrawStyle
    public var transforms: [Transform]
    public var path: Path {
        Path { path in
            path.move(to: CGPoint(x: -0.5, y: -0.5))
            path.addLine(to: CGPoint(x: -0.5, y: 0.5))
            path.addLine(to: CGPoint(x: 0.5, y: 0.5))
            path.addLine(to: CGPoint(x: 0.5, y: -0.5))
            path.addLine(to: CGPoint(x: -0.5, y: -0.5))
        }
    }
}

/// circle with radius one centered at (0, 0)
/// note this will be larger than the unit square - for it to be similar, it would need to have radius 0.5
public struct UnitCircle: PathDrawable, Equatable {
    /// init
    /// - Parameters:
    ///   - drawStyle: how to draw the shape
    ///   - transforms: transforms to apply to the shape in the order they are in the array
    public init(drawStyle: DrawStyle, transforms: [Transform]) {
        self.drawStyle = drawStyle
        self.transforms = transforms
    }

    public var drawStyle: DrawStyle
    public var transforms: [Transform]
    public var path: Path {
        Path.init(ellipseIn: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
    }

}

// use default Drawable draw implementation since these are PathDrawable
extension UnitCircle: Drawable {}
extension UnitSquare: Drawable {}
