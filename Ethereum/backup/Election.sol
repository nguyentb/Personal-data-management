pragma solidity 0.4.25;

contract Election {
    
  struct Candidate {
		uint id;
    string name;
    uint voteCount;
  }

  struct AuthLedger {
		string dataPointer;
		string dataHash;
		uint8 flag;
  }

	struct Dataset {
		uint datasetId;
		address owner;
		address sp;
		string dataPointer;
  }

	struct AclKeeper {
		address[] grantedAddr; //dynamic storage array
		uint grantCount;
	}

	struct AccessToken {
		address ownerID;
		//There is no need to consider SP's ID here as we use only one SP in the demonstration
		//address spID;
		address tpID; //thirdparty ID who requests to access data
		string dataHash;
		uint256 issued_at; //Unix timestamp
		uint operation; //1-create;3-read;5-update;7-delete and sum of the operations
		uint expired_in;
		uint refresh_count;
  }

  /* We consider only one Service provider, thus there is no need to add SP's Id */

    //mapping access control list for data owners
    mapping(address => mapping(address => uint8)) public aclists;

    // Auth_ledger
    mapping(address => AuthLedger) public auth_ledger;

		// Access Control List Keeper for keep track of granted third-parties
		//mapping(address => AclKeeper) public acl_keeper;
		mapping(address => address[]) public acl_keeper;
		mapping(address => uint) public acl_keeper_count;

    // Token_ledger
    // mapping(string => AccessToken) public token_ledger;

    // Store accounts that have voted
    mapping(address => bool) public voters;

    // Store Candidates
    // Fetch Candidate
    mapping(uint => Candidate) public candidates;
    // Store Candidates Count
    uint public candidatesCount;

		//AclKeeper aclkeeper_init;

    // voted event
    event votedEvent (
        uint indexed _candidateId
    );

    // Upload Data event
    event uploadDataEvent (
			address _address,
			string _dataPointer,
			string _dataHash
    );

		event grantAccessEvent(
			address _owner,
			address _thirdparty,
			uint8 _permission
		);

    constructor () public {
        addCandidate("Nguyen Truong");
        addCandidate("Kai Sun");
    }

    function addCandidate (string _name) private {
        candidatesCount ++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

  function uploadData (address _owner, string _dataPointer, string _dataHash) public {
		require(msg.sender == _owner);

		if(auth_ledger[_owner].flag == 1) { //owner has previously uploaded data
	    //update the ledger
	    auth_ledger[_owner].dataPointer = _dataPointer;
	    auth_ledger[_owner].dataHash = _dataHash;
		} else {
			//initiate the Access Control List	   
	    aclists[msg.sender][msg.sender] = 16; //provide all permissions to the data owner
	    auth_ledger[_owner] = AuthLedger(_dataPointer, _dataHash, 1);
		}
		//trigger uploadData event
		emit uploadDataEvent(_owner, _dataPointer, _dataHash);
  }

	function grantAccess (address _owner, address _thirdparty, uint8 _permission){
		require(msg.sender == _owner);
		require(auth_ledger[_owner].flag == 1); //owner have already uploaded data

		// update the acl_keeper		
		if (aclists[_owner][_thirdparty] > 0) { //thirdparty has already granted a permission)
			// no need to update the acl_keeper
		} else {			
			// update the acl_keeper to add the thirdparty to the list of granted account
			/*
			if (acl_keeper[_owner].grantCount > 0){ //AclKeeper record is already initialised for the _owner
				acl_keeper[_owner].grantedAddr.push(_thirdparty);
				acl_keeper[_owner].grantCount++;

			} else { //initialise the first record
				//Trick to create a dynamic storage array in a function

				//AclKeeper memory newaclkeeper;
				//acl_keeper[_owner] = newaclkeeper(new address[](0), 1);
				acl_keeper[_owner] = aclkeeper_init;
				//update the content
				acl_keeper[_owner].grantedAddr.push(_thirdparty);
				acl_keeper[_owner].grantCount = 1;
			}
			*/			
			acl_keeper[_owner].push(_thirdparty);
			if (acl_keeper_count[_owner] > 0) {
				acl_keeper_count[_owner] ++;
			} else {
				acl_keeper_count[_owner] = 1;
			}
		}

		//create or update the access control list
		aclists[_owner][_thirdparty] = _permission;
		emit grantAccessEvent(_owner, _thirdparty, _permission);
	}

  function vote (uint _candidateId) public {
		// require that they haven't voted before
    require(!voters[msg.sender]);
    // require a valid candidate
    require(_candidateId > 0 && _candidateId <= candidatesCount);

		// record that voter has voted
		voters[msg.sender] = true;
    // update candidate vote Count
    candidates[_candidateId].voteCount ++;
    // trigger voted event
    emit votedEvent(_candidateId);
    }
}
