import UIKit

class ViewController: UIViewController {
    
    var layersStackView: UIStackView!
    var layerCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Create stack view to hold layers
        layersStackView = UIStackView()
        layersStackView.axis = .vertical
        layersStackView.alignment = .fill
        layersStackView.distribution = .equalSpacing
        layersStackView.spacing = 10
        
        layersStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(layersStackView)
        
        NSLayoutConstraint.activate([
            layersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            layersStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            layersStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            layersStackView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7)
        ])
        
        // Add button to add layers
        let addLayerButton = UIButton(type: .system)
        addLayerButton.setTitle("Add Layer", for: .normal)
        addLayerButton.addTarget(self, action: #selector(addLayer), for: .touchUpInside)
        
        addLayerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addLayerButton)
        
        NSLayoutConstraint.activate([
            addLayerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addLayerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Add button to remove layers
        let removeLayerButton = UIButton(type: .system)
        removeLayerButton.setTitle("Remove Layer", for: .normal)
        removeLayerButton.addTarget(self, action: #selector(removeLayer), for: .touchUpInside)
        
        removeLayerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(removeLayerButton)
        
        NSLayoutConstraint.activate([
            removeLayerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeLayerButton.bottomAnchor.constraint(equalTo: addLayerButton.topAnchor, constant: -20)
        ])
    }
    
    @objc func addLayer() {
        layerCount += 1
        let layerLabel = UILabel()
        layerLabel.text = "Layer \(layerCount)"
        layerLabel.textAlignment = .center
        layerLabel.backgroundColor = .lightGray
        layerLabel.layer.cornerRadius = 5
        layerLabel.layer.masksToBounds = true
        layersStackView.addArrangedSubview(layerLabel)
    }
    
    @objc func removeLayer() {
        guard layerCount > 0 else { return }
        layerCount -= 1
        layersStackView.arrangedSubviews.last?.removeFromSuperview()
    }
}
