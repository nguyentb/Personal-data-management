package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the log_ledger data model, with 5 properties.  The Structure tags are used by encoding/json library
type LogLedger struct {
	Token string `json:"token"`
	Status string `json:status`
	Activity string `json:"activity"`
	Expiration int `json:"expiration"`
	Timestm string `json:"timestm"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryLedger" {
		return s.queryLedger(APIstub, args)
	} else if function == "initLedger" {
		return s.initLedger(APIstub)
    }

	return shim.Error("Invalid Smart Contract function name.")
}


// ===== Example: Parameterized rich query =================================================
// queryLedger queries for a log based on a passed in token.
// This is an example of a parameterized query where the query logic is baked into the chaincode,
// and accepting a single query parameter (token).
// Only available on state databases that support rich query (e.g. CouchDB)
func (s *SmartContract) queryLedger(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting 1 (i.e., the provided token)")
    }

    owner := args[0];
    // fmt.Printf("Cars belong to: " + owner);
    queryString := fmt.Sprintf("{\"selector\":{\"owner\":\"%s\"}}", owner);
    resultsIterator, err := APIstub.GetQueryResult(queryString)

    if err != nil {
        return shim.Error(err.Error());
    }
    defer resultsIterator.Close();

    // buffer is a JSON array containing QueryResults
    var buffer bytes.Buffer
    buffer.WriteString("[")
    bArrayMemberAlreadyWritten := false
    for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
            return shim.Error(err.Error())
        }
        // Add a comma before array members, suppress it for the first array member
        if bArrayMemberAlreadyWritten == true {
            buffer.WriteString(",")
        }
        buffer.WriteString("{\"Key\":")
        buffer.WriteString("\"")
        buffer.WriteString(queryResponse.Key)
        buffer.WriteString("\"")
        buffer.WriteString(", \"Record\":")
        // Record is a JSON object, so we write as-is
        buffer.WriteString(string(queryResponse.Value))
        buffer.WriteString("}")
        buffer.WriteString("\n")

        bArrayMemberAlreadyWritten = true
    }
    buffer.WriteString("]")
    fmt.Printf("- queryCarOwner:\n%s\n", buffer.String())
    return shim.Success(buffer.Bytes())
}


func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	log1 := LogLedger{Token: "xxx111", Status: "approved", Activity: "blue", Expiration: 3600, Timestm: "12321312"}

	log1AsBytes, _ := json.Marshal(log1)
	APIstub.PutState("pk_DS, pk_DC, pk_DP", carAsBytes)
	fmt.Println("Added", log1)

	return shim.Success(nil)
}

func (s *SmartContract) changeCarOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	carAsBytes, _ := APIstub.GetState(args[0])
	car := Car{}

	json.Unmarshal(carAsBytes, &car)
	car.Owner = args[1]

	carAsBytes, _ = json.Marshal(car)
	APIstub.PutState(args[0], carAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
