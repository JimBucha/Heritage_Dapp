import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';  
import axios from 'axios';  
import { Link } from 'react-router-dom';  
import Sidebar from '../../components/Sidebar';  

export default function Policies() {  
  const queryClient = useQueryClient();  

  // Fetch policies  
  const { data: policies } = useQuery({  
    queryKey: ['policies'],  
    queryFn: async () => {  
      const res = await axios.get('/api/policies');  
      return res.data;  
    },  
  });  

  // Delete policy  
  const deletePolicy = useMutation({  
    mutationFn: async (policyId) => {  
      await axios.delete(`/api/policies/${policyId}`);  
    },  
    onSuccess: () => {  
      queryClient.invalidateQueries(['policies']);  
    },  
  });  

  return (  
    <div className="flex">  
      <Sidebar />  
      <div className="flex-1 p-8">  
        <div className="flex justify-between items-center mb-6">  
          <h1 className="text-2xl font-bold">Policies</h1>  
          <Link  
            to="/admin/policies/new"  
            className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"  
          >  
            Create New Policy  
          </Link>  
        </div>  
        <div className="bg-white rounded-lg shadow overflow-hidden">  
          <table className="min-w-full">  
            <thead className="bg-gray-50">  
              <tr>  
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>  
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>  
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>  
              </tr>  
            </thead>  
            <tbody className="divide-y divide-gray-200">  
              {policies?.map((policy) => (  
                <tr key={policy.policy_id}>  
                  <td className="px-6 py-4 whitespace-nowrap">{policy.name}</td>  
                  <td className="px-6 py-4 whitespace-nowrap">{policy.category_id}</td>  
                  <td className="px-6 py-4 whitespace-nowrap">  
                    <button  
                      onClick={() => deletePolicy.mutate(policy.policy_id)}  
                      className="text-red-600 hover:text-red-900"  
                    >  
                      Delete  
                    </button>  
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