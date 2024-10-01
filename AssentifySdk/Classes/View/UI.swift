
import Foundation
import SVGKit
import UIKit


class Guide{
    
   private var cardBackground :SVGKImage?
   private var cardSvgImageView :SVGKFastImageView?
    
    private var faceBackground :SVGKImage?
    private var faceSvgImageView :SVGKFastImageView?
    
    func showCardGuide(view:UIView){
           guard let modelPath = Bundle.main.path(forResource: "card_background", ofType: "svg") else {
                  print("SVG file not found.")
                  return
            }

            guard let svgImage = SVGKImage(contentsOfFile: modelPath) else {
                print("Failed to load SVG image.")
                return
            }
            cardBackground = svgImage;
            cardSvgImageView = SVGKFastImageView(svgkImage: svgImage)
            cardSvgImageView!.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cardSvgImageView!)
             NSLayoutConstraint.activate([
                cardSvgImageView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cardSvgImageView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                cardSvgImageView!.widthAnchor.constraint(equalTo: view.widthAnchor),
                cardSvgImageView!.heightAnchor.constraint(equalTo: view.heightAnchor)
               ])
    }
    
    
    func changeCardColor(view:UIView,to color: String) {
        cardSvgImageView!.removeFromSuperview()
        let layerIDsToChange = ["Layer_1-1", "Layer_1-2", "Layer_1-3", "Layer_1-4"]
        self.changeLayerColor(svgImage: self.cardBackground!, layerIDs: layerIDsToChange ,newColor: UIColor(hexString: color) )
        cardSvgImageView = SVGKFastImageView(svgkImage: self.cardBackground)
        cardSvgImageView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardSvgImageView!)
        NSLayoutConstraint.activate([
            cardSvgImageView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardSvgImageView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardSvgImageView!.widthAnchor.constraint(equalTo: view.widthAnchor),
            cardSvgImageView!.heightAnchor.constraint(equalTo: view.heightAnchor)
          ])
    }
    
    //// Face
    
    func showFaceGuide(view:UIView){
           guard let modelPath = Bundle.main.path(forResource: "face_background", ofType: "svg") else {
                  print("SVG file not found.")
                  return
            }

            guard let svgImage = SVGKImage(contentsOfFile: modelPath) else {
                print("Failed to load SVG image.")
                return
            }
            faceBackground = svgImage;
            faceSvgImageView = SVGKFastImageView(svgkImage: svgImage)
            faceSvgImageView!.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(faceSvgImageView!)
             NSLayoutConstraint.activate([
                faceSvgImageView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                faceSvgImageView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                faceSvgImageView!.widthAnchor.constraint(equalTo: view.widthAnchor),
                faceSvgImageView!.heightAnchor.constraint(equalTo: view.heightAnchor)
               ])
    }

    func changeFaceColor(view:UIView,to color: String) {
        faceSvgImageView!.removeFromSuperview()
        let layerIDsToChange = ["Layer_1-1"]
        self.changeLayerColor(svgImage: self.faceBackground!, layerIDs: layerIDsToChange ,newColor: UIColor(hexString: color) )
        faceSvgImageView = SVGKFastImageView(svgkImage: self.faceBackground)
        faceSvgImageView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(faceSvgImageView!)
        NSLayoutConstraint.activate([
            faceSvgImageView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faceSvgImageView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            faceSvgImageView!.widthAnchor.constraint(equalTo: view.widthAnchor),
            faceSvgImageView!.heightAnchor.constraint(equalTo: view.heightAnchor)
          ])
    }
 
    /// Color
    func changeLayerColor(svgImage: SVGKImage, layerIDs: [String], newColor: UIColor) {
        for layerID in layerIDs {
            if let layer = svgImage.layer(withIdentifier: layerID) as? CAShapeLayer {
                layer.fillColor = newColor.cgColor
            }
        }
    }
    
    func showFaceTimer(view: UIView, initialTextColorHex: String,countdownFinished: @escaping () -> Void) -> UIView {
        
        let countdownLabel = UILabel()
        countdownLabel.font = UIFont.boldSystemFont(ofSize: 130)
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = UIColor(hexString: initialTextColorHex)
        countdownLabel.backgroundColor = UIColor.clear
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 100),
            countdownLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        var countdownValue = 3
        countdownLabel.text = "\(countdownValue)"
        
        let countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
                countdownLabel.text = "\(countdownValue)"
            } else {
                timer.invalidate()
                countdownLabel.text = "1"
                countdownFinished()
                countdownLabel.removeFromSuperview()
            }
        }
        
        return countdownLabel
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let red = CGFloat(Int(color >> 16) & mask) / 255.0
        let green = CGFloat(Int(color >> 8) & mask) / 255.0
        let blue = CGFloat(Int(color) & mask) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}


