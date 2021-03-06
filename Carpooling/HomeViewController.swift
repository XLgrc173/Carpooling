//
//  HomeViewController.swift
//  Carpooling
//
//  Created by Sanjay Shrestha on 4/1/16.
//  Copyright © 2016 St Marys. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

// Without this the app wouldnt function, this connects to the back end of the App


class HomeViewController: UIViewController{
    
    
    @IBOutlet weak var ridesSegment: UISegmentedControl!
    
    @IBOutlet weak var open: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tempArray:NSMutableArray = [] //Trips.makeDummyTrips()
    
    var availaibleRideArray: NSMutableArray = []
    
    var imageToSend : UIImage?
    
    // fetch the trips from firebase and then update the tempArray
    
    func fetchTripList(ref: Firebase, rideArray: NSMutableArray)
    {
        ref.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            //if time has not passed, assign values and add to array
                let fromStreet = snapshot.value["fromStreet"] as? String
                let fromCity = snapshot.value["fromCity"] as? String
                let fromState = snapshot.value["fromState"] as? String
                let fromZipCode = snapshot.value["fromZipCode"] as? String
                let toStreet = snapshot.value["toStreet"] as? String
                let toCity = snapshot.value["toCity"] as? String
                let toState = snapshot.value["toState"] as? String
                let toZipCode = snapshot.value["toZipCode"] as? String
                let postedTime = snapshot.value["postedTime"] as? String
                let pickUpTime = snapshot.value["pickupTime"] as? String
                //if the pickup time has expired
                let notes = snapshot.value["notes"] as? String
                let capacity = snapshot.value["capacity"] as? String
                let elapsed = self.timeElapsed(postedTime!)
                let firstName = snapshot.value["first"] as? String
                let lastName = snapshot.value["last"] as? String
                let phoneNumber = snapshot.value["phone"] as? String
                let email = snapshot.value["email"] as? String
                //let picture = snapshot.value["image"] as? String
                let startingCapacity = snapshot.value["startingCapacity"] as? String
                let picture = "male"
                let postId = snapshot.value["postId"] as? String
            
                
                let r5: Rider = Rider(firstName: firstName!, lastName: lastName!, phoneNumber: phoneNumber!, email: email!, password: "39874", picture: picture)
                
                rideArray.addObject(Trips(rider: r5, fromStreetAddress: fromStreet!, fromCity: fromCity!, fromState: fromState!, fromZipCode: fromZipCode!, toStreetAddress: toStreet!, toCity: toCity!, toState: toState!, toZipCode: toZipCode!, pickUpTime: pickUpTime! , notes: notes!, postedTime: elapsed, capacity: capacity!, startingCapacity: startingCapacity!, postId: postId!))
                self.tableView.reloadData()
            // else nothing
        })
        print("temp array count is:  \(tempArray.count)")
        // These strings are the functions that allow the user to see where the desire location from start to the end location.
        
    }
    func convertBase64StringToUImage(baseString: String)-> UIImage {
        let decodedData = NSData(base64EncodedString: baseString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedimage = UIImage(data: decodedData!)
        //println(decodedimage)
        return decodedimage! as UIImage
        
    }
    override func viewWillAppear(animated: Bool) {
         self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchTripList(DataService.dataService.postRef, rideArray: tempArray)
        fetchTripList(DataService.dataService.requestRideRef, rideArray: availaibleRideArray)
        
       
        tableView.delegate = self
        tableView.dataSource = self
        
        if self.revealViewController() != nil {
           open.target = self.revealViewController()
            open.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.reloadData()
  
        
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calculates the time elapsed after a given time
    func timeElapsed(date: String)-> String{
        
        let dateformatter = NSDateFormatter()
        dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let postedDate  = dateformatter.dateFromString(date)!
       // print("posted date is  \(postedDate)")


        let elapsedTimeInSeconds = NSDate().timeIntervalSinceDate(postedDate)
       // print("Elapsed Time in Second  is  \(elapsedTimeInSeconds)")

        
        let secondInDays: NSTimeInterval = 60 * 60 * 24
       // print("Seconds in days is  \(secondInDays)")

        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateformatter.dateFormat = "MM/dd/yy"
         //   print("first if statement Time Elapsed")
            let timeToShow: String = dateformatter.stringFromDate(postedDate)
            return timeToShow

        } else if elapsedTimeInSeconds > secondInDays{
            dateformatter.dateFormat = "EEE"
           // print("first if statement Time Elapsed > secinds indays ")
            let timeToShow: String = dateformatter.stringFromDate(postedDate)
            return timeToShow


        } else if elapsedTimeInSeconds > secondInDays/60{
            let timeToshow = Int(elapsedTimeInSeconds/3600)

            return "\(timeToshow) hour ago"

        }
        else {
            let timeToshow = Int(elapsedTimeInSeconds/60)
            return "\(timeToshow) mins ago "
        }
    
    }
    
    @IBAction func changeView(sender: UISegmentedControl) {
        print("SegmentControl pressed")
        self.tableView.reloadData()
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
        if segue.identifier == "showDetailsSegue"{
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!

            let destinationVC = segue.destinationViewController as! DetailRideViewController
            destinationVC.rideDetail = tempArray[indexPath.row] as? Trips
            //vc.detailTrips = tempArray[indexPath.row] as! NSMutableArray
        }
        //if segue.identifier == "sendMailSegue"
        else if segue.identifier == "sendMailSegue"
        {
            print("before assignment")
            let vc = segue.destinationViewController as! SendMailViewController
            print("after assignment")
            print(vc.description)
            //self.dismissViewControllerAnimated(false, completion: nil)
            //presentViewController(vc, animated: true, completion: nil)
            //performSegueWithIdentifier("sendMailSegue", sender: self)
            //UIViewController.name
            //presentViewController("sendMail", animated: true, completion: nil)
            print("after present")
        }
 
    }
    
    /*
        else if segue.identifier == "GoogleMapViewToUserProfileView" {
            self.screenShotMethod()
            (segue.destinationViewController as! UserProfileViewController).userProfileViewBackgroundImage = self.userProfileViewBackgroundImage
        }
        else if segue.identifier == "awaitingConfirmView"{
            self.screenShotMethod()
            
            (segue.destinationViewController as! AwaitingConfirmationViewController).userProfileViewBackgroundImage = self.userProfileViewBackgroundImage
            
        }
    }
    */
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        switch ridesSegment.selectedSegmentIndex {
        case 0:
            returnValue = tempArray.count
            print("Case 0 in numberof sectionsin ")

        case 1:
            print("Case 1 in numberof sectionsin ")

            returnValue = availaibleRideArray.count
        default:
            break
        }
        return returnValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: AvailableRidesTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! AvailableRidesTableViewCell
        
        switch ridesSegment.selectedSegmentIndex {
        case 0:
            print("Case 0 in cellfor rowAtindex")
            let trip = tempArray[indexPath.row] as! Trips
            // Configure the cell...
            // let picture = convertBase64StringToUImage((trip.driver?.picture)!)
            
            cell.fullName.text = "\(trip.firstName) \(trip.lastName)"
            // cell.picture.image = picture
            cell.startAddress?.text = "Leaving \(trip.fromCity) to \(trip.toCity) \n on  \(trip.pickUpTime)  "
           // cell.endAddress?.text = "To: \(trip.toStreetAddress), \(trip.toCity), \(trip.toState), \(trip.toZipCode)  "
            cell.postedTime?.text = "Posted \(trip.postedTime)"
            cell.pickUpTime?.text = "On \(trip.pickUpTime)"
         //   cell.notes?.text = "Notes here \(trip.notes)"
            cell.capacity?.text = "Capacity: \(trip.capacity)"
            configureTableView()
        case 1:
            
            print("Case 1 in cell for row at index")
            let trip = availaibleRideArray[indexPath.row] as! Trips
            // Configure the cell...
            // let picture = convertBase64StringToUImage((trip.driver?.picture)!)
            
            cell.fullName.text = "\(trip.firstName) \(trip.lastName)"
            // cell.picture.image = picture
            cell.startAddress?.text = "Leaving from  \(trip.fromCity) to \(trip.toCity) \n on \(trip.pickUpTime)"
            //cell.endAddress?.text = "To: \(trip.toStreetAddress), \(trip.toCity), \(trip.toState), \(trip.toZipCode)  "
            cell.postedTime?.text = "Posted \(trip.postedTime)"
            cell.pickUpTime?.text = "On \(trip.pickUpTime)"
            //cell.notes?.text = "Notes here \(trip.notes)"
            cell.capacity?.text = "Capacity: \(trip.capacity)"
            configureTableView()

        default:
            break
        }
        
        
        
        return cell
    }
    
// when the user types the number of the cell on the app, these strings show to display that number. 
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //when selected do something
      //  let requestedRide = self.tempArray[indexPath.row] as! Trips
       // let sendImage: UIImage = requestedRide.
        switch ridesSegment.selectedSegmentIndex {
        case 0:
            self.performSegueWithIdentifier("showDetailsSegue", sender: nil)
            
        case 1:
            print("Case 1 in numberof sectionsin ")
            
            //returnValue = availaibleRideArray.count
        default:
            break
        }
        
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        switch ridesSegment.selectedSegmentIndex {
        case 0:
            let requestedRide = self.tempArray[indexPath.row] as! Trips
            let driver = "\(requestedRide.driver!.firstName) \(requestedRide.driver!.lastName)"
            print("Case 0 Actionsheet mail call text")
            let contactAction = UITableViewRowAction(style: .Normal, title: "Contact \(requestedRide.driver!.firstName)"){(action: UITableViewRowAction!, indexPath: NSIndexPath) -> Void in
                
                let contactAlertController = UIAlertController(title: "Contact  \(driver)", message: ":)", preferredStyle: .ActionSheet )
                
                let callAction = UIAlertAction(title: "Call the Driver", style: UIAlertActionStyle.Default){(action)-> Void in
                    
                    var url:NSURL = NSURL(string: "tel://+15103675660")!
                    UIApplication.sharedApplication().openURL(url)
                    //do stuff
                }
                let textAction = UIAlertAction(title: "Text", style: UIAlertActionStyle.Default){(action)-> Void in
                    //do stuff
                    
                    let msgVC = MFMessageComposeViewController()
                    msgVC.body = "Hello World"
                    msgVC.recipients = ["+15103675660"]
                    msgVC.messageComposeDelegate = self
                    self.presentViewController(msgVC, animated: true, completion: nil)
                }
                let emailAction = UIAlertAction(title: "Email", style: UIAlertActionStyle.Default){(action)-> Void in
                    //self.performSegueWithIdentifier("sendMailSegue", sender: nil)
                    //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: SendMailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("sendMail") as! SendMailViewController
                    let trip = self.tempArray[indexPath.row] as! Trips
                    vc.emailAddress = trip.email
                    self.presentViewController(vc, animated: true, completion: nil)

                    //do stuff
                    //segue to sendmailcontroller and send data or driver's email add thru segue
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default){(action)-> Void in
                    
                }
                contactAlertController.addAction(callAction)
                contactAlertController.addAction(textAction)
                contactAlertController.addAction(emailAction)
                contactAlertController.addAction(cancelAction)
                
                self.presentViewController(contactAlertController, animated: true, completion: nil)
                
            }
            let requestAction = UITableViewRowAction(style: .Normal, title: "Request Ride"){(action: UITableViewRowAction!, indexPath: NSIndexPath) -> Void in
                
                let requestAlertController = UIAlertController(title: nil, message: "Are you sure you want to request this ride?", preferredStyle: .ActionSheet)
                
                let requestAction = UIAlertAction(title: "Confirm Request", style: UIAlertActionStyle.Default){(action)-> Void in
                    self.tableView.reloadData()

                    //do stuff
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                requestAlertController.addAction(requestAction)
                requestAlertController.addAction(cancelAction)
                
                self.presentViewController(requestAlertController, animated: true, completion: nil)
                
            }
            
            contactAction.backgroundColor = UIColor.blackColor()
            print("ContactActionSheet")
            
            return [contactAction, requestAction]

            
        case 1:
            print("Case 1 in numberof sectionsin ")
            let GiveRideAction = UITableViewRowAction(style: .Normal, title: "Request Ride"){(action: UITableViewRowAction!, indexPath: NSIndexPath) -> Void in
                
                let giveRideAlertController = UIAlertController(title: nil, message: "Are you sure you want to give ride?", preferredStyle: .ActionSheet)
                
                let giveRideAction = UIAlertAction(title: "Confirm Request", style: UIAlertActionStyle.Default){(action)-> Void in
                    
                    self.tableView.reloadData()
                    //do stuff
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                giveRideAlertController.addAction(giveRideAction)
                giveRideAlertController.addAction(cancelAction)
                
                self.presentViewController(giveRideAlertController, animated: true, completion: nil)
                
            }
            return [GiveRideAction]
            
        default:
            break
        }
        return []
    }

    
    func actionSheet(){
        
    }
    
    
    func configureTableView(){
        tableView.rowHeight = 130.00
        
        
    }
}
extension HomeViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
        

    }
}



