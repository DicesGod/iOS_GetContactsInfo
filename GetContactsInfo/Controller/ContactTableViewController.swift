import MessageUI
import UIKit
import Contacts
import CoreData

weak var currentInstanceofContactTableViewController = ContactTableViewController()
let appDelegate = UIApplication.shared.delegate as? AppDelegate
var cellIndex = IndexPath()

class ContactTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var ContactTableView: UITableView!
    
    
    
    @IBAction func sendMessage(_ sender: Any) {
        displayMessageUI(index: cellIndex)
    }
    @IBAction func Search(_ sender: Any) {
        
    }
    var contactsList = [Contact]()
    //let [ContactTableViewController ]instanceofContactTableViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // contacts = fetchContacts() as! [Contact]
        fetchContacts()
        ContactTableView.delegate = self
        ContactTableView.dataSource = self
        currentInstanceofContactTableViewController = self
    }
    
//    override func viewWillAppear(_ animate: Bool){
//        fetchContacts()
//        print(contactsList)
//        ContactTableView.reloadData()
//    }
    
    func  fetchContacts(){
        fetchContacts(){
            (done) in
            if done{
                if self.contactsList.count > 0 {
                    print("Data loaded! xD")
                    
                }
            } else{
               print("Data not loaded! xD")
            }
        }
    }

    //A functioning table view requires three table view data source methods.
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        return cellIndex = indexPath
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ContactTableViewCell
        let contact = contactsList[indexPath.row]
        cell.contactName.text = contact.name
        cell.phoneNumber.text = contact.phonenumber
        cell.email.text = contact.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func fetchContacts(completion: @escaping (_ done: Bool) -> ()) {
        let store = CNContactStore()
        //var contactsList: [Contact] = []
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err{
                print("Fail to request access:",err)
                return
            }
            
            if granted{
                print("access granted")
                
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
          let contact  = Contact(name: contact.givenName+" "+contact.familyName,
                                 phonenumber: contact.phoneNumbers.first?.value.stringValue ?? "",
                                 email: contact.emailAddresses.first?.value as? String ?? "" as String)
                        
                        self.contactsList.append(contact)
                        
                        //print(self.contactsList)
                        //stopPointerIfYouWantToStopEnumerating.pointee = true
                        completion(true)
                    })
                    
                    
                }catch let err{
                    print("Failed to enumerate contact:",err)
                    completion(false)
                }
                
              
            }
            else{
                print("access denied")
                completion(false)
            }
        }
    }
}

extension ContactTableViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    func displayMessageUI(index: IndexPath){
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "My friend! Our class have a very cool app! Give it a try ;)";
        messageVC.recipients = [contactsList[index.row].name]
        //messageVC.recipients = ["minh"]
        messageVC.messageComposeDelegate = self
        if MFMessageComposeViewController.canSendText() {
            present(messageVC, animated: true, completion: nil)
        }
        else {
            print("Can't send messages.")
        }
    }
    
    // variable to store text typed by user in search box
//    var searchText: String = ""
//    @IBAction func Search(_ sender: Any) {
//        // getting value from search box
//        searchText = searchBoxText.text!
//        searchContacts()
//    }
    
    func searchContacts() -> [Contact]{
        
        var retSearchedContacts = [Contact]() // new array that will contain the searched result
        for contact in contactsList{
            if contact.name.lowercased().contains(searchText.lowercased()){
                retSearchedContacts.append(contact)
            }
        }
        return retSearchedContacts
    }
}


