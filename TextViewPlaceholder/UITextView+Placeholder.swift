//
//  UITextView+Placeholder.swift
//  TextViewPlaceholder
//
//  Created by apple on 19/03/2022.
//

import UIKit

// MARK: - Define properties

fileprivate var observerTextKey = "observerTextKey"
fileprivate var placeholderLabelKey = "placeholderLabelKey"
fileprivate var placeholderKey = "placeholderKey"
fileprivate var placeholderColorKey = "placeholderColorKey"
fileprivate var placeholderFontKey = "placeholderFontKey"

public extension UITextView {
    // MARK: - Public properties

    var placeholder: String? {
        get {
            if let value = objc_getAssociatedObject(self, &placeholderKey) as? String {
                return value
            }
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &placeholderKey, newValue, .OBJC_ASSOCIATION_COPY)
            if newValue.isEmpty {
                removePlaceholder()
                removeObserverText()
            } else {
                addPlaceholder(newValue)
                addObserverText()
            }
        }
    }

    var placeholderColor: UIColor? {
        get {
            if let value = objc_getAssociatedObject(self, &placeholderColorKey) as? UIColor {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &placeholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            placeholderLabel?.textColor = newValue
        }
    }

    var placeholderFont: UIFont? {
        get {
            if let value = objc_getAssociatedObject(self, &placeholderFontKey) as? UIFont {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &placeholderFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            placeholderLabel?.font = newValue
        }
    }

    // MARK: - Private properties

    fileprivate var placeholderLabel: UILabel? {
        get {
            if let label = objc_getAssociatedObject(self, &placeholderLabelKey) as? UILabel {
                return label
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &placeholderLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var observerText: ObserverTextView? {
        get {
            if let observer = objc_getAssociatedObject(self, &observerTextKey) as? ObserverTextView {
                return observer
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &observerTextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate func updateSizePlaceholder(newFrame: CGRect) {
        let padding = 2 * textContainer.lineFragmentPadding + textContainerInset.left + textContainerInset.right
        placeholderLabel?.frame.size.width = newFrame.width - padding
    }
}

private class ObserverTextView: NSObject {
    weak var _textView: UITextView!

    private let observerTextKeyPath = "text"
    private let observerFrameKeyPath = "Frame"

    init(textView: UITextView) {
        super.init()
        _textView = textView
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(notification:)), name: UITextView.textDidChangeNotification, object: nil)
        _textView.addObserver(self, forKeyPath: observerTextKeyPath, options: [.new], context: nil)
        _textView.addObserver(self, forKeyPath: observerFrameKeyPath, options: [.new], context: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        _textView.removeObserver(self, forKeyPath: observerTextKeyPath)
        _textView.removeObserver(self, forKeyPath: observerFrameKeyPath)
    }

    @objc func textViewDidChange(notification: Notification) {
        guard let textView = notification.object as? UITextView, _textView === textView else {
            return
        }
        if let text = textView.placeholder, textView.text.isEmpty {
            textView.addPlaceholder(text)
        } else {
            textView.removePlaceholder()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        switch keyPath {
        case observerTextKeyPath:
            if let newText = change?[NSKeyValueChangeKey.newKey] as? String, !newText.isEmpty {
                _textView.removePlaceholder()
            } else if let placeholder = _textView.placeholder {
                _textView.addPlaceholder(placeholder)
            }
        case observerFrameKeyPath:
            if let newFrame = change?[NSKeyValueChangeKey.newKey] as? CGRect {
                _textView.updateSizePlaceholder(newFrame: newFrame)
            }
        default: break
        }
    }
}

// MARK: - Handle add placeholder

fileprivate extension UITextView {
    func addObserverText() {
        observerText = ObserverTextView(textView: self)
    }

    func removeObserverText() {
        observerText = nil
    }

    func addPlaceholder(_ text: String) {
        guard self.text.isEmpty else { return }
        placeholderLabel?.removeFromSuperview()
        placeholderLabel = UILabel()
        guard let placeholderLabel = placeholderLabel else { return }
        placeholderLabel.text = text
        placeholderLabel.font = placeholderFont ?? font
        placeholderLabel.textColor = placeholderColor ?? textColor
        placeholderLabel.numberOfLines = 0
        let padding = 2 * textContainer.lineFragmentPadding + textContainerInset.left + textContainerInset.right
        let estimateSize = placeholderLabel.sizeThatFits(CGSize(width: frame.size.width - padding, height: frame.size.height))
        placeholderLabel.frame = CGRect(x: textContainer.lineFragmentPadding + textContainerInset.left, y: textContainerInset.top, width: estimateSize.width, height: estimateSize.height)
        addSubview(placeholderLabel)
        setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

    func removePlaceholder() {
        placeholderLabel?.removeFromSuperview()
    }
}
