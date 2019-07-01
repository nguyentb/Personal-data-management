
# Personal Data Management - Ethereum-based system

Follow the steps below to download, install, and run this project.

## Dependencies
Install these prerequisites to follow along with the Personal data management system based on Ethereum.
- NPM: https://nodejs.org
- Truffle: https://github.com/trufflesuite/truffle
- Ganache: http://truffleframework.com/ganache/
- Metamask: https://metamask.io/


## Step 1. Clone the project
`git clone https://github.com/nguyentb/Personal-data-management`

## Step 2. Go to Ethereum folder, Install dependencies
```
$ cd Ethereum
$ npm install
```
## Step 3. Start Ganache
Open the Ganache GUI client that you downloaded and installed. This will start your local blockchain instance.

## Step 4. Compile & Deploy the Smart Contracts
`$ truffle migrate --reset`
You must migrate the smart contract each time your restart ganache.

## Step 5. Configure Metamask
See free video tutorial for full explanation of these steps:
- Unlock Metamask
- Connect metamask to your local Etherum blockchain provided by Ganache.
- Import an account provided by ganache.

## Step 6. Run the Front End Application
`$ npm run dev`
Visit this URL in your browser: http://localhost:3000

If you get stuck, please contact me at ngbitr@gmail.com.
