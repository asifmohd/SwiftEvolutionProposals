//
//  ProposalDetailViewController.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 30/10/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import UIKit
import Down

class ProposalDetailViewController: UIViewController {
    
    var passedProposalObj: Proposal!
    let githubAPIInstance: GithubAPI = GithubAPI()
    @IBOutlet weak var proposalDetailView: UIView!
    weak var downView: DownView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupDownView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupDownViewConstraints() {
        
        guard let downView = self.downView else {
            return
        }
        if downView.constraints.count != 0 {
            // constraints have been added already
            return
        }
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": downView])
        self.proposalDetailView.addConstraints(heightConstraints)
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": downView])
        self.proposalDetailView.addConstraints(widthConstraints)
        
    }
    
    func setupDownView() {
        if let existingData = passedProposalObj.data as? Data,
            let markdownString = String(data: existingData, encoding: .utf8) {
            do {
                let downView = try DownView(frame: self.proposalDetailView.frame, markdownString: markdownString, openLinksInBrowser: true)
                downView.translatesAutoresizingMaskIntoConstraints = false
                self.proposalDetailView.addSubview(downView)
                self.downView = downView
                self.setupDownViewConstraints()
            }
            catch {
                print(error)
            }
        } else {
            githubAPIInstance.getDetailsOf(proposal: passedProposalObj, completionHandler: {
                DispatchQueue.main.async { [weak self] in
                    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    guard let passedProposalObj = self?.passedProposalObj else {
                        return
                    }
                    moc.refresh(passedProposalObj, mergeChanges: true)
                    guard let data = passedProposalObj.data as? Data,
                        let frame = self?.view.frame else {
                            return
                    }
                    guard let proposalMarkdownString = String(data: data, encoding: String.Encoding.utf8) else {
                        return
                    }
                    do {
                        let downView = try DownView(frame: frame, markdownString: proposalMarkdownString, openLinksInBrowser: true)
                        downView.translatesAutoresizingMaskIntoConstraints = false
                        self?.downView?.removeFromSuperview()
                        self?.proposalDetailView.addSubview(downView)
                        self?.downView = downView
                        self?.setupDownViewConstraints()
                    }
                    catch {
                        print(error)
                    }
                }
            })
        }
    }
    
    

}
