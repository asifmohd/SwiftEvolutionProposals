//
//  API.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 30/10/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct GithubAPI {
    
    func getListOfProposals(completionHandler: @escaping ((Void) -> Void)) {
        
        let proposalsUrl = URL(string: APIConstants.ProposalsURL)!
        let request = URLRequest(url: proposalsUrl,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
                                 timeoutInterval: APIConstants.TimeoutValue)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        
        
        let dataTask = session.dataTask(with: request,
                         completionHandler: { (responseData: Data?,
                            response: URLResponse?,
                            errorVal: Error?) in
                            guard let responseData = responseData else {
                                completionHandler()
                                return
                            }
                            var jsonError: NSError?
                            let proposalJSON = JSON(data: responseData,
                                            options: JSONSerialization.ReadingOptions.allowFragments,
                                            error: &jsonError)
                            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                            
                            for aProposal in proposalJSON.arrayValue {
                                guard let proposalName = aProposal["name"].string else {
                                    continue
                                }
                                var separatedName = proposalName.components(separatedBy: CharacterSet(charactersIn: "-."))
                                guard let proposalIdString = separatedName.first,
                                    let proposalId = Int64(proposalIdString) else {
                                    continue
                                }
                                separatedName.removeFirst()
                                separatedName.removeLast()
                                let displayName = separatedName.joined(separator: " ").uppercaseFirst
                                guard !displayName.isEmpty else {
                                    continue
                                }
                                guard let githubDownloadUrl = aProposal["download_url"].string else {
                                    continue
                                }
                                guard let fileSha = aProposal["sha"].string else {
                                    continue
                                }
                                
                                let fetchRequest: NSFetchRequest<Proposal> = Proposal.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "id = %d", argumentArray: [proposalId])
                                let proposalEntity: Proposal
                                do {
                                    if let existingProposal = try moc.fetch(fetchRequest).first {
                                        proposalEntity = existingProposal
                                    }
                                    else {
                                        proposalEntity = Proposal(context: moc)
                                    }
                                }
                                catch {
                                    print(error)
                                    proposalEntity = Proposal(context: moc)
                                }
                                
                                proposalEntity.githubName = proposalName
                                proposalEntity.displayName = displayName
                                proposalEntity.id = proposalId
                                proposalEntity.downloadUrl = githubDownloadUrl
                                proposalEntity.sha = fileSha
                            }
                            
                            do {
                                try moc.save()
                            }
                            catch {
                                print(error)
                            }
                            completionHandler()
        })
        dataTask.resume()
    }
    
    func getDetailsOf(proposal: Proposal, completionHandler: @escaping ((Void) -> Void)) {
        let proposalDetailUrl = URL(string: proposal.downloadUrl!)!
        let request = URLRequest(url: proposalDetailUrl,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
                                 timeoutInterval: APIConstants.TimeoutValue)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        
        
        let dataTask = session.dataTask(with: request,
                                        completionHandler: { (responseData: Data?,
                                            response: URLResponse?,
                                            errorVal: Error?) in
                                            guard let responseData = responseData else {
                                                completionHandler()
                                                return
                                            }
                                            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                                            
                                            let fetchRequest: NSFetchRequest<Proposal> = Proposal.fetchRequest()
                                            fetchRequest.predicate = NSPredicate(format: "id = %d", argumentArray: [proposal.id])
                                            do {
                                                if let existingProposal = try moc.fetch(fetchRequest).first {
                                                    existingProposal.data = responseData as NSData?
                                                    try moc.save()
                                                }
                                            }
                                            catch {
                                                print(error)
                                            }
                                            completionHandler()
        })
        dataTask.resume()
    }
    
}
