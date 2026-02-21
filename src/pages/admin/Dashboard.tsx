import { motion, AnimatePresence } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Users,
    Activity,
    Search,
    Zap,
    TrendingUp,
    ArrowUpRight
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

const useLiveStats = (initialProgress: number, initialAttendance: number) => {
    const [progress, setProgress] = useState(initialProgress);
    const [attendance, setAttendance] = useState(initialAttendance);

    useEffect(() => {
        const interval = setInterval(() => {
            setProgress(prev => Math.min(100, prev + (Math.random() > 0.7 ? 0.5 : 0)));
            setAttendance(prev => Math.min(100, Math.max(0, prev + (Math.random() > 0.5 ? 0.2 : -0.1))));
        }, 3000);
        return () => clearInterval(interval);
    }, []);

    return { progress, attendance };
};

const SessionCard = ({ status, title, time, initialProgress, initialAttendance, teams, index, onClick }: any) => {
    const { progress, attendance } = useLiveStats(initialProgress, initialAttendance);

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1, type: "spring", stiffness: 100 }}
            whileHover={{ y: -5, transition: { duration: 0.2 } }}
            onClick={onClick}
            className="glass-card p-6 rounded-3xl relative overflow-hidden group border-white/40 bg-white/70 backdrop-blur-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_50px_rgba(0,0,0,0.1)] transition-all cursor-pointer"
        >
            <div className="flex justify-between items-start mb-4">
                <span className={cn(
                    "px-3 py-1 rounded-full text-[10px] font-black tracking-widest uppercase flex items-center gap-1.5",
                    status === 'ACTIVE'
                        ? "bg-emerald-100 text-emerald-600 border border-emerald-200"
                        : "bg-orange-100 text-orange-600 border border-orange-200"
                )}>
                    {status === 'ACTIVE' && <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />}
                    {status}
                </span>
                <button className="text-slate-300 hover:text-slate-600 transition-colors px-2">
                    <span className="text-lg font-bold">•••</span>
                </button>
            </div>

            <h3 className="text-lg font-black text-slate-800 mb-1 leading-tight group-hover:text-primary transition-colors">{title}</h3>
            <p className="text-sm text-slate-400 font-medium mb-6">{time}</p>

            <div className="space-y-4">
                <div className="flex justify-between items-end mb-1">
                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Completion</span>
                    <span className="text-[11px] font-black text-primary">{Math.round(progress)}%</span>
                </div>
                <div className="h-2 w-full bg-slate-100/50 rounded-full overflow-hidden p-0.5 border border-slate-50">
                    <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        className="h-full bg-gradient-to-r from-primary to-cyan-400 rounded-full shadow-[0_0_12px_rgba(var(--primary),0.3)]"
                    />
                </div>

                <div className="flex justify-between items-center text-[11px] font-bold text-slate-600 pt-2 border-t border-slate-100/50">
                    <div className="flex items-center gap-1.5">
                        <Users className="w-3.5 h-3.5 text-slate-300" />
                        <span>{teams} Teams</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                        <Activity className="w-3.5 h-3.5 text-slate-300" />
                        <span>{attendance.toFixed(1)}% Attn.</span>
                    </div>
                </div>
            </div>
        </motion.div>
    );
};



const LiveTicker = () => {
    const [events, setEvents] = useState([
        "Team Alpha joined Hall A",
        "Hall B session initiated",
        "Attendance verification complete for Hall C",
        "New supervisor assigned to Session #42"
    ]);

    useEffect(() => {
        const interval = setInterval(() => {
            setEvents(prev => [prev[prev.length - 1], ...prev.slice(0, prev.length - 1)]);
        }, 5000);
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="bg-primary/5 border border-primary/10 rounded-2xl px-6 py-3 flex items-center gap-3 overflow-hidden whitespace-nowrap">
            <Zap className="w-4 h-4 text-primary animate-pulse flex-shrink-0" />
            <div className="text-[11px] font-black text-primary uppercase tracking-widest overflow-hidden">
                <AnimatePresence mode="wait">
                    <motion.p
                        key={events[0]}
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: -20, opacity: 0 }}
                        transition={{ duration: 0.5 }}
                    >
                        LIVE: {events[0]}
                    </motion.p>
                </AnimatePresence>
            </div>
        </div>
    );
};

const AdminDashboard = () => {
    const navigate = useNavigate();

    return (
        <div className="relative min-h-screen">
            {/* Floating Background Orbs */}
            <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
                <motion.div
                    animate={{ rotate: 360, x: [0, 100, 0], y: [0, 50, 0] }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                    className="absolute -top-40 -left-40 w-96 h-96 bg-primary/5 rounded-full blur-[100px]"
                />
                <motion.div
                    animate={{ rotate: -360, x: [0, -100, 0], y: [0, -50, 0] }}
                    transition={{ duration: 25, repeat: Infinity, ease: "linear" }}
                    className="absolute top-1/2 -right-40 w-[500px] h-[500px] bg-cyan-400/5 rounded-full blur-[120px]"
                />
            </div>

            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-6 duration-1000 max-w-5xl mx-auto pb-10 pt-4">
                {/* Profile Header - Compact */}
                <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="flex justify-between items-center px-4"
                >
                    <div className="flex items-center gap-4">
                        <div className="relative group">
                            <div className="absolute inset-0 bg-primary rounded-full blur-xl opacity-0 group-hover:opacity-20 transition-opacity" />
                            <div className="relative w-12 h-12 rounded-full overflow-hidden border-2 border-white shadow-lg ring-1 ring-slate-100 group-hover:ring-primary/20 transition-all cursor-pointer">
                                <img
                                    src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150"
                                    alt="Profile"
                                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                                />
                            </div>
                        </div>
                        <div>
                            <p className="text-slate-400 text-[9px] font-black uppercase tracking-widest mb-0.5">Admin Console</p>
                            <h2 className="text-lg font-black text-slate-900 leading-none">System Overview</h2>
                        </div>
                    </div>

                    <LiveTicker />
                </motion.div>

                {/* Search Bar */}
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 }}
                    className="px-4"
                >
                    <div className="relative group">
                        <Search className="absolute left-6 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-300 group-focus-within:text-primary transition-colors" />
                        <input
                            type="search"
                            placeholder="Search sessions or metrics..."
                            className="w-full px-14 py-5 bg-white/60 backdrop-blur-md border border-slate-100 rounded-2xl text-slate-700 placeholder:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/5 focus:border-primary/20 transition-all font-bold text-base shadow-sm"
                        />
                        <div className="absolute right-6 top-1/2 -translate-y-1/2 hidden md:block">
                            <span className="px-1.5 py-0.5 rounded bg-slate-50 border border-slate-200 text-[8px] font-black text-slate-400">⌘ K</span>
                        </div>
                    </div>
                </motion.div>

                {/* GD Project Metrics HUD */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 px-4">
                    <div className="glass-card p-4 rounded-2xl bg-white/50 border border-slate-100 flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-500">
                            <Activity className="w-5 h-5" />
                        </div>
                        <div>
                            <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Active Sessions</p>
                            <h4 className="text-sm font-black text-slate-800">8 Running</h4>
                        </div>
                    </div>
                    <div className="glass-card p-4 rounded-2xl bg-white/50 border border-slate-100 flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-500">
                            <Users className="w-5 h-5" />
                        </div>
                        <div>
                            <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Total Participants</p>
                            <h4 className="text-sm font-black text-slate-800">1,240 Students</h4>
                        </div>
                    </div>
                    <div className="glass-card p-4 rounded-2xl bg-white/50 border border-slate-100 flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-500">
                            <TrendingUp className="w-5 h-5" />
                        </div>
                        <div>
                            <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Avg. Engagement</p>
                            <h4 className="text-sm font-black text-slate-800">92% Positive</h4>
                        </div>
                    </div>
                </div>



                <div className="px-4">
                    {/* Live Sessions - Compact Grid */}
                    <div className="space-y-6">
                        <div className="flex justify-between items-center">
                            <div className="flex items-center gap-2">
                                <h2 className="text-xl font-black text-slate-900 tracking-tight">Live Sessions</h2>
                                <div className="px-2 py-0.5 rounded bg-primary text-[8px] font-black text-white uppercase tracking-widest">LIVE</div>
                            </div>
                            <button className="text-slate-400 font-black text-[9px] tracking-widest uppercase hover:text-primary transition-all flex items-center gap-1 group">
                                Audit All <ArrowUpRight className="w-3.5 h-3.5 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
                            </button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <SessionCard
                                status="ACTIVE"
                                title="Morning GD - Hall A"
                                time="In Progress"
                                initialProgress={78}
                                initialAttendance={92}
                                teams={24}
                                index={1}
                                onClick={() => navigate('sessions')}
                            />
                            <SessionCard
                                status="JOINING"
                                title="Tech Quiz - Block C"
                                time="Starts in 10m"
                                initialProgress={15}
                                initialAttendance={45}
                                teams={12}
                                index={2}
                                onClick={() => navigate('sessions')}
                            />
                        </div>
                    </div>
                </div>


            </div>
        </div>
    );
};

export default AdminDashboard;
