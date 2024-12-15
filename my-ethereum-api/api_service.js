import Web3 from 'web3';

const contractABI = [ [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_ownerAddress",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_contractAddress",
				"type": "address"
			},
			{
				"internalType": "uint256[]",
				"name": "_products",
				"type": "uint256[]"
			}
		],
		"name": "addproduct",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "createSmartContract",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_contractAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_productHashCode",
				"type": "uint256"
			}
		],
		"name": "checkProduct",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_walletAddress",
				"type": "address"
			}
		],
		"name": "getCompanySmartContractAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_val",
				"type": "address"
			}
		],
		"name": "retrieve",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
] ];
const contractAddress = '0xf33c5CD8dCD581174800fA934063Cd7bc015fB7f'; 
const web3 = new Web3('http://127.0.0.1:7545');
const contract = new web3.eth.Contract(contractABI, contractAddress);

async function addProduct(ownerAddress, contractAddress, products, userAddress) {
    try {
        const result = await contract.methods.addproduct(ownerAddress, contractAddress, products).send({ from: userAddress });
        return result;
    } catch (error) {
        console.error("Error adding product:", error);
        throw error; 
    }
}

async function checkProduct(contractAddress, productHashCode) {
    try {
        const productInfo = await contract.methods.checkProduct(contractAddress, productHashCode).call();
        return productInfo;
    } catch (error) {
        console.error("Error checking product:", error);
        throw error; 
    }
}

export { addProduct, checkProduct };