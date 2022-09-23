/*
  Copyright (C) 2022 Marvin Häuser. All rights reserved.
  SPDX-License-Identifier: BSD-3-Clause
*/

import Cocoa
import os.log

final class CommandsMenuDelegate: NSObject, NSMenuDelegate {
    @IBOutlet var infoUnknownStateItem: NSMenuItem!

    @IBOutlet var infoPowerAdapterEnabledItem: NSMenuItem!
    @IBOutlet var infoPowerAdapterDisabledItem: NSMenuItem!

    @IBOutlet var infoChargingToMaximumItem: NSMenuItem!
    @IBOutlet var infoChargingToFullItem: NSMenuItem!
    @IBOutlet var infoChargingUnknownModeItem: NSMenuItem!

    @IBOutlet var infoNotChargingItem: NSMenuItem!
    @IBOutlet var infoRequestedChargingToMaximumItem: NSMenuItem!
    @IBOutlet var infoRequestedChargingToFullItem: NSMenuItem!
    @IBOutlet var infoNotChargingUnknownModeItem: NSMenuItem!

    @IBOutlet var disablePowerAdapterItem: NSMenuItem!
    @IBOutlet var enablePowerAdapterItem: NSMenuItem!

    @IBOutlet var chargeToFullNowItem: NSMenuItem!
    @IBOutlet var chargeToMaximumNowItem: NSMenuItem!
    @IBOutlet var disableChargingItem: NSMenuItem!

    @IBOutlet var requestChargingToFullItem: NSMenuItem!
    @IBOutlet var requestChargingToMaximumItem: NSMenuItem!
    @IBOutlet var cancelChargingRequestItem: NSMenuItem!

    private var refreshTimer: DispatchSourceTimer? = nil

    @MainActor private func refresh() {
        BatteryToolkit.getState { (state) -> Void in
            DispatchQueue.main.async {
                let powerNum        = state[BTStateInfo.Keys.power] as? NSNumber
                let connectedNum    = state[BTStateInfo.Keys.connected] as? NSNumber
                let chargingNum     = state[BTStateInfo.Keys.charging] as? NSNumber
                let progressNum     = state[BTStateInfo.Keys.progress] as? NSNumber
                let chargingModeNum = state[BTStateInfo.Keys.chargingMode] as? NSNumber

                guard let power        = powerNum?.boolValue,
                      let connected    = connectedNum?.boolValue,
                      let charging     = chargingNum?.boolValue,
                      let progress     = progressNum?.intValue,
                      let chargingMode = chargingModeNum?.intValue else {

                    self.infoPowerAdapterDisabledItem.isHidden       = true
                    self.infoPowerAdapterEnabledItem.isHidden        = true
                    self.infoChargingToMaximumItem.isHidden          = true
                    self.infoChargingToFullItem.isHidden             = true
                    self.infoChargingUnknownModeItem.isHidden        = true
                    self.infoNotChargingItem.isHidden                = true
                    self.infoRequestedChargingToMaximumItem.isHidden = true
                    self.infoRequestedChargingToFullItem.isHidden    = true
                    self.infoNotChargingUnknownModeItem.isHidden     = true
                    self.infoUnknownStateItem.isHidden               = false

                    self.disablePowerAdapterItem.isHidden      = true
                    self.enablePowerAdapterItem.isHidden       = true
                    self.chargeToFullNowItem.isHidden          = true
                    self.chargeToMaximumNowItem.isHidden       = true
                    self.requestChargingToFullItem.isHidden    = true
                    self.requestChargingToMaximumItem.isHidden = true
                    self.disableChargingItem.isHidden          = true
                    self.cancelChargingRequestItem.isHidden    = true

                    return
                }

                self.infoUnknownStateItem.isHidden = true

                if power {
                    self.infoPowerAdapterDisabledItem.isHidden = true
                    self.infoPowerAdapterEnabledItem.isHidden  = false

                    self.enablePowerAdapterItem.isHidden  = true
                    self.disablePowerAdapterItem.isHidden = false
                } else {
                    self.infoPowerAdapterEnabledItem.isHidden  = true
                    self.infoPowerAdapterDisabledItem.isHidden = false

                    self.disablePowerAdapterItem.isHidden = true
                    self.enablePowerAdapterItem.isHidden  = false
                }

                if charging {
                    self.infoNotChargingItem.isHidden                = true
                    self.infoRequestedChargingToMaximumItem.isHidden = true
                    self.infoRequestedChargingToFullItem.isHidden    = true
                    self.infoNotChargingUnknownModeItem.isHidden     = true

                    switch chargingMode {
                        case Int(BTStateInfo.ChargingMode.standard.rawValue),
                            Int(BTStateInfo.ChargingMode.toMaximum.rawValue):
                            self.infoChargingToFullItem.isHidden      = true
                            self.infoChargingUnknownModeItem.isHidden = true
                            self.infoChargingToMaximumItem.isHidden   = false

                        case Int(BTStateInfo.ChargingMode.toFull.rawValue):
                            self.infoChargingToMaximumItem.isHidden   = true
                            self.infoChargingUnknownModeItem.isHidden = true
                            self.infoChargingToFullItem.isHidden      = false

                        default:
                            os_log("Unknown charging mode: \(chargingMode)")
                            self.infoChargingToMaximumItem.isHidden   = true
                            self.infoChargingToFullItem.isHidden      = true
                            self.infoChargingUnknownModeItem.isHidden = false
                    }
                } else {
                    self.infoChargingToMaximumItem.isHidden   = true
                    self.infoChargingToFullItem.isHidden      = true
                    self.infoChargingUnknownModeItem.isHidden = true

                    self.chargeToFullNowItem.isHidden    = true
                    self.chargeToMaximumNowItem.isHidden = true

                    switch chargingMode {
                        case Int(BTStateInfo.ChargingMode.standard.rawValue):
                            self.infoRequestedChargingToMaximumItem.isHidden = true
                            self.infoRequestedChargingToFullItem.isHidden    = true
                            self.infoNotChargingUnknownModeItem.isHidden     = true
                            self.infoNotChargingItem.isHidden                = false

                        case Int(BTStateInfo.ChargingMode.toMaximum.rawValue):
                            self.infoNotChargingItem.isHidden                = true
                            self.infoRequestedChargingToFullItem.isHidden    = true
                            self.infoNotChargingUnknownModeItem.isHidden     = true
                            self.infoRequestedChargingToMaximumItem.isHidden = false

                        case Int(BTStateInfo.ChargingMode.toFull.rawValue):
                            self.infoNotChargingItem.isHidden                = true
                            self.infoRequestedChargingToMaximumItem.isHidden = true
                            self.infoNotChargingUnknownModeItem.isHidden     = true
                            self.infoRequestedChargingToFullItem.isHidden    = false

                        default:
                            os_log("Unknown charging mode: \(chargingMode)")
                            self.infoNotChargingItem.isHidden                = true
                            self.infoRequestedChargingToMaximumItem.isHidden = true
                            self.infoRequestedChargingToFullItem.isHidden    = true
                            self.infoNotChargingUnknownModeItem.isHidden     = false
                    }
                }

                let chargeBelowMax  = progress <= BTStateInfo.ChargingProgress.belowMax.rawValue
                let chargeBelowFull = progress <= BTStateInfo.ChargingProgress.belowFull.rawValue

                if connected {
                    self.requestChargingToFullItem.isHidden    = true
                    self.requestChargingToMaximumItem.isHidden = true
                    self.cancelChargingRequestItem.isHidden    = true
                    self.disableChargingItem.isHidden          = !charging

                    switch chargingMode {
                        case Int(BTStateInfo.ChargingMode.standard.rawValue),
                            Int(BTStateInfo.ChargingMode.toMaximum.rawValue):
                            self.chargeToMaximumNowItem.isHidden = charging || !chargeBelowMax
                            self.chargeToFullNowItem.isHidden    = !chargeBelowFull

                        case Int(BTStateInfo.ChargingMode.toFull.rawValue):
                            self.chargeToFullNowItem.isHidden    = true
                            self.chargeToMaximumNowItem.isHidden = !chargeBelowMax

                        default:
                            self.chargeToFullNowItem.isHidden    = !chargeBelowFull
                            self.chargeToMaximumNowItem.isHidden = !chargeBelowMax
                    }
                } else {
                    self.chargeToFullNowItem.isHidden    = true
                    self.chargeToMaximumNowItem.isHidden = true
                    self.disableChargingItem.isHidden    = true

                    switch chargingMode {
                        case Int(BTStateInfo.ChargingMode.standard.rawValue):
                            self.cancelChargingRequestItem.isHidden    = true
                            self.requestChargingToFullItem.isHidden    = !chargeBelowFull
                            self.requestChargingToMaximumItem.isHidden = !chargeBelowMax

                        case Int(BTStateInfo.ChargingMode.toMaximum.rawValue):
                            self.requestChargingToMaximumItem.isHidden = true
                            self.requestChargingToFullItem.isHidden    = !chargeBelowFull
                            self.cancelChargingRequestItem.isHidden    = false

                        case Int(BTStateInfo.ChargingMode.toFull.rawValue):
                            self.requestChargingToFullItem.isHidden    = true
                            self.requestChargingToMaximumItem.isHidden = !chargeBelowMax
                            self.cancelChargingRequestItem.isHidden    = false

                        default:
                            self.requestChargingToFullItem.isHidden    = !chargeBelowFull
                            self.requestChargingToMaximumItem.isHidden = !chargeBelowMax
                            self.cancelChargingRequestItem.isHidden    = false
                    }
                }
            }
        }
    }

    @MainActor func menuWillOpen(_ menu: NSMenu) {
        assert (self.refreshTimer == nil)

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.setEventHandler {
            self.refresh()
        }
        timer.schedule(deadline: .now(), repeating: 5)
        timer.resume()
        self.refreshTimer = timer
    }

    func menuDidClose(_ menu: NSMenu) {
        assert(self.refreshTimer != nil)

        self.refreshTimer!.cancel()
        self.refreshTimer = nil
    }

    @IBAction private func disablePowerAdapterHandler(sender: NSMenuItem) {
        BatteryToolkit.disablePowerAdapter(reply: BTCompletionHandlers.commandError)
    }

    @IBAction private func enablePowerAdapterHandler(sender: NSMenuItem) {
        BatteryToolkit.enablePowerAdapter(reply: BTCompletionHandlers.commandError)
    }

    @IBAction private func chargeToMaximumHandler(sender: NSMenuItem) {
        BatteryToolkit.chargeToMaximum(reply: BTCompletionHandlers.commandError)
    }

    @IBAction private func chargeToFullHandler(sender: NSMenuItem) {
        BatteryToolkit.chargeToFull(reply: BTCompletionHandlers.commandError)
    }

    @IBAction private func disableChargingHandler(sender: NSMenuItem) {
        BatteryToolkit.disableCharging(reply: BTCompletionHandlers.commandError)
    }
}
