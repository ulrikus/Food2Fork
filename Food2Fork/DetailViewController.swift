//
//  DetailViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var recipe: ListRecipe?
    var detailRecipe: DetailRecipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = recipe?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.foodWhite]
        
        self.tableView.backgroundColor = .foodBlack
        self.tableView.tableHeaderView = UIImageView()
        
        let methodParameters: [String: AnyObject] = [
            Constants.Food2ForkParameterKeys.RecipeId: recipe?.recipeId as AnyObject,
            Constants.Food2ForkParameterKeys.APIKey: Constants.Food2ForkParameterValues.APIKey as AnyObject
        ]
        getRecipeFromFood2Fork(methodParameters)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let recipeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        let imageURL = URL(string: (recipe?.imageUrlString)!)
        self.tableView.tableHeaderView = recipeImageView
        recipeImageView.contentMode = .scaleAspectFit
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    recipeImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Constants.StringLiterals.Ingredients
        case 1:
            return Constants.StringLiterals.PublisherName
        case 2:
            return Constants.StringLiterals.PublisherUrl
        default:
            return Constants.StringLiterals.F2FUrl
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return detailRecipe?.ingredients.count ?? 0
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .foodDarkBlack
        } else {
            cell.backgroundColor = .foodBlack
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.StringLiterals.ReuseCellIdentifier)!
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = detailRecipe?.ingredients[indexPath.row]
        case 1:
            cell.textLabel?.text = detailRecipe?.publisherName
        case 2:
            cell.textLabel?.text = detailRecipe?.publisherUrl
        default:
            cell.textLabel?.text = detailRecipe?.food2ForkUrlString
        }
        
        return cell
    }
    // MARK: Network request
    fileprivate func getRecipeFromFood2Fork(_ methodParameters: [String: AnyObject]) {
        
        // Create session and request
        let session = URLSession.shared
        let request = URLRequest(url: food2ForkSearchURLFromParameters(methodParameters))
        
        // Create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ error: String) {
                print(error)
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2XX.")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                displayError("No data was returned by the request.")
                return
            }
            
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                displayError("Could not parse the data as JSON.")
                return
            }
            
            // GUARD: Is the "recipe" key in out result?
            guard let recipe = parsedResult[Constants.Food2ForkResponseKeys.Recipe] as? [String: AnyObject] else {
                displayError("Cannot find keys '\(Constants.Food2ForkResponseKeys.Recipe)' in \(parsedResult).")
                return
            }
            
            guard let imageURLString = recipe[Constants.Food2ForkResponseKeys.ImageUrl] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.ImageUrl)'")
                return
            }
            guard let recipeId = recipe[Constants.Food2ForkResponseKeys.RecipeId] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.RecipeId)'")
                return
            }
            guard let sourceUrlString = recipe[Constants.Food2ForkResponseKeys.SourceUrl] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.SourceUrl)'")
                return
            }
            guard let f2fUrlString = recipe[Constants.Food2ForkResponseKeys.F2FUrl] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.F2FUrl)'")
                return
            }
            guard let publisherName = recipe[Constants.Food2ForkResponseKeys.PublisherName] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.PublisherName)'")
                return
            }
            guard let publisherUrl = recipe[Constants.Food2ForkResponseKeys.PublisherUrl] as? String else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.PublisherUrl)'")
                return
            }
            guard let socialRank = recipe[Constants.Food2ForkResponseKeys.SocialRank] as? Double else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.SocialRank)'")
                return
            }
            guard let ingredients = recipe[Constants.Food2ForkResponseKeys.Ingredients] as? [String] else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.Ingredients)'")
                return
            }
            guard let title = recipe[Constants.Food2ForkResponseKeys.Title] as? String, title != "" else {
                displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.Ingredients)'")
                return
            }
            
            let tempRecipe = DetailRecipe(recipeId: recipeId, title: title, imageUrlString: imageURLString, sourceUrlString: sourceUrlString, food2ForkUrlString: f2fUrlString, publisherName: publisherName, publisherUrl: publisherUrl, socialRank: socialRank, ingredients: ingredients)
            
            performUIUpdatesOnMain {
                self.detailRecipe = tempRecipe
                self.tableView.reloadData()
            }
        }
    
        // Start the task
        task.resume()
    }

    // MARK: Helper for Creating a URL from Parameters
    private func food2ForkSearchURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Food2Fork.APIScheme
        components.host = Constants.Food2Fork.APIHost
        components.path = Constants.Food2Fork.APIPathGet
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}

