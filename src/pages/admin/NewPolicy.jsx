import { useState } from 'react';  
import { useNavigate } from 'react-router-dom';  
import { useBlockchain } from '../../contexts/BlockchainContext';  
import axios from 'axios';  

export default function NewPolicy() {  
  const { web3, account } = useBlockchain();  
  const [name, setName] = useState('');  
  const [premium, setPremium] = useState('');  
  const [ipfsHash, setIpfsHash] = useState('');  
  const navigate = useNavigate();  

  const handleSubmit = async (e) => {  
    e.preventDefault();  
    // 1. Upload policy document to IPFS (pseudo-code)  
    // const ipfsHash = await uploadToIPFS(policyDocument);  

    // 2. Create policy on blockchain  
    const contract = new web3.eth.Contract(contractABI, contractAddress);  
    await contract.methods  
      .createPolicy(account, name, web3.utils.toWei(premium, 'ether'), 31536000, ipfsHash)  
      .send({ from: account });  

    // 3. Save policy to MySQL via backend API  
    await axios.post('/api/policies', {  
      name,  
      category_id: 1, // Replace with dynamic value  
      ipfs_hash: ipfsHash,  
    });  

    navigate('/admin/policies');  
  };  

  return (  
    <div className="p-8">  
      <h1 className="text-2xl font-bold mb-6">Create New Policy</h1>  
      <form onSubmit={handleSubmit} className="max-w-lg space-y-4">  
        <div>  
          <label className="block text-sm font-medium text-gray-700">Policy Name</label>  
          <input  
            type="text"  
            value={name}  
            onChange={(e) => setName(e.target.value)}  
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"  
          />  
        </div>  
        <div>  
          <label className="block text-sm font-medium text-gray-700">Premium (ETH)</label>  
          <input  
            type="number"  
            value={premium}  
            onChange={(e) => setPremium(e.target.value)}  
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"  
          />  
        </div>  
        <button  
          type="submit"  
          className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"  
        >  
          Create Policy  
        </button>  
      </form>  
    </div>  
  );  
}  