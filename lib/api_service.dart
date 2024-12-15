import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart'; // For Ethereum interaction
import 'package:flutter/services.dart'; // For loading the ABI

class ApiService {
  // Flask backend URL
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Ethereum RPC and contract configuration
  final String _rpcUrl = 'http://127.0.0.1:8545'; // Ganache or Ethereum node
  final String _privateKey = '0x45f789ac8c034c5b153440849129c4f8f8ba6f04756e6d3611a0d645e25bb648'; // Replace with your wallet's private key
  final String _contractAddress = '0xea5247a7F18f58CDa1bEA645E98E9Dceb3BeE676'; // Replace with deployed contract address

  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  // Constructor to initialize Ethereum client and contract
  ApiService() {
    _client = Web3Client(_rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  // Load the ABI and initialize the deployed contract
  Future<void> initializeContract() async {
    final abiString = await rootBundle.loadString('assets/abi.json'); // Load ABI from assets
    _contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'Company'),
      EthereumAddress.fromHex(_contractAddress),
    );
  }

  // Add a product to the smart contract
  Future<String> addProduct(String productId, String ownerId, String manufacturerId) async {
    try {
      // Ensure the contract is initialized
      if (_contract == null) {
        await initializeContract();
      }

      // Convert Product ID to BigInt and create the product hashcode
      final productHashcode = BigInt.parse(productId);

      // Call the `addProducts` function in the contract
      final transactionHash = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _contract.function('addProducts'),
          parameters: [
            EthereumAddress.fromHex(ownerId), // Owner address
            [productHashcode], // List of product IDs (hashcodes)
          ],
        ),
        chainId: null, // Adjust for the correct network ID (e.g., Ganache uses 1337)
      );

      return transactionHash; // Return the transaction hash for tracking
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Verify a product's authenticity in the smart contract
  Future<String> verifyProduct(String productId) async {
    try {
      // Ensure the contract is initialized
      if (_contract == null) {
        await initializeContract();
      }

      // Convert Product ID to BigInt
      final productHashcode = BigInt.parse(productId);

      // Call the `verifyProduct` function in the contract
      final result = await _client.call(
        contract: _contract,
        function: _contract.function('verifyProduct'),
        params: [productHashcode],
      );

      return result.first as String; // Return the verification result (e.g., "Authenticated")
    } catch (e) {
      throw Exception('Failed to verify product: $e');
    }
  }

  // Flask API: Retrieve products from the backend
  Future<List<dynamic>> retrieveProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/retrieve_products'));
    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse and return the product list
    } else {
      throw Exception('Failed to retrieve products: ${response.body}');
    }
  }

  // Flask API: Check product details via backend
  Future<Map<String, dynamic>> checkProduct(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/check_product?product_id=$productId'));
    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse and return product details
    } else {
      throw Exception('Failed to fetch product: ${response.body}');
    }
  }
}
