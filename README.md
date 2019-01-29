# Personal-data-management-SMs
Personal Data Management business logic written in Smart Contracts.

Owner identifier in Hyperledger Fabric
In the Hyperledger Fabric network, all actors have an identity known to other participants. The default Membership Service Provider implementation uses X.509 certificates as identities, adopting a traditional Public Key Infrastructure (PKI) hierarchical model.

Using information about creator of a proposal and asset ownership the chaincode should be able implement chaincode-level access control mechanisms checking is actor can initiate transactions that update the asset. The corresponding chaincode logic has to be able to store this "ownership" information associated with the asset and evaluate it with respect to the proposal creator.

In HLF network as unique owner identifier (token balance holder) we can use combination of MSP Identifier and user identity identifier. Identity identifier - is concatenation of Subject and Issuer parts of X.509 certificate. This ID is guaranteed to be unique within the MSP.

func (c *clientIdentityImpl) GetID() (string, error) {
	// The leading "x509::" distinquishes this as an X509 certificate, and
	// the subject and issuer DNs uniquely identify the X509 certificate.
	// The resulting ID will remain the same if the certificate is renewed.
	id := fmt.Sprintf("x509::%s::%s", getDN(&c.cert.Subject), getDN(&c.cert.Issuer))
	return base64.StdEncoding.EncodeToString([]byte(id)), nil
}
Client identity chaincode library allows to write chaincode which makes access control decisions based on the identity of the client (i.e. the invoker of the chaincode).

In particular, you may make access control decisions based on either or both of the following associated with the client:

the client identity's MSP (Membership Service Provider) ID
an attribute associated with the client identity
CCkit contains identity package with structures and functions can that be used for implementing access control in chaincode.

Defining token smart contract functions

First, we need to define chaincode functions. In this project we use router package from CCkit, that allows us to define chaincode methods and their parameters in consistent way.
The chaincode kit is embedded as a library for the Hyperledger Smart Contracts
