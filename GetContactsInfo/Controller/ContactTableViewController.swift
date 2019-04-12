
import UIKit
import Contacts

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    
    
    @IBOutlet weak var ContactTableView: UITableView!
    
    
    var contactsList = [Contact]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // contacts = fetchContacts() as! [Contact]
        
        ContactTableView.delegate = self
        //ContactTableView.dataSource = fetchContacts() as? UITableViewDataSource
        //contactsList.append(Contact(name: "minh",phonenumber: "000",email: "gmail.com"))
        
       // fetchContacts()
        
    }
    
    override func viewWillAppear(_ animate: Bool){
        fetchContacts()
        print(contactsList)
        ContactTableView.reloadData()
    }

    
    
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
                                               email: contact.emailAddresses.first?.value as! String ?? "" as String)
                        
                        self.contactsList.append(contact)
                        
                        print(self.contactsList)
                        stopPointerIfYouWantToStopEnumerating.pointee = true
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

