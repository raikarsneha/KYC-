pragma solidity ^0.4.4;


contract kyc{
    
    
    address admin;
    
    constructor() public{
        admin=msg.sender;
    }
    
     modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
     //Struct customer
    //  uname - username of the customer
    //  data - customer data
    //  kycstatus - This is the status of the kyc request. 
    //  upvotes - number of upvotes recieved from banks
    //  downvotes - number of upvotes recieved from banks
    //  bank - address of bank that validated the customer account

    
    struct customer{
        string username;
        string data;
        bool kycstatus;
        uint upvotes;
        uint downvotes;
        address bank;
    }
        //  Struct Organisation
    //  name - name of the bank/organisation
    //  ethAddress - ethereum address of the bank/organisation
    //  report - rating based on number of valid/invalid verified accounts
    //  KYC_count - number of KYCs verified by the bank/organisation
    // kycPermission - This is a boolean to hold status of bank
    // regNumber - This is the registration number for the bank
    
    
    struct organisation{
        string name;
        address ethaddress;
        uint report;
        uint kyc_count;
        bool kycpermission;
        string regnumber;
        
    }
    
    struct Request{
        string username;
        address bankAddress;
        string customerdata;
    }
    
    customer[] allCustomers;

    //  list of all Banks/Organisations

    organisation[] allOrgs;


    Request[] allRequests;
    
    
    //Add Request - This function is used to add the KYC request to the requests list.
    
    function addRequest(string Uname, address bankAddress,string customerdata) public payable {
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].username, Uname) && allRequests[i].bankAddress == bankAddress &&  stringsEqual(allRequests[i].customerdata,customerdata)) {
                return;
            }
        }
        allRequests.length ++;
        allRequests[allRequests.length - 1] = Request(Uname, bankAddress, customerdata);
    }
     function stringsEqual(string storage _a, string memory _b) internal view returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
        {
			if (a[i] != b[i])
				return false;
        }
		return true;
	}
	
	 //  function to add a customer 
    //  returns 0 if successful
    //  returns 7 if inorganisation
    //  returns 1 if size limit of the database is reached
    //  returns 2 if customer already in network
	
 function addCustomer(string Uname, string DataHash) public payable returns(uint) {
        if(!inorganisation())
            return 7;
        //  throw error if username already in use
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname))
                return 2;
        }
        allCustomers.length ++;
        //  throw error if there is overflow in uint
        if(allCustomers.length < 1)
            return 1;
        allCustomers[allCustomers.length-1] = customer(Uname, DataHash, true,100, 0, msg.sender);
        updateRating(msg.sender,true);
        return 0;
    }
    
    function upvoteCustomer(string uname) public payable  returns(uint){
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, uname))
                allCustomers[i].upvotes++;
                return allCustomers[i].upvotes;
        }
    }
    function downvoteCustomer(string uname) public payable returns(uint){
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, uname))
                allCustomers[i].downvotes++;
                return allCustomers[i].downvotes;
        }
    }
    
    //  function to check access rights 

    
        function inorganisation() public payable returns(bool) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethaddress == msg.sender)
                return true;
        }
        return false;
    }
function updateRating(address bankAddress,bool ifAdded) public payable returns(uint) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethaddress == bankAddress) {
                //update rating
                if(ifAdded) {
                    allOrgs[i].kyc_count ++;
                   
                }
                else {
                      allOrgs[i].kyc_count--;
                    }
                
               
            }
        }
        //  throw error if bank not found
        return 0;
    }
    
     //  function to remove  customer 
    //  returns 0 if successful
    //  returns 7 if not in organisation
    //  returns 1 if customer profile not in database
    
     function removeCustomer(string Uname) public payable returns(uint) {
        if(!inorganisation())
            return 7;
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                address a = allCustomers[i].bank;
                for(uint j = i+1;j < allCustomers.length; ++ j) {
                    allCustomers[i-1] = allCustomers[i];
                }
                allCustomers.length --;
                updateRating(a,false);
                //  updateRating(msg.sender, true);
                return 0;
            }
        }
        //  throw error if uname not found
        return 1;
    }
     // function to return customer profile data
     function viewCustomer(string Uname) public payable returns(string) {
        if(!inorganisation())
            return "Access denied!";
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                return allCustomers[i].data;
            }
        }
        return "Customer not found in database!";
    }
    

    //  function to modify a customer profile in database
    //  returns 0 if successful
    //  returns 7 if not in organisation
    //  returns 1 if customer profile not in database

    
 function modifyCustomer(string Uname,string DataHash) public payable returns(uint) {
        if(!inorganisation())
            return 7;
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                allCustomers[i].data = DataHash;
                allCustomers[i].bank = msg.sender;
                return 0;
            }
        }
        //  throw error if uname not found
        return 1;
    }
     function getcustomerstatus(string Uname) public payable returns(bool) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname) ) {
                return true;
            }
            if(stringsEqual(allCustomers[i].username, Uname)) {
                return false;
            }
        }
        return false;
    }
     function Getbankdetails(address ethAcc) public payable returns(string) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethaddress == ethAcc) {
                return allOrgs[i].name;
            }
        }
        return "null";
    }
    function GetBankReport(address ethAcc) public payable returns(uint) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethaddress == ethAcc) {
                return allOrgs[i].report;
            }
        }
        return 0;
    }
     //  function that adds an organisation to the network
    //  returns 0 if successfull
    //  returns 7 if in organisation
    
     function addBank(string uname, address eth, string regNum) onlyAdmin public payable returns(uint) {
     
            allOrgs.length ++;
            allOrgs[allOrgs.length - 1] = organisation(uname, eth,0, 200, true, regNum);
            return 0;
       
    }
    
    
    //  function that removes an organisation from the network
    //  returns 0 if successful
    //  returns 1 if organisation to be removed not part of network

    
    function removeBank(address eth) onlyAdmin public payable returns(uint) {
        
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethaddress == eth) {
                for(uint j = i+1;j < allOrgs.length; ++ j) {
                    allOrgs[i-1] = allOrgs[i];
                }
                allOrgs.length --;
                return 0;
            }
        }
            
        return 1;
    }
    
    //
    function ModifybankkycPermission(address eth) onlyAdmin public payable{
    
        for(uint i=0;i < allOrgs.length;++i)
        {
            if(allOrgs[i].ethaddress == eth   &&  allOrgs[i].kycpermission==true)
            {
                allOrgs[i].kycpermission=false;
            }
           else
           {
               allOrgs[i].kycpermission=true;
           }
        }
        }
    

}