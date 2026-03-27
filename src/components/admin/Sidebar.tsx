import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard,
    BarChart3,
    Settings,
    LogOut,
    Shield,
    Database,
    User,
} from 'lucide-react';
import { motion } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

const navItems = [
    { icon: LayoutDashboard, label: 'Overview', path: '/admin' },
    { icon: Database, label: 'Sessions', path: '/admin/sessions' },
    { icon: BarChart3, label: 'Analytics', path: '/admin/analytics' },
    { icon: User, label: 'Profile', path: '/admin/profile' },
    { icon: Settings, label: 'Config', path: '/admin/settings' },
];

export const Sidebar = () => {
    return (
        <div className="w-64 h-screen bg-white/80 backdrop-blur-2xl border-r border-slate-200/50 flex flex-col fixed left-0 top-0 z-50 shadow-[4px_0_24px_rgba(0,0,0,0.02)]">
            <div className="p-8">
                {/* Brand Identity */}
                <div className="flex items-center gap-4 mb-12 group cursor-pointer">
                    <div className="relative">
                        <div className="absolute inset-0 bg-primary/20 blur-xl rounded-2xl group-hover:bg-primary/30 transition-all duration-700" />
                        <div className="relative p-3 bg-slate-900 rounded-2xl shadow-2xl shadow-slate-200 group-hover:scale-105 transition-transform duration-500">
                            <Shield className="w-5 h-5 text-white" />
                        </div>
                    </div>
                    <div>
                        <h1 className="text-lg font-black tracking-tighter text-slate-900 leading-none">
                            GD <span className="text-primary italic">ADMIN</span>
                        </h1>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] mt-1.5 opacity-60">
                            Console v2.0
                        </p>
                    </div>
                </div>

                <nav className="space-y-2">
                    {navItems.map((item) => (
                        <NavLink
                            key={item.path}
                            to={item.path}
                            end={item.path === '/admin'}
                            className={({ isActive }) => cn(
                                "flex items-center gap-4 px-5 py-3.5 rounded-2xl transition-all duration-500 group relative overflow-hidden",
                                isActive
                                    ? "text-primary font-black"
                                    : "text-slate-400 hover:text-slate-600 hover:bg-slate-50/50"
                            )}
                        >
                            {({ isActive }) => (
                                <>
                                    <item.icon className={cn(
                                        "w-5 h-5 transition-all duration-500 relative z-10",
                                        isActive ? "scale-110 drop-shadow-[0_0_8px_rgba(var(--primary),0.3)]" : "group-hover:text-slate-500"
                                    )} />
                                    <span className="text-[11px] uppercase tracking-[0.15em] relative z-10">{item.label}</span>
                                    
                                    {isActive && (
                                        <motion.div 
                                            layoutId="sidebar-active-pill"
                                            className="absolute inset-0 bg-primary/5 border border-primary/10 rounded-2xl z-0 shadow-inner"
                                            transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                                        />
                                    )}
                                    {isActive && (
                                        <motion.div 
                                            layoutId="sidebar-active-line"
                                            className="absolute left-0 w-1.5 h-6 bg-primary rounded-r-full shadow-[0_0_12px_rgba(var(--primary),0.5)]"
                                            style={{ top: 'calc(50% - 12px)' }}
                                            transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                                        />
                                    )}
                                </>
                            )}
                        </NavLink>
                    ))}
                </nav>
            </div>

            <div className="mt-auto p-8 border-t border-slate-100 bg-slate-50/20">
                <div className="mb-8 p-4 bg-white/50 border border-slate-200/50 rounded-2xl backdrop-blur-sm shadow-sm group hover:border-primary/20 transition-all duration-500">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-400 group-hover:bg-primary/5 group-hover:border-primary/10 group-hover:text-primary transition-all">
                            <User className="w-5 h-5" />
                        </div>
                        <div>
                            <p className="text-[10px] font-black text-slate-900 uppercase tracking-widest">Admin User</p>
                            <p className="text-[9px] font-bold text-slate-400 mt-0.5">Administrator</p>
                        </div>
                    </div>
                </div>

                <motion.button 
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className="flex items-center justify-center gap-3 px-5 py-4 w-full rounded-2xl border border-slate-200 text-slate-400 hover:text-rose-600 hover:bg-rose-50 hover:border-rose-100 transition-all duration-300 font-black text-[10px] uppercase tracking-[0.2em] group shadow-sm hover:shadow-lg hover:shadow-rose-100"
                >
                    <LogOut className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
                    Sign Out
                </motion.button>
            </div>
        </div>
    );
};
