import React from 'react';
import { Outlet } from 'react-router-dom';
import { Sidebar } from '../components/admin/Sidebar';

export const AdminLayout = () => {
    return (
        <div className="min-h-screen bg-background text-foreground flex selection:bg-primary/10 selection:text-primary transition-colors duration-500">
            <Sidebar />
            <main className="flex-1 ml-56 p-8 lg:p-10 h-screen overflow-y-auto scrollbar-hide">
                <div className="max-w-screen-xl mx-auto pb-10">
                    <Outlet />
                </div>
            </main>

            {/* Subtle Light Mode Background Effects */}
            <div className="fixed top-[-10%] left-[-5%] w-[60%] h-[60%] bg-primary/5 rounded-full blur-[140px] pointer-events-none" />
            <div className="fixed bottom-[-5%] right-[-5%] w-[40%] h-[40%] bg-cyan-500/5 rounded-full blur-[120px] pointer-events-none" />

            {/* Fine texture overlay */}
            <div className="fixed inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-[0.02] pointer-events-none" />
        </div>
    );
};
