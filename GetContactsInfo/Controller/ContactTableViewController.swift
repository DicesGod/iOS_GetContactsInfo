import MessageUI
import UIKit
import Contacts
import CoreData

weak var currentInstanceofContactTableViewController = ContactTableViewController()
let appDelegate = UIApplication.shared.delegate as? AppDelegate
var cellIndex = IndexPath()

class ContactTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var ContactTableView: UITableView!
    
    @IBOutlet weak var searchText: UITextField!
    
    var contactsListFull = [Contact]()
    var seachedcontactsList = [Contact]()
    
    @IBAction func MenuTapped(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @IBAction func searchContacts(_ sender: UITextField) {
            seachedcontactsList.removeAll()
            seachedcontactsList = searchContacts(searchText: searchText.text ?? "",contactsList: contactsListFull)
            ContactTableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ContactTableView.delegate = self
        ContactTableView.dataSource = self
        currentInstanceofContactTableViewController = self
    }
    
    func searchContacts(searchText: String, contactsList: [Contact]) -> [Contact]{
        if (searchText == ""){
            return contactsListFull
        }
        else{
            var searchedcontactsListFull = [Contact]() // new array that will contain the searched result
            for contact in contactsListFull{
                if contact.name.lowercased().contains(searchText.lowercased()){
                    searchedcontactsListFull.append(contact)
                }
            }
            return searchedcontactsListFull
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        displayMessageUI(index: cellIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // contacts = fetchContacts() as! [Contact]
        fetchContacts()
        seachedcontactsList = contactsListFull
        ContactTableView.delegate = self
        ContactTableView.dataSource = self
        currentInstanceofContactTableViewController = self
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showDepartment),
                                               name: NSNotification.Name("ShowDepartment"),
                                               object: nil)
    }
    
    @objc func showDepartment() {
        performSegue(withIdentifier: "ShowDepartment", sender: nil)
    }
    
    
    func  fetchContacts(){
        fetchContacts(){
            (done) in
            if done{
                if self.contactsListFull.count > 0 {
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
        return seachedcontactsList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        return cellIndex = indexPath
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ContactTableViewCell
        let contact = seachedcontactsList[indexPath.row]
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
                        
                        self.contactsListFull.append(contact)
                        //print(self.contactsListFull)
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

//Send massage
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
        messageVC.recipients = [contactsListFull[index.row].name]
        //messageVC.recipients = ["minh"]
        messageVC.messageComposeDelegate = self
        if MFMessageComposeViewController.canSendText() {
            present(messageVC, animated: true, completion: nil)
        }
        else {
            print("Can't send messages.")
        }
    }
}


