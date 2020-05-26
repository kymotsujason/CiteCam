//
//  GoogleBookService.swift
//  CiteCam
//
//  This file handles all networking activities.
//  ISBN gets translated into book information here.
//  Book information is formatted into a citation (APA Style).
//  That citation is then added to the citation list table view.
//
//  This file is also used for offline compatibility.
//  If we can't get the information, we store the ISBN for later use.
//  If we can get information, we delete the ISBN and add the information.
//
//  Main functions:
//  Retrieve book information related to the ISBN from Google Books API.
//  On failure to do so, either show error or store ISBN for later use.
//  Check if we can get information related to the stored ISBN, if so we update the citation table and delete the ISBN.
//
//  Created by Jason Yue on 2016-12-01.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON
import SCLAlertView

class GoogleBookService {
    
    // Static function for searching for book information related to an ISBN.
    static func bookSearch(isbn: String) -> Bool {
        
        // API link.
        let url = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        
        // Utilize Alamofire to request (GET) information from API about ISBN.
        Alamofire.request(url).responseJSON { response in
            
            // Variables
            var photo: UIImage?
            var cite = ""
            var authors = ""
            var publishedDates = ""
            var titles = ""
            var publishers = ""
            var imageURL = ""
            let whiteSpace = NSCharacterSet.whitespaces
            
            // If we get a JSON formatted result.
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                
                // If we can find an "items" section in the JSON result (book information starts here).
                if let items = json["items"].array
                {
                    if  let firstItem = items.first
                    {
                        
                        // If there's a title, assign it to a variable.
                        if let title = firstItem["volumeInfo","title"].string
                        {
                            titles = "\(title)."
                        } else {
                            titles = "."
                        }
                        
                        // If there's an author, put last name first and take first letter of middle or first names.
                        if let author = firstItem["volumeInfo","authors"].array
                        {
                            
                            // Ensure that we have something
                            if (!author.isEmpty) {
                                for element in author {
                                    
                                    // Seperate into an array by whitespace (space).
                                    var tmp = "\(element)".components(separatedBy: " ")
                                    var firstName = ""
                                    
                                    // If there are 2 or more authors.
                                    if  (!"\(element)".trimmingCharacters(in: whiteSpace).isEmpty) {
                                        
                                        // Take first letter of first and middle name and string them together.
                                        for i in 0...tmp.count-2 {
                                            firstName += " " + tmp[i][tmp[i].startIndex..<tmp[i].index(after: tmp[i].startIndex)] + "."
                                        }
                                    } else {
                                        firstName = " \(element)"
                                    }
                                    
                                    // Add the first and middle name after last name (reverse order).
                                    authors += "\(tmp[tmp.count-1])\(firstName),"
                                }
                                
                                // Replace comma with period (due our method).
                                authors = authors.substring(to: authors.index(before: authors.index(authors.endIndex, offsetBy: -1)))
                                authors += "."
                            } else {
                                authors = "."
                            }
                        } else {
                            authors = "."
                        }
                        
                        // If there's a publisher.
                        if let publisher = firstItem["volumeInfo","publisher"].string
                        {
                            publishers = "\(publisher)."
                        } else {
                            publishers = "."
                        }
                        
                        // If there's a published date, only get the year.
                        if let publishedDate = firstItem["volumeInfo","publishedDate"].string
                        {
                            
                            // Seperate into an array by "-" which means there's a day and month in the date.
                            let tmp = "\(publishedDate)".components(separatedBy: "-")
                            for element in tmp {
                                
                                // Only get the year.
                                if (element.characters.count == 4) {
                                    publishedDates = "(\(element))."
                                }
                            }
                        } else {
                            publishedDates = "."
                        }
                        
                        // If there a thumbnail/preview image, assign the URL to a variable.
                        // Otherwise, use stock picture.
                        if let smallThumbnailURL = firstItem["volumeInfo","imageLinks","smallThumbnail"].string
                        {
                            imageURL = "\(smallThumbnailURL)"
                        } else {
                            photo = UIImage(named: "image1")!
                        }
                        
                        // In the event we have an thumbnail/preview image, download it and set it as the picture.
                        // Otherwise, set the stock picture.
                        Alamofire.request(imageURL).responseImage { response in
                            
                            // If we have a downloaded image.
                            if let image = response.result.value {
                                photo = image
                                
                                // APA Format citation.
                                cite = "\(authors) \(publishedDates) \(titles) \(publishers)"
                                print("\(cite)")
                                
                                // Add citation to citation list table.
                                CitationTableViewController.addCitation(name: cite, photo: photo!)
                                
                                // Alert user on success.
                                SCLAlertView().showSuccess("Citation Generated!", subTitle: cite, closeButtonTitle: "Okay!", duration: 6, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF)
                            } else {
                                
                                // APA Format citation.
                                cite = "\(authors) \(publishedDates) \(titles) \(publishers)"
                                
                                // Add citation to citation list table.
                                CitationTableViewController.addCitation(name: cite, photo: photo!);
                                
                                // Alert user on success.
                                SCLAlertView().showSuccess("Citation Generated!", subTitle: cite, closeButtonTitle: "Okay!", duration: 6, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF)
                            }
                        }
                    }
                } else {
                    
                    // If we were unable to generate a citation, tell the user.
                    // Most likely occurs if we have an invalid isbn or non-novel isbn (ie. textbooks).
                    SCLAlertView().showError("Generator failed!", subTitle: "Unable to generate citation. Information does not exist using our API.")
                }
            }
            
            // In the case we could not get a response, save the ISBN to try again later.
            if(response.result.isFailure) {
                
                // Tell the user there is no internet.
                SCLAlertView().showError("No Internet!", subTitle: "Unable to generate citation, this application requires internet! Saving ISBN for next launch with internet access...")
                
                // Save ISBN.
                CitationTableViewController.addISBN(code: isbn)
            }
        }
        return true
    }
    
    // Check if there's internet, if so we can convert all saved ISBNs and empty the ISBN list.
    static func checkInternet(isbn: String) {
        
        // API link.
        let url = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        
        // Send a GET request to attempt to get a result back.
        Alamofire.request(url).responseJSON { response in
            
            // If succesful, begin translating all ISBN into citations and removing the ISBN from the list.
            if(response.result.isSuccess) {
                var done = false
                while(!done) {
                    done = GoogleBookService.bookSearch(isbn: CitationTableViewController.isbn[0].isbn)
                }
                CitationTableViewController.isbn.remove(at: 0)
                CitationTableViewController.saveISBN()
            }
        }
    }
}
