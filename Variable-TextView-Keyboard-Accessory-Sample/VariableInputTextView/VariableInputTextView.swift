//
//  VariableInputTextView.swift
//  Variable-TextView-Keyboard-Accessory-Sample
//
//  Created by kawaharadai on 2020/05/10.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

protocol VariableInputTextViewDelegate: AnyObject {
    func tappedOutputButton(text: String, _ completion: @escaping () -> ())
}

class VariableInputTextView: UIView {

    @IBOutlet weak private var inputTextView: UITextView! {
        didSet { inputTextView.delegate = self }
    }
    @IBOutlet weak private var inputTextViewContainer: UIView!
    @IBOutlet weak private var outputTextBotton: UIButton!
    @IBOutlet weak private var closeBotton: UIButton!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextViewContainerHeightConstraint: NSLayoutConstraint!

    weak var delegate: VariableInputTextViewDelegate?
    private var currentTextViewHeight: CGFloat = 33
    private let maxTextViewHeight: CGFloat = 80
    private let minTextViewHeight: CGFloat = 33

    static func make(frame: CGRect) -> VariableInputTextView {
        let view = UINib(nibName: "VariableInputTextView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! VariableInputTextView
        view.frame = frame
        return view
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 5
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        outputTextBotton.layer.masksToBounds = true
        outputTextBotton.layer.cornerRadius = 5
        closeBotton.layer.masksToBounds = true
        closeBotton.layer.cornerRadius = 5
        let topBorder = CALayer()
        topBorder.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: 1))
        topBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        inputTextViewContainer.layer.addSublayer(topBorder)
    }

    @IBAction func tappedOutputTextButton(sender: UIButton) {
        delegate?.tappedOutputButton(text: inputTextView.text) { [weak self] in
            self?.inputTextView.text = ""
            self?.endEditing(true)
        }
    }

    @IBAction func tappedOutputCloseButton(sender: UIButton) {
        endEditing(true)
    }

    @IBAction func tappedBackgroundView(_ sender: UITapGestureRecognizer) {
        endEditing(true)
    }

    func beginInputText() {
        inputTextView.becomeFirstResponder()
    }

    private func adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: CGFloat) {
        // IB側のinputTextViewに対する制約を再現する（一度autoLayoutを解除するため）
        inputTextView.frame = CGRect(x: 20, y: 15, width: self.frame.width - 40, height: variableHeight)
    }
}

extension VariableInputTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {

            }
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentHeight = inputTextView.contentSize.height
        if minTextViewHeight <= contentHeight && contentHeight <= maxTextViewHeight {
            inputTextView.translatesAutoresizingMaskIntoConstraints = true
            inputTextView.sizeToFit()
            inputTextView.isScrollEnabled = false
            let resizedHeight = inputTextView.frame.size.height
            inputTextViewHeightConstraint.constant = resizedHeight

            adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: resizedHeight)

            if resizedHeight > currentTextViewHeight {
                let addingHeight = resizedHeight - currentTextViewHeight
                inputTextViewContainerHeightConstraint.constant += addingHeight
                currentTextViewHeight = resizedHeight
            } else if resizedHeight < currentTextViewHeight {
                let subtractingHeight = currentTextViewHeight - resizedHeight
                inputTextViewContainerHeightConstraint.constant -= subtractingHeight
                currentTextViewHeight = resizedHeight
            }
        } else {
            inputTextView.isScrollEnabled = true
            inputTextViewHeightConstraint.constant = currentTextViewHeight
            adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: currentTextViewHeight)
        }
    }
}

