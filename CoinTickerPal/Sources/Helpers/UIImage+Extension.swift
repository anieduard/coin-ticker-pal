//
//  UIImage+Extension.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 25.03.2024.
//

import UIKit

extension UIImage {
    var dominantColor: UIColor? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }

        // Apply CIColorCube filter with cube dimension 2 to sample colors
        let colorCubeFilter = CIFilter(name: "CIColorCube")!
        colorCubeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorCubeFilter.setValue(2, forKey: "inputCubeDimension")

        // Get the output image
        guard let outputImage = colorCubeFilter.outputImage else {
            return nil
        }

        // Create a CIContext to render the output image
        let context = CIContext(options: nil)

        // Render the output image
        let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent)

        // Convert the CGImage to UIImage for processing
        let resultUIImage = UIImage(cgImage: outputCGImage!)

        // Get the most frequent color from the resulting image
        let dominantColor = resultUIImage.pixelColor

        return dominantColor
    }

    private var pixelColor: UIColor? {
        // Get the CGImage of the current UIImage
        guard let cgImage = self.cgImage else {
            return nil
        }

        // Create a color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Define the number of bytes per pixel and the number of bits per component
        let bytesPerPixel = 4
        let bitsPerComponent = 8

        // Calculate the bytes per row
        let bytesPerRow = bytesPerPixel * cgImage.width

        // Create a buffer to hold pixel data
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * cgImage.height)

        // Create a context to draw the image
        guard let context = CGContext(data: &pixelData,
                                      width: cgImage.width,
                                      height: cgImage.height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
            return nil
        }

        // Draw the image into the context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        // Create a frequency dictionary to count occurrences of colors
        var colorFreqDict = [UInt32: Int]()

        // Iterate over each pixel and count occurrences of each color
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = pixelData[i]
            let g = pixelData[i + 1]
            let b = pixelData[i + 2]

            // Convert RGB values to UInt32
            let color = (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)

            // Increment frequency count for the color
            colorFreqDict[color, default: 0] += 1
        }

        // Find the color with the highest frequency
        if let (mostFrequentColor, _) = colorFreqDict.max(by: { $0.value < $1.value }) {
            // Extract RGB components from the UInt32 color value
            let red = CGFloat((mostFrequentColor >> 16) & 0xFF) / 255.0
            let green = CGFloat((mostFrequentColor >> 8) & 0xFF) / 255.0
            let blue = CGFloat(mostFrequentColor & 0xFF) / 255.0

            // Create and return the UIColor
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }

        return nil
    }
}
