//
//  ProposalListViewController.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 27/08/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

class ProposalListViewController: UIViewController {

    let activityIndicator: MBProgressHUD
    let GithubAPIInstance = GithubAPI()
    @IBOutlet weak var proposalsTableView: UITableView!
    let proposalsFRC: NSFetchedResultsController<Proposal>
    
    required init?(coder aDecoder: NSCoder) {
        activityIndicator = MBProgressHUD(frame: UIScreen.main.bounds)
        let fetchRequest = NSFetchRequest<Proposal>(entityName: "Proposal")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchBatchSize = 50
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        proposalsFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "proposalCache")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.show(animated: true)
        GithubAPIInstance.getListOfProposals { (proposalList) in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.hide(animated: true)
                self?.fetchResultsFromFRC()
                self?.proposalsTableView.reloadData()
            }
        }
        ProposalListTableViewCell.registerNibForTable(self.proposalsTableView)
        self.proposalsTableView.rowHeight = UITableViewAutomaticDimension
        self.proposalsTableView.estimatedRowHeight = 64.0
        
        self.fetchResultsFromFRC()
    }
    
    func fetchResultsFromFRC() {
        do {
            try self.proposalsFRC.performFetch()
        }
        catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let proposalObj = sender as? Proposal else {
            return
        }
        guard let destinationVC = segue.destination as? ProposalDetailViewController else {
            return
        }
        destinationVC.passedProposalObj = proposalObj
    }

}

extension ProposalListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedObjects = self.proposalsFRC.fetchedObjects else {
            return 0
        }
        return fetchedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProposalListTableViewCell.ReuseIdentifier, for: indexPath) as! ProposalListTableViewCell
        let aProposal = self.proposalsFRC.object(at: indexPath)
        cell.idLabel.text = aProposal.id.description
        cell.nameLabel.text = aProposal.displayName
        return cell
    }
    
}

extension ProposalListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let proposalObj = self.proposalsFRC.object(at: indexPath)
        self.performSegue(withIdentifier: "showProposalDetail", sender: proposalObj)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
