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
        <div className="w-56 h-screen bg-white border-r border-border flex flex-col fixed left-0 top-0 z-50">
            <div className="p-6">
                <div className="flex items-center gap-3 mb-10 group cursor-pointer">
                    <div className="relative">
                        <div className="absolute inset-0 bg-primary/10 blur-lg rounded-xl group-hover:bg-primary/20 transition-all" />
                        <div className="relative p-2.5 bg-primary rounded-xl shadow-lg shadow-primary/10 group-hover:scale-110 transition-transform duration-500">
                            <Shield className="w-5 h-5 text-primary-foreground" />
                        </div>
                    </div>
                    <div>
                        <h1 className="text-lg font-black tracking-tighter leading-none text-slate-900">
                            GD ADMIN
                        </h1>
                        <p className="text-[9px] font-bold text-primary tracking-[0.15em] uppercase mt-1 opacity-80">
                            Admin Console
                        </p>
                    </div>
                </div>

                <nav className="space-y-1.5">
                    {navItems.map((item) => (
                        <NavLink
                            key={item.path}
                            to={item.path}
                            end={item.path === '/admin'}
                            className={({ isActive }) => cn(
                                "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-300 group relative overflow-hidden",
                                isActive
                                    ? "bg-primary/5 text-primary font-bold border border-primary/10 shadow-sm"
                                    : "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
                            )}
                        >
                            <item.icon className={cn(
                                "w-4.5 h-4.5 transition-transform duration-300 group-hover:scale-110",
                                "relative z-10"
                            )} />
                            <span className="relative z-10 tracking-tight text-xs uppercase font-black">{item.label}</span>
                        </NavLink>
                    ))}
                </nav>
            </div>

            <div className="mt-auto p-6 space-y-6">
                <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-12 h-12 bg-primary/5 blur-xl rounded-full" />
                    <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2">Health</p>
                    <div className="flex items-center gap-2">
                        <div className="relative">
                            <div className="w-2 h-2 rounded-full bg-emerald-500" />
                            <div className="absolute inset-0 w-2 h-2 rounded-full bg-emerald-500 animate-ping opacity-40" />
                        </div>
                        <span className="text-xs font-bold text-slate-700">Online</span>
                    </div>
                </div>

                <button className="flex items-center justify-center gap-2.5 px-4 py-3.5 w-full rounded-xl border border-slate-200 text-slate-500 hover:text-rose-500 hover:bg-rose-50 hover:border-rose-200 transition-all font-black text-[10px] uppercase tracking-widest group">
                    <LogOut className="w-3.5 h-3.5 group-hover:-translate-x-1 transition-transform" />
                    Sign Out
                </button>
            </div>
        </div>
    );
};
