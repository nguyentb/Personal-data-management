var isAddress = function (address) {
    if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) {
        // check if it has the basic requirements of an address
        return false;
    } else if (/^(0x)?[0-9a-f]{40}$/.test(address) || /^(0x)?[0-9A-F]{40}$/.test(address)) {
        // If it's all small caps or all all caps, return true
        return true;
    } else {
        // Otherwise check each case
        address = address.replace('0x','');

        // creates the case map using the binary form of the hash of the address
        var caseMap = parseInt(web3.sha3('0x'+address.toLowerCase()),16).toString(2).substring(0, 40);

        for (var i = 0; i < 40; i++ ) { 
            // the nth letter should be uppercase if the nth digit of casemap is 1
            if ((caseMap[i] == '1' && address[i].toUpperCase() != address[i])|| (caseMap[i] == '0' && address[i].toLowerCase() != address[i])) {
                return false;
            }
        }
        return true;
    }
};


/**
 * Makes a checksum address
 *
 * @method toChecksumAddress
 * @param {String} address the given HEX adress
 * @return {String}
*/
var toChecksumAddress = function (address) {

    var checksumAddress = '0x';
    address = address.toLowerCase().replace('0x','');

    // creates the case map using the binary form of the hash of the address
    var caseMap = parseInt(web3.sha3('0x'+address),16).toString(2).substring(0, 40);

    for (var i = 0; i < address.length; i++ ) {  
        if (caseMap[i] == '1') {
          checksumAddress += address[i].toUpperCase();
        } else {
            checksumAddress += address[i];
        }
    }

    console.log('create: ', address, caseMap, checksumAddress)
    return checksumAddress;
};

var convertPermission = function (permission) {
	var ret = "";
	switch (parseInt(permission)) {
		case 0:
			ret = "NO PERMISSION"
			break;
		case 1:
			ret = "CREATE"
			break;
		case 2:
			ret = "READ"
			break;
		case 3:
			ret = "CREATE & READ"
			break;
		case 4:
			ret = "UPDATE"
			break;
		case 5:
			ret = "CREATE & UPDATE"
			break;
		case 6:
			return "READ & UPDATE"
			break;
		case 7:
			ret = "CREATE & READ & UPDATE"
			break;
		case 8:
			ret = "DELETE"
			break;
		case 9:
			ret = "CREATE & DELETE"
			break;
		case 10:
			ret = "READ & DELETE"
			break;
		case 11:
			ret = "CREATE & READ & UPDATE"
			break;
		case 12:
			ret = "UPDATE & DELETE"
			break;
		case 14:
			ret = "READ & UPDATE & DELETE"			
			break;
		case 15:
			ret = "CREATE & READ & UPDATE & DELETE"
			break;
		default:
			ret = "undefined";
	}
	return ret;
};
