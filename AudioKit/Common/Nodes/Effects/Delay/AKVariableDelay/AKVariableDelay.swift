//
//  AKVariableDelay.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A delay line with cubic interpolation.
///
/// - parameter input: Input node to process
/// - parameter time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
/// - parameter feedback: Feedback amount. Should be a value between 0-1.
///
public struct AKVariableDelay: AKNode {

    // MARK: - Properties

    /// Required property for AKNode
    public var avAudioNode: AVAudioNode

    internal var internalAU: AKVariableDelayAudioUnit?
    internal var token: AUParameterObserverToken?

    private var timeParameter: AUParameter?
    private var feedbackParameter: AUParameter?

    /// Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    public var time: Double = 1.0 {
        didSet {
            timeParameter?.setValue(Float(time), originator: token!)
        }
    }
    /// Feedback amount. Should be a value between 0-1.
    public var feedback: Double = 0.0 {
        didSet {
            feedbackParameter?.setValue(Float(feedback), originator: token!)
        }
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - parameter input: Input node to process
    /// - parameter time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    /// - parameter feedback: Feedback amount. Should be a value between 0-1.
    public init(
        _ input: AKNode,
        time: Double = 1.0,
        feedback: Double = 0.0) {

        self.time = time
        self.feedback = feedback

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x76646c61 /*'vdla'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKVariableDelayAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKVariableDelay",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKVariableDelayAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
        }

        guard let tree = internalAU?.parameterTree else { return }

        timeParameter             = tree.valueForKey("time")             as? AUParameter
        feedbackParameter         = tree.valueForKey("feedback")         as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.timeParameter!.address {
                    self.time = Double(value)
                } else if address == self.feedbackParameter!.address {
                    self.feedback = Double(value)
                }
            }
        }
        timeParameter?.setValue(Float(time), originator: token!)
        feedbackParameter?.setValue(Float(feedback), originator: token!)
    }
}
