//
//  ObjectDetectionView.swift
//  Sample 1
//
//  Created by Vedant Kathrani on 3/31/23.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct ObjectDetectionView: View {
    @State private var resultText=""
    @State private var showingImagePicker=false
    @State private var inputImage: UIImage? = UIImage(named:"trash")
    
    @State var detectedObjects: [String] = []
    @EnvironmentObject var refreshManager:RefreshManager
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                Text("Looking for trash...")
                    .font(.system(size:42))
                    .fontWeight(.bold)
                    .padding(10)
                Image(uiImage: inputImage!).resizable()
                    .aspectRatio(contentMode: .fit)
                Button("Choose trash"){
                    self.buttonPressed()
                }
                .padding(.all, 14.0)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            }
                    .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: detectObjects) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func detectObjects() {
        guard let inputImage=inputImage else {
            print("No image selected")
            return
        }
        let model1=Trash_Detector_1().model
        //let model1=ObjectDetector_CatsDogs_v2_1().model
        guard let model = try? VNCoreMLModel(for: model1) else {
                fatalError("Failed to load Core ML model.")
            }
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                    print("Unexpected result type from VNCoreMLRequest.")
                    return
                }
                // Draw bounding boxes around the detected objects
                let imageSize = inputImage.size
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
                let scale = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
                let objectBoundsAndLabels = results.map { observation -> (CGRect, String) in
                         let observationBounds = observation.boundingBox
                         let objectBounds = observationBounds.applying(scale).applying(transform)
                         let label = observation.labels[0].identifier
                    
                         return (objectBounds, label)
                     }
                
                DispatchQueue.main.async {
                    self.inputImage = inputImage
                    self.refreshManager.refreshTab += 1
                    self.detectedObjects = results.map { observation in
                        return observation.labels[0].identifier
                    }
                    self.drawBoundingBoxes(on: &self.inputImage, with: objectBoundsAndLabels)
                }
            }
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!)
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform detection: \(error.localizedDescription)")
            }
        }
    
    
    func drawBoundingBoxes(on image: inout UIImage?, with objectBoundsAndLabels: [(CGRect, String)]) {
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
        image?.draw(in: CGRect(origin: CGPoint.zero, size: image!.size))
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(4.0)
        for (objectBounds, label) in objectBoundsAndLabels {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.addRect(objectBounds)
            context?.drawPath(using: .stroke)
            
            context?.setFillColor(UIColor.red.cgColor)
            if ["plastic"].contains(label) {
                DataStore.label=label
                DataStore.seen=true
            }
            print("Object bounds are \(objectBounds) for label \(label) and label is \(label) and seen is \(DataStore.seen)")
            
            let labelRect = CGRect(x: objectBounds.origin.x, y: max(objectBounds.origin.y - 55,0), width: objectBounds.width, height: 55)
            context?.fill(labelRect)
            
            context?.setFillColor(UIColor.black.cgColor)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let labelFontAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            let attributedLabel = NSAttributedString(string: label, attributes: labelFontAttributes)
            attributedLabel.draw(in: labelRect)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    
    
}


struct ObjectDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetectionView()
    }
}
