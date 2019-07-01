App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Election.json", function(election) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Election = TruffleContract(election);
      // Connect provider to interact with contract
      App.contracts.Election.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Election.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.grantAccessEvent({}, {
        fromBlock: 'latest',
        toBlock: 'latest'
      }).watch(function(error, event) {      
        console.log("event triggered", event)
        //alert(event.args.token);
        // Reload
        //App.render();
      });
      
    });
  },

  render: function() {
    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html(account);        
      }      
    });
    
    // Load contract data
    App.contracts.Election.deployed().then(function(instance) {
      //electionInstance = instance;
      instance.auth_ledger(App.account).then(function(auth_ledger) {
		var dataInfo = $("#datainfo");
		dataInfo.empty();
		  
	  	var dpointer = auth_ledger[0];
	  	var dhash = auth_ledger[1];
	  	var flag = auth_ledger[2];
		  
	  	//render data information
	  	var infoTemplate = "<tr><th>" + flag + "</th><td>" + dpointer + "</td><td>" + dhash + "</td></tr>"
	  	dataInfo.append(infoTemplate);
      });
      
 	  instance.acl_keeper_count(App.account).then(function(acl_count) {
       	//render auth_ledger information for the current account
	  	var aclInfo = $("#aclinfo");
	  	aclInfo.empty();
	  	var j=0;
	    for (var i = 0; i < acl_count; i++) {
	    	instance.acl_keeper(App.account, i).then(function(tpaddr) {
	    		instance.aclists(App.account, tpaddr).then(function(acl) {
	    			j++;
	    			var infoTemplate = "<tr><th>" + j + "</th><td>" + tpaddr + "</td>+<td>" + convertPermission(acl[0]) + "</td><td>" + acl[1] + "</td></tr>"
	    			aclInfo.append(infoTemplate);					
				});
			});
	    }
	  });
	  
    }).catch(function(error) {
      console.warn(error);
    });
  },
  
  grantAccess: function() {
    var perSelect = $('#permissionSelect').val();
	var tpaddress = $('#tpaddress').val();
	var select = 0;
	
	// Check whether the input address is valid
	/*
	if (isAddress(tpaddress)) {
		alert("true");
	} else {
		alert("false");
	}	
	*/
	
	// Convert multiple select to uint	
	for (var i=0; i<perSelect.length; i++) {
		select += parseInt(perSelect[i]);
	}

	App.contracts.Election.deployed().then(function(instance) {
  		return instance.grantAccess(App.account, tpaddress, select);
	}).then(function(result) {
		// do nothing here
	}).catch(function(err) {
  		console.error(err);
	});

  },
  
  uploadData: function() {  
    var dpointer = $('#dpointer').val();
    var dhash = $('#dhash').val();
    
    App.contracts.Election.deployed().then(function(instance) {
      return instance.uploadData(App.account, dpointer, dhash);
    }).then(function(result) {
 
    }).catch(function(err) {
      console.error(err);
    });
  },
  
  tokenInfo: function() {
  	var actoken = $('#actoken').val();
  	var tokenInfo = $("#tokenInfo");
	tokenInfo.empty();
	
	App.contracts.Election.deployed().then(function(instance) {
      return instance.tokenlist(actoken);
    }).then(function(tokenrecord) {
    	alert(tokenrecord);    	
 	  	var infoTemplate = "<tr><th>" + tokenrecord[1] + "</th><td>" + convertPermission(tokenrecord[2]) + "</td>+<td>" + tokenrecord[3] + "</td><td>" + tokenrecord[4] + "</td>+<td>" + tokenrecord[5] + "</td><td>" +  tokenrecord[6] + "</td></tr>"
	    tokenInfo.append(infoTemplate);
    }).catch(function(err) {
      console.error(err);
    });	
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
