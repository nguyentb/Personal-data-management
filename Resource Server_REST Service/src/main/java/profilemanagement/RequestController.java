package profilemanagement;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RequestController {
	
	@Autowired
	private MongoTemplate mongoTemplate;
	
	@Autowired
	private ProfileRepository prepo;
	
	@RequestMapping(value = "/pcreate", method = RequestMethod.GET)   
    public String pcreate(@RequestParam Map<String, String> requestParams) throws Exception{	
    	
    	String pub = requestParams.get("pk"); //public key
    	String sig = requestParams.get("sig"); //corresponding signature
    	
    	//verify the pub and sig
    	//validate whether the pub has permission to create a profile by
    	//querying the ledger using corresponding Smart Contract
    	
    	// 1. Calling a NodeJS SDK HLF  client app to query the ledger
    	Process process = new ProcessBuilder("node", "/home/nguyentb/Hyperledger/HNAProject/nodejs-apps/query.js").start();
    	InputStream is = process.getInputStream();
    	InputStreamReader isr = new InputStreamReader(is);
    	BufferedReader br = new BufferedReader(isr);
    	String line;

    	while ((line = br.readLine()) != null) {
    	  System.out.println(line);
    	}
    	
    	// 2. Get output from the app
    	
    	String fname = requestParams.get("fname"); //first name
    	String lname = requestParams.get("lname"); //last name
    	int age = Integer.parseInt(requestParams.get("age"));
    	String email = requestParams.get("email");
 	
    	Profile ret = new Profile(fname, lname, age, email, System.currentTimeMillis());
		prepo.save(ret);
    	
 	   	return ret.getId();
    }
		
	@RequestMapping(value = "/profile", method = RequestMethod.GET)   
    public Profile profiledao(@RequestParam Map<String, String> requestParams) throws Exception{	
    	try {
	    	String pub = requestParams.get("pk"); //public key
	    	String sig = requestParams.get("sig"); //corresponding signature
	    	String pid = requestParams.get("pid"); //public key
	    	String token = requestParams.get("token"); //access token
	    	String act = requestParams.get("action"); //requested action on personal data
	    	
	    	// Validate the access token by calling a smart contract
	    	// TODO: 
	    	// val = SmartContract.execute.parameter(pub, sig, token, act);
	    	// get metadata associated with the access token
	    	
	    	Process process = new ProcessBuilder("node", "/home/nguyentb/Hyperledger/HNAProject/nodejs-apps/acquery.js", token).start();
	    	InputStream is = process.getInputStream();
	    	InputStreamReader isr = new InputStreamReader(is);
	    	BufferedReader br = new BufferedReader(isr);
	    	String line;

	    	while ((line = br.readLine()) != null) {
	    	  System.out.println(line);
	    	}
	    	
	    		    	
	    	boolean val = true;
	    	Profile ret = null;
	    	if (val) {
	    		Query query = new Query();
	        	query.addCriteria(Criteria.where("id").is(pid));
	        	
	        	List<Profile> pdata = mongoTemplate.find(query, Profile.class); // get profile data from the query
	        	  	        	
	        	if (!pdata.isEmpty())
	        		ret = pdata.get(0);
	    	}
	    	   	
	    	if (act.equals("read")) {
	    		System.out.println("Read the profile");
	    		
	    		//Call corresponding Smart Contract to update the activity log
	    		
	    		System.out.println("Update the ledger");
	    		return ret;	
	    	}
	    		    	
	    	return null;
	    
		} catch(Exception e){
			System.err.println("Caught IOException: " + e.getMessage());
			return null;
		}
	}
}