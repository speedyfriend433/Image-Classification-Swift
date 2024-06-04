import SwiftUI
import CoreML
import Vision
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var recognizedText = ""
    @State private var mnistClassifier: VNCoreMLModel?
    
    var body: some View {
        VStack {
            CanvasView(canvasView: $canvasView)
                .frame(height: 400)
                .background(canvasBackgroundColor())
                .cornerRadius(10)
                .padding()
            
            Button("Recognize") {
                recognizeDrawing()
            }
            .padding()
            
            Text("Recognized Number: \(recognizedText)")
                .padding()
            
            Button("Clear") {
                clearCanvas()
            }
            .padding()
        }
        .onAppear {
            loadModel()
        }
    }
    
    func loadModel() {
        guard let modelURL = Bundle.main.url(forResource: "MNISTClassifier", withExtension: "mlmodelc") else {
            print("Model file not found")
            return
        }
        
        do {
            let model = try MLModel(contentsOf: modelURL)
            self.mnistClassifier = try VNCoreMLModel(for: model)
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }
    }
    
    func recognizeDrawing() {
        guard let mnistClassifier = mnistClassifier else {
            print("Model is not loaded")
            return
        }
        
        let drawing = canvasView.drawing
        guard let image = drawing.image(from: drawing.bounds, scale: 1.0).cgImage else {
            print("Failed to get image from drawing")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        let request = VNCoreMLRequest(model: mnistClassifier) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                if let topResult = results.first {
                    DispatchQueue.main.async {
                        self.recognizedText = topResult.identifier
                    }
                }
            } else {
                print("No results found: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform request: \(error.localizedDescription)")
            }
        }
    }
    
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
        recognizedText = ""
    }
    
    func canvasBackgroundColor() -> Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

@main
struct HandwritingRecognitionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
