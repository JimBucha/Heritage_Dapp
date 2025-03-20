import { useState } from 'react';
import { useBlockchain } from '../../contexts/BlockchainContext';
import axios from 'axios';

export default function Payment({ policyId, premium }) {
  const { web3, account } = useBlockchain();
  const [isPaying, setIsPaying] = useState(false);

  const handlePayment = async () => {
    setIsPaying(true);
    try {
      // 1. Pay on blockchain
      const contract = new web3.eth.Contract(contractABI, contractAddress);
      await contract.methods
        .payPremium(policyId)
        .send({ 
          from: account, 
          value: web3.utils.toWei(premium, 'ether') 
        });

      // 2. Update backend payment status
      await axios.post('/api/transactions', {
        user_policy_id: policyId,
        amount: premium,
        blockchain_tx_hash: txHash,
      });
      
      alert('Payment successful!');
    } catch (error) {
      alert('Payment failed: ' + error.message);
    }
    setIsPaying(false);
  };

  return (
    <div className="p-4 bg-gray-50 rounded-lg">
      <h3 className="text-lg font-semibold mb-2">Pay Premium</h3>
      <p className="mb-4">{premium} ETH</p>
      <button
        onClick={handlePayment}
        disabled={isPaying}
        className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:bg-gray-400"
      >
        {isPaying ? 'Processing...' : 'Pay with MetaMask'}
      </button>
    </div>
  );
}