import express from 'express';
import Web3 from 'web3';
import bodyParser from 'body-parser';
import cors from 'cors';
import { addMedicalRecord, getMedicalRecord } from './api_service.js'; // Ensure to use .js extension

const app = express();
const web3 = new Web3('http://127.0.0.1:7545'); // Ganache default port
const PORT = process.env.PORT || 5000; // Set the port to listen on

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(bodyParser.json()); // Parse JSON request bodies

// Define API endpoint to add a medical record
app.post('/addRecord', async (req, res) => {
    const { patientName, recordHash, userAddress } = req.body; // Extract data from request body
    try {
        const result = await addMedicalRecord(patientName, recordHash, userAddress); // Call the function to add the record
        res.json(result); // Send the result back as JSON
    } catch (error) {
        res.status(500).send(error.message); // Handle errors
    }
});

// Define API endpoint to get a medical record
app.get('/getRecord/:id', async (req, res) => {
    const recordId = req.params.id; // Get the record ID from the URL parameters
    try {
        const record = await getMedicalRecord(recordId); // Call the function to get the record
        res.json(record); // Send the record back as JSON
    } catch (error) {
        res.status(500).send(error.message); // Handle errors
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`); // Log the server URL
});