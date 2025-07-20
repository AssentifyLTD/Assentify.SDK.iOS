//
//  ScanNfcDelegate.swift
//  Pods
//
//  Created by TariQ on 20/07/2025.
//

@objc public protocol ScanNfcDelegate{
  func onStartNfcScan()
  func onCompleteNfcScan(dataModel: PassportResponseModel)
  func onErrorNfcScan(dataModel: PassportResponseModel,message: String)
}
