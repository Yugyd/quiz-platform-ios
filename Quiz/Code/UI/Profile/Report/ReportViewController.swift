//
//  Copyright 2024 Roman Likhachev
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

import UIKit
import MessageUI

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var msgTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBAction

    @IBAction func actionSend() {
        sendMessage()
    }

    @IBAction func actionCancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - MFMailComposeViewControllerDelegate - link func

    private func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private func

    private func sendMessage() {
        guard let msg = msgTextField.text else {
            return dismiss(animated: true, completion: nil)
        }

        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(StaticScope.mailSubject)
            mc.setMessageBody(msg, isHTML: false)
            mc.setToRecipients([StaticScope.mailAddress])

            present(mc, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ReportViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
