//
//  VariableInputTextView.swift
//  Variable-TextView-Keyboard-Accessory-Sample
//
//  Created by kawaharadai on 2020/05/10.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

protocol VariableInputTextViewDelegate: AnyObject {
    func didDrawView()
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
    private var currentTextViewHeight = CGFloat(0)
    private var maxTextViewHeight = CGFloat(0)
    private var minTextViewHeight = CGFloat(0)
    private var inputTextViewOriginalFrame: CGRect = .zero

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
        inputTextView.text = "　" // 適当な文字列を入れて設定フォントサイズ状況下でのFrameを確定させる
        let firstTextViewHeight = inputTextView.frame.height
        currentTextViewHeight = firstTextViewHeight // 初期Heightを記録
        minTextViewHeight = firstTextViewHeight // 初期Heightをminに
        maxTextViewHeight = firstTextViewHeight * 2.5 // 初期Heightの2.5倍の高さをmaxに
        inputTextViewOriginalFrame = inputTextView.frame
        adjustInputTextViewFrameWhenTextViewDidChangeIfNeeded()
        inputTextView.text = ""
        delegate?.didDrawView()
    }

    @IBAction func tappedOutputTextButton(sender: UIButton) {
        delegate?.tappedOutputButton(text: inputTextView.text) { [weak self] in
            self?.inputTextView.text = "　"
            self?.adjustInputTextViewFrameWhenTextViewDidChangeIfNeeded()
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

    private func adjustInputTextViewFrameWhenTextViewDidChangeIfNeeded() {
        let contentHeight = inputTextView.contentSize.height
        if minTextViewHeight <= contentHeight && contentHeight <= maxTextViewHeight {
            // 文字列のサイズに合わせる
            inputTextView.sizeToFit()
            inputTextView.isScrollEnabled = false
            let resizedHeight = inputTextView.frame.size.height
            // 前回サイズと変化ないならリターン
            guard resizedHeight != currentTextViewHeight else { return }
            // 変化ありならTextView自体のFrameを調節する
            inputTextViewHeightConstraint.constant = resizedHeight
            adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: resizedHeight)

            // 変化ありならContiner側のFrameも調節する
            if resizedHeight > currentTextViewHeight {
                let addingHeight = resizedHeight - currentTextViewHeight
                inputTextViewContainerHeightConstraint.constant += addingHeight
                currentTextViewHeight = resizedHeight
            } else {
                let subtractingHeight = currentTextViewHeight - resizedHeight
                inputTextViewContainerHeightConstraint.constant -= subtractingHeight
                currentTextViewHeight = resizedHeight
            }
        } else {
            // max超えてたら最大値を入れ続ける
            inputTextView.isScrollEnabled = true
            inputTextViewHeightConstraint.constant = currentTextViewHeight
            adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: currentTextViewHeight)
        }
    }

    private func adjustInputTextViewFrameWhenTextViewDidChange(variableHeight: CGFloat) {
        // 手動でレイアウトをいじっているため、ここでAutoLayoutで決められたサイズに戻す
        inputTextView.frame = CGRect(origin: inputTextViewOriginalFrame.origin,
                                     size: CGSize(width: inputTextViewOriginalFrame.width, height: variableHeight))
    }
}

extension VariableInputTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustInputTextViewFrameWhenTextViewDidChangeIfNeeded()
    }
}

