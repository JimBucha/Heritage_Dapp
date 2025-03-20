import { useQuery } from '@tanstack/react-query';
import Sidebar from '../../components/Sidebar';

export default function Dashboard() {
  // Example: Fetch stats from backend API
  const { data: stats } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const res = await axios.get('/api/admin/stats');
      return res.data;
    },
  });

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 p-8">
        <h1 className="text-2xl font-bold mb-6">Admin Dashboard</h1>
        <div className="grid grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-gray-500">Total Policies</h3>
            <p className="text-3xl font-bold">{stats?.totalPolicies || 0}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-gray-500">Pending Claims</h3>
            <p className="text-3xl font-bold">{stats?.pendingClaims || 0}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-gray-500">Revenue (ETH)</h3>
            <p className="text-3xl font-bold">{stats?.revenue || 0}</p>
          </div>
        </div>
      </div>
    </div>
  );
}