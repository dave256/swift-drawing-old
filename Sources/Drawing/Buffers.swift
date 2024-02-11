//
//  Buffers.swift
//
//
//  Created by David Reed on 2/11/24.
//

import SwiftUI

#if os(macOS)
public typealias PlatformImage = NSImage
#else
public typealias PlatformImage = UIImage
#endif

/// color values for a pixel
public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

/// some sample colors
public extension PixelData {
    static var red: PixelData { PixelData(a: 255, r: 200, g: 0, b: 0) }
    static var orange: PixelData { PixelData(a: 255, r: 255, g: 165, b: 0) }
    static var yellow: PixelData { PixelData(a: 255, r: 255, g: 165, b: 0) }
    static var green: PixelData { PixelData(a: 255, r: 0, g: 200, b: 0) }
    static var blue: PixelData { PixelData(a: 255, r: 0, g: 0, b: 200) }
    static var indigo: PixelData { PixelData(a: 255, r: 75, g: 0, b: 130) }
    static var violet: PixelData { PixelData(a: 255, r: 160, g: 32, b: 240) }
    static var black: PixelData { PixelData(a: 255, r: 0, g: 0, b: 0) }
    static var white: PixelData { PixelData(a: 255, r: 255, g: 255, b: 255) }
    static var clear: PixelData { PixelData(a: 0, r: 0, g: 0, b: 0) }
}

/// FrameBuffer for creating an image from individual pixels
@Observable
public class FrameBuffer {
    /// UIImage or NSImaage that is observed
    public private(set) var image: PlatformImage = PlatformImage()

    /// width of FrameBuffer
    @ObservationIgnored
    public private(set) var width: Int

    /// height
    @ObservationIgnored
    public private(set) var height: Int

    /// color for each pixel as a 1D array that is width * height in size
    @ObservationIgnored
    private var pixels: [PixelData]

    /// init FrameBuffer
    /// - Parameters:
    ///   - width: width of its image
    ///   - height: height of its image
    ///   - color: initial color for each pixel
    public init(width: Int, height: Int, color: PixelData = .clear) {
        self.width = width
        self.height = height
        pixels = .init(repeating: .green, count: width * height)
    }
    
    /// clear the image buffer by setting each pixel to the specified color
    /// - Parameter color: color to use to set each pixel
    public func clear(color: PixelData = .clear) {
        for i in 0..<width * height {
            pixels[i] = color
        }
    }

    /// set pixel to a color
    /// - Parameters:
    ///   - row: row of pixel
    ///   - col: column of pixel
    ///   - color: color to set it to
    public func setPixel(row: Int, col: Int, color: PixelData) {
        pixels[row * width + col] = color
    }

    /// use this function to generate image and cause observation
    public func generateImage() {
#if os(macOS)
        image = imageFromPixelData() ?? NSImage(systemSymbolName: "exclamationmark.warninglight", accessibilityDescription: nil)!
#else
        image = imageFromPixelData() ?? UIImage(systemName: "exclamationmark.warninglight")!
#endif
    }

    ///  for setting and getting a pixel
    ///  frameBuffer[row, col] = pixelData
    public subscript(row: Int, col: Int) -> PixelData {
        get {
            pixels[row * width + col]
        }
        set {
            pixels[row * width + col] = newValue
        }
    }
    
    /// private helper function to generate an image from the array of pixels
    /// - Returns: UIImage? or NSImage? with image
    private func imageFromPixelData() -> PlatformImage? {
        // based on: https://stackoverflow.com/questions/30958427/pixel-array-to-uiimage-in-swift
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32

        guard let providerRef = CGDataProvider(data: NSData(bytes: &pixels, length: pixels.count * MemoryLayout<PixelData>.size))
        else { return nil }

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        else { return nil }

#if os(macOS)
        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
#else
        return PlatformImage(cgImage: cgImage)
#endif
    }
}

/// ZBuffer for tracking z value of closest pixel
public class ZBuffer {
    
    /// initialize the ZBuffer
    /// - Parameters:
    ///   - width: width for it
    ///   - height: height for it
    ///   - value: initial z-value for each pixel
    public init(width: Int, height: Int, value: CGFloat = 2.0) {
        self.width = width
        self.height = height
        buffer = .init(repeating: 2.0, count: width * height)
    }
    
    /// clear the buffer by setting all locations to value
    /// - Parameter value: value to initialize each buffer value with
    public func clear(_ value: CGFloat = 2.0) {
        for idx in 0..<width * height {
            buffer[idx] = value
        }
    }
    
    /// width of ZBuffer
    public private(set) var width: Int
    
    /// height of ZBuffer
    public private(set) var height: Int

    /// 1D array of CGFloat that is of size width * height
    private var buffer: [CGFloat]

    ///  for setting and getting a value
    ///  zBuffer[row, col] = 0.5
    public subscript(row: Int, col: Int) -> CGFloat {
        get {
            buffer[row * width + col]
        }
        set {
            buffer[row * width + col] = newValue
        }
    }
}

#if DEBUG
struct ContentView: View {
    var frameBuffer = FrameBuffer(width: 500, height: 500)

    var body: some View {
        VStack {
#if os(macOS)
            Image(nsImage: frameBuffer.image)
                .onAppear {
                    frameBuffer.generateImage()
                }
#else
            Image(uiImage: frameBuffer.image)
                .onAppear {
                    frameBuffer.generateImage()
                }
#endif
            Button("set") {
                for row in 45...55 {
                    for col in 0..<500 {
                        frameBuffer[row, col] = .blue
                    }
                }
            }.padding(.bottom, 20)

            Button("regenerate") {
                frameBuffer.generateImage()
            }

            Button("clear") {
                frameBuffer.clear(color: .green)
                frameBuffer.generateImage()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

#endif
