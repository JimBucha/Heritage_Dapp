import { Link } from 'react-router-dom';

export default function Sidebar() {
  return (
    <div className="w-64 bg-gray-800 min-h-screen p-4">
      <div className="text-white text-xl font-bold mb-8">Heritage Insurance</div>
      <nav>
        <ul className="space-y-2">
          <li>
            <Link to="/admin/dashboard" className="block px-4 py-2 text-gray-300 hover:bg-gray-700 rounded">
              Dashboard
            </Link>
          </li>
          <li>
            <Link to="/admin/policies" className="block px-4 py-2 text-gray-300 hover:bg-gray-700 rounded">
              Policies
            </Link>
          </li>
          <li>
            <Link to="/admin/claims" className="block px-4 py-2 text-gray-300 hover:bg-gray-700 rounded">
              Claims
            </Link>
          </li>
          <li>
            <Link to="/admin/reports" className="block px-4 py-2 text-gray-300 hover:bg-gray-700 rounded">
              Reports
            </Link>
          </li>
        </ul>
      </nav>
    </div>
  );
}