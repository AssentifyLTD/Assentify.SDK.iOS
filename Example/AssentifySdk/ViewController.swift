//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate , FlowDelegate{
  
    
   
    let yellowColor = "🔥 -> ";
    private var assentifySdk :AssentifySdk?
    let environmentalConditions = EnvironmentalConditions(
          enableDetect: true,
          enableGuide: true,
          CountDownNumbersColor: "#FC4D92",
          HoldHandColor: "#FC4D92",
          activeLiveType: ActiveLiveType.BLINK,
          activeLivenessCheckCount: 1,
          minRam: 2,
          minCPUCores: 6
      
      )
      
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.assentifySdk = AssentifySdk(
                 apiKey: "QwWzzKOYLkDzCLJ9lENlgvRQ1kmkKDv76KbJ9sPfr9Joxwj2DUuzC7htaZP89RqzgB9i9lHc4IpYOA7g",
                 tenantIdentifier: "2937c91f-c905-434b-d13d-08dcc04755ec",
                 interaction: "E4BDD59C3B69A3F89AE8C756FCD67EBC72A45F405B256B3C3BDD643BE282B195",
                 environmentalConditions: self.environmentalConditions,
                 assentifySdkDelegate: self,
                 performActiveLivenessFace:  false,
             )
        
    }
    
    
    func onAssentifySdkInitError(message: String) {
            print("\(yellowColor)onAssentifySdkInitError:" , message)
        }
        
    func onAssentifySdkInitSuccess(configModel: ConfigModel) {
        print("\(yellowColor)onAssentifySdkInitSuccess:" )
        let  blockLoaderCustomProperties: [String: Any] = [:] ;
        let flowEnvironmentalConditions = FlowEnvironmentalConditions(
              backgroundType: .color,
              logoUrl: "https://image2url.com/r2/default/images/1769694393603-0afa5733-d9a5-4b0d-9134-868d3a750069.png",
//            svgBackgroundImageUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=patternA",
            textColor: "#000000",
            secondaryTextColor: "#ffffff",
            backgroundCardColor: "#f3f4f6",
            accentColor: "#ffc400",
            backgroundColor: .solid(hex: "#ffffff"),
            clickColor: .solid(hex: "#ffc400"),
          
//            language: Language.English,
//            enableNfc: true,
//            enableQr: true,
//            blockLoaderCustomProperties: blockLoaderCustomProperties
//              textColor:"000000",
//              secondaryTextColor: "#000000",
//              backgroundCardColor : "#F2F2F2",
//              accentColor : "#833F89",
//              backgroundColor: .solid(hex: "#ffffff"),
//              clickColor : .gradient(
//                colorsHex: ["#833F89", "#C82B47"],
//                angleDegrees: 0.0,
//                holdUntil : 0.6
//            ),
        )

        DispatchQueue.main.async {
            self.assentifySdk!.startFlow(from:self,flowDelegate: self,flowEnvironmentalConditions: flowEnvironmentalConditions)

        }
    }
    
    func onFlowCompleted(submitRequestModel: [SubmitRequestModel]) {
        print("\(yellowColor)onFlowCompleted: \(submitRequestModel)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


