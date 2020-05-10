//
//  ViewController.swift
//  Variable-TextView-Keyboard-Accessory-Sample
//
//  Created by kawaharadai on 2020/05/10.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var outputResultLabel: UILabel!
    private var inputTextView: VariableInputTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // VariableInputTextViewを生成して画面外に置いておく
        inputTextView = VariableInputTextView.make(frame: CGRect(origin: CGPoint(x: 0, y: view.bounds.height),
                                                                 size: view.bounds.size))
        inputTextView.delegate = self
        view.addSubview(inputTextView)
        // キーボードに合わせてVariableInputTextViewを上げ下げ
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        outputResultLabel.layer.borderWidth = 1
        outputResultLabel.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func tappedActionButton(_ sender: UIButton) {
        inputTextView.beginInputText()
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveValue)  else {
                return
        }

        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) { [unowned self] in
            self.inputTextView.transform = CGAffineTransform(translationX: 0, y: -(keyboardFrame.height + self.inputTextView.frame.height))
        }
        animator.startAnimation()
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveValue)  else {
                return
        }

        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) { [unowned self] in
            self.inputTextView.transform = .identity
        }
        animator.startAnimation()
    }
}

extension ViewController: VariableInputTextViewDelegate {
    func tappedOutputButton(text: String, _ completion: @escaping () -> ()) {
        outputResultLabel.text = text
        completion()
    }
}
