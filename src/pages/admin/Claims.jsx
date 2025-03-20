import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axios from 'axios';
import { Link } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';
import { useBlockchain } from '../../contexts/BlockchainContext';

export default function Claims() {
  const queryClient = useQueryClient();
  const { web3, account } = useBlockchain();

  // Fetch claims
  const { data: claims } = useQuery({
    queryKey: ['claims'],
    queryFn: async () => {
      const res = await axios.get('/api/claims');
      return res.data;
    },
  });

  // Approve/reject claim (blockchain + backend)
  const processClaim = useMutation({
    mutationFn: async ({ claimId, action }) => {
      // 1. Update blockchain
      const contract = new web3.eth.Contract(contractABI, contractAddress);
      if (action === 'approve') {
        await contract.methods.approveClaim(claimId).send({ from: account });
      }

      // 2. Update backend
      await axios.patch(`/api/claims/${claimId}`, { status: action });
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
    },
  });

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 p-8">
        <h1 className="text-2xl font-bold mb-6">Claims</h1>
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="min-w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Policyholder</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount (ETH)</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {claims?.map((claim) => (
                <tr key={claim.claim_id}>
                  <td className="px-6 py-4 whitespace-nowrap">{claim.user_id}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{web3.utils.fromWei(claim.amount_claimed, 'ether')}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-sm rounded-full ${claim.status === 'approved' ? 'bg-green-100 text-green-800' : claim.status === 'rejected' ? 'bg-red-100 text-red-800' : 'bg-yellow-100 text-yellow-800'}`}>
                      {claim.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap space-x-2">
                    {claim.status === 'pending' && (
                      <>
                        <button
                          onClick={() => processClaim.mutate({ claimId: claim.claim_id, action: 'approve' })}
                          className="text-green-600 hover:text-green-900"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() => processClaim.mutate({ claimId: claim.claim_id, action: 'reject' })}
                          className="text-red-600 hover:text-red-900"
                        >
                          Reject
                        </button>
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}