import SwiftUI
import Vision

struct ContentView: View {
    @State private var resultText = "Analyzed results here"
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            Text("Image Classification")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 200)
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 100)
                }
            }

            Button(action: {
                self.showImagePicker.toggle()
            }) {
                Text("Select Image")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            Text(resultText)
                .foregroundColor(.black)
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            Spacer()
            
            Text("Made By Speedyfriend67")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, -30)
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: self.$selectedImage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .imageAnalyzed)) { _ in
            self.analyzeImage()
        }
    }

    private func analyzeImage() {
        guard let selectedImage = selectedImage,
              let ciImage = CIImage(image: selectedImage) else {
            return
        }

        do {
            let model = try VNCoreMLModel(for: MobileNetV2().model)
            let handler = VNImageRequestHandler(ciImage: ciImage)
            let request = VNCoreMLRequest(model: model) { request, _ in
                if let results = request.results as? [VNClassificationObservation], let firstResult = results.first {
                    self.resultText = "\(firstResult.identifier) (\(Int(firstResult.confidence * 100))%)"
                } else {
                    self.resultText = "No Results"
                }
            }
            try handler.perform([request])
        } catch {
            print("Image Analyze Error: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                NotificationCenter.default.post(name: .imageAnalyzed, object: nil)
            }

            picker.dismiss(animated: true)
        }
    }
}

extension Notification.Name {
    static let imageAnalyzed = Notification.Name("imageAnalyzed")
}
