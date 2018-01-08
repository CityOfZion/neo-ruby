## RPC Functions

* [x] getaccountstate <address> - Check account asset information according to account address
* [x] getassetstate <asset_id> - Query asset information according to the specified asset number
* [x] getbestblockhash - Gets the hash of the tallest block in the main chain
* [x] getblock <hash> [verbose=0] - Returns the corresponding block information according to the specified hash value
* [x] getblock <index> [verbose=0] - Returns the corresponding block information according to the specified index
* [x] getblockcount - Gets the number of blocks in the main chain
* [x] getblockhash <index> - Returns the hash value of the corresponding block based on the specified index
* [x] getblocksysfee <index> - Returns the system fees before the block according to the specified index
* [x] getconnectioncount - Gets the current number of connections for the node
* [x] getcontractstate <script_hash> - Returns information about the contract based on the specified script hash
* [x] getrawmempool - Get a list of unconfirmed transactions in memory
* [x] getrawtransaction <txid> [verbose=0] - Returns the corresponding transaction information based on the specified hash value
* [ ] getstorage <script_hash> <key> - Returns the stored value based on the contract script hash and key
* [x] gettxout <txid> <n> - Returns the corresponding transaction output (change) information based on the specified hash and index
* [x] getpeers - Get a list of nodes that are currently connected/disconnected by this node
* [x] getversion - Get version information of this node
* [ ] invoke <script_hash> <params> - Invokes a smart contract at specified script hash with the given parameters
* [ ] invokefunction <script_hash> <operation> <params> - Invokes a smart contract at specified script hash, passing in an operation and its params
* [ ] invokescript <script> - Runs a script through the virtual machine and returns the results
* [ ] sendrawtransaction <hex> - Broadcast a transaction over the network. See the network protocol documentation.
* [x] validateaddress <address> - Verify that the address is a correct NEO address
