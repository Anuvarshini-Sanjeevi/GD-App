import { Outlet } from 'react-router-dom';
import { Sidebar } from '../components/admin/Sidebar';

export const AdminLayout = () => {
    return (
        <div className="min-h-screen bg-[#f8fafc] text-foreground flex selection:bg-primary/10 selection:text-primary transition-colors duration-500">
            <Sidebar />
            <main className="flex-1 ml-56 p-8 lg:p-10 h-screen overflow-y-auto scrollbar-hide">
                <div className="max-w-screen-xl mx-auto pb-10">
                    <Outlet />
                </div>
            </main>

        </div>
    );
};
