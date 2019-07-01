pragma solidity 0.4.25;

contract Election {
    
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

	struct Acl {
		uint8 permission;
		bytes32 token;
	}

	struct AccessToken {
		//There is no need to consider SP's ID here as we use only one SP in the demonstration
		address ownerID;
		address tpID; //thirdparty ID who requests to access data
		//string dataHash
		uint permission; //1-create;2-read;4-update;8-delete and sum of the operations
		uint256 issued_at; //Unix timestamp
		uint expired_in;
		uint refresh_count;
		bool validity;
  }

  /* We consider only one Service provider, thus there is no need to add SP's Id */

    //mapping access control list for data owners
    mapping(address => mapping(address => Acl)) public aclists;
		
		//mapping AccessToken for data owners
		mapping(bytes32 => AccessToken) public tokenlist;

    // Auth_ledger
    mapping(address => AuthLedger) public auth_ledger;

		// Access Control List Keeper for keep track of granted third-parties
		//mapping(address => AclKeeper) public acl_keeper;
		mapping(address => address[]) public acl_keeper;
		mapping(address => uint) public acl_keeper_count;

    // Token_ledger
    // mapping(string => AccessToken) public token_ledger;

		uint public blockNumber;
		bytes32 public blockHashNow;

    // Upload Data event
    event uploadDataEvent (
			address _address,
			string _dataPointer,
			string _dataHash
    );

		event grantAccessEvent(
			bytes32 token
		);

    constructor () public {
    }

  function uploadData (address _owner, string _dataPointer, string _dataHash) public {
		require(msg.sender == _owner);

		if(auth_ledger[_owner].flag == 1) { //owner has previously uploaded data
	    //update the ledger
	    auth_ledger[_owner].dataPointer = _dataPointer;
	    auth_ledger[_owner].dataHash = _dataHash;
		} else {
			//initiate the Access Control List
	    //aclists[msg.sender][msg.sender] = Acl(16, ); //provide all permissions to the data owner
			//token = keccak256(abi.encodePacked(_owner, _thirdparty, blockHashNow));

	    auth_ledger[_owner] = AuthLedger(_dataPointer, _dataHash, 1);
		}
		//trigger uploadData event
		emit uploadDataEvent(_owner, _dataPointer, _dataHash);
  }

	function grantAccess (address _owner, address _thirdparty, uint8 _permission) public {
		require(msg.sender == _owner);
		require(auth_ledger[_owner].flag == 1); //owner have already uploaded data

		bytes32 token;

		// update the acl_keeper		
		if (aclists[_owner][_thirdparty].permission > 0) { //thirdparty has already granted a permission -> update new permission
			// no need to update the acl_keeper
			// retrieve the Access Token
			token = aclists[_owner][_thirdparty].token;
			if (aclists[_owner][_thirdparty].permission != _permission){
				//update new permission
				aclists[_owner][_thirdparty].permission = _permission;
				tokenlist[token].permission = _permission;
			}

		} else {
			// update the acl_keeper to add the thirdparty to the list of granted account
			//update acl_keeper ledger
			acl_keeper[_owner].push(_thirdparty);
			
			if (acl_keeper_count[_owner] > 0) {
				acl_keeper_count[_owner] ++;
			} else {
				acl_keeper_count[_owner] = 1;
			}
			
			//create token
			blockNumber = block.number;
			blockHashNow = blockhash(blockNumber);
			token = keccak256(abi.encodePacked(_owner, _thirdparty, blockHashNow));
			//create a pseudo-random access token with associated information
			tokenlist[token] = AccessToken(_owner, _thirdparty, _permission, block.timestamp, 3000, 1, true);
			
			//create aclists record
			aclists[_owner][_thirdparty] = Acl(_permission, token);
		}

		//create or update permission
		//aclists[_owner][_thirdparty] = _permission;
		emit grantAccessEvent(token);
	}

	function validateAccess(address _callerId, bytes32 _token) public {
		require(msg.sender == _callerId);
		require(tokenlist[_token].validity == true);

	}
}
