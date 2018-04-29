//
//  LoadMoreView.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class LoadMoreCell: UICollectionReusableView {
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var doneView: UIView!
    
    public func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LoadMoreCell", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return UIView() }
        return view
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }
    
    // MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }
    
    fileprivate func setupNib() {
        let view = self.loadNib()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:[], metrics:nil, views: bindings))
    }
}

extension LoadMoreCell {
  func load(_ load: Bool) {
        activityIndicatorView.isHidden = !load
        doneView.isHidden = load
    }
}


extension Reactive where Base: LoadMoreCell{
    var load: Binder<Bool>{
        return Binder(base) { (cell, load) in //자기자신, 불리언
            cell.load(load)
        }
    }
}







