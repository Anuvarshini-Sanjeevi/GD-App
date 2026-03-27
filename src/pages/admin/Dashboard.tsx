import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../../utils/api';
import {
    Users,
    Activity,
    ArrowUpRight,
    Zap,
    TrendingUp,
    Clock
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

const SessionCard = ({ token, index, onClick }: any) => {
    const status = token.session_status || 'CREATED';
    const title = token.activity_type ? token.activity_type.replace(/_/g, ' ') : token.hall_qr_token;

    let progress = 0;
    let timeLabel = "Pending";

    if (token.start_time_ms && token.total_duration_minutes) {
        const now = Date.now();
        const durationMs = token.total_duration_minutes * 60 * 1000;
        const elapsed = now - token.start_time_ms;

        if (elapsed < 0) {
            progress = 0;
            const minsToStart = Math.ceil(-elapsed / 60000);
            timeLabel = `Starts in ${minsToStart}m`;
        } else if (elapsed >= durationMs) {
            progress = 100;
            timeLabel = "Completed";
        } else {
            progress = (elapsed / durationMs) * 100;
            const minsLeft = Math.ceil((durationMs - elapsed) / 60000);
            timeLabel = `${minsLeft}m left`;
        }
    }

    const attendanceCount = token.scan_count || 0;

    const isActive = status === 'ACTIVE' || status === 'PROGRESS';
    const isJoining = status === 'JOINING';

    return (
        <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.06 }}
            onClick={onClick}
            className="glass-card p-5 rounded-2xl cursor-pointer group relative overflow-hidden"
        >
            {/* Subtle accent bar */}
            <div className={cn(
                "absolute top-0 left-0 w-full h-0.5 rounded-t-xl transition-opacity",
                isActive ? "bg-gradient-to-r from-emerald-400 to-teal-400 opacity-100" :
                isJoining ? "bg-gradient-to-r from-blue-400 to-indigo-400 opacity-100" :
                "bg-slate-100 opacity-0 group-hover:opacity-100"
            )} />

            <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-2">
                    <div className={cn(
                        "w-2 h-2 rounded-full flex-shrink-0",
                        isActive ? "bg-emerald-500 shadow-[0_0_6px_rgba(16,185,129,0.5)] animate-pulse" :
                        isJoining ? "bg-blue-500 shadow-[0_0_6px_rgba(59,130,246,0.5)]" :
                        "bg-slate-300"
                    )} />
                    <span className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                        {status}
                    </span>
                </div>
                <div className="flex items-center gap-1.5 text-slate-400 text-[10px] font-semibold bg-slate-50 px-2 py-0.5 rounded-full border border-slate-100">
                    <Clock className="w-3 h-3" />
                    {timeLabel}
                </div>
            </div>

            <h3 className="text-[14px] font-bold text-slate-800 mb-5 group-hover:text-primary transition-colors leading-tight capitalize">{title}</h3>

            <div className="space-y-3">
                <div className="flex justify-between items-center text-xs">
                    <div className="flex items-center gap-1.5 text-slate-500 font-medium">
                        <div className="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center">
                            <Users className="w-3 h-3" />
                        </div>
                        <span>{attendanceCount} Students</span>
                    </div>
                    <span className={cn(
                        "font-bold text-[11px]",
                        progress > 50 ? "text-emerald-500" : "text-primary"
                    )}>{Math.round(progress)}%</span>
                </div>
                <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
                    <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                        className={cn(
                            "h-full rounded-full",
                            isActive ? "bg-gradient-to-r from-emerald-400 to-teal-500" :
                            isJoining ? "bg-gradient-to-r from-blue-400 to-indigo-500" :
                            "bg-primary"
                        )}
                    />
                </div>
            </div>
        </motion.div>
    );
};

const AdminDashboard = () => {
    const navigate = useNavigate();
    const [liveSessions, setLiveSessions] = useState<any[]>([]);

    useEffect(() => {
        const fetchSessions = async () => {
            try {
                const response = await api.get('/hall-qr-tokens');
                const tokens = response.data;
                const filtered = tokens.filter((t: any) =>
                    ['CREATED', 'JOINING', 'PROGRESS', 'ACTIVE'].includes(t.session_status)
                );
                setLiveSessions(filtered);
            } catch (error) {
                console.error("Failed to fetch sessions", error);
            }
        };
        fetchSessions();
        const interval = setInterval(fetchSessions, 10000);
        return () => clearInterval(interval);
    }, []);

    const activeCount = liveSessions.length;
    const totalParticipants = liveSessions.reduce((acc, curr) => acc + (curr.scan_count || 0), 0);
    const joiningCount = liveSessions.filter(s => s.session_status === 'JOINING').length;

    const now = new Date();
    const hour = now.getHours();
    const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return (
        <div className="space-y-8 pb-10 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {/* Welcome Banner */}
            <div className="relative overflow-hidden bg-gradient-to-br from-primary to-blue-700 p-7 rounded-2xl text-white shadow-lg shadow-primary/20">
                <div className="absolute inset-0 opacity-10"
                    style={{ backgroundImage: 'radial-gradient(circle at 10% 50%, white 1px, transparent 1px), radial-gradient(circle at 90% 20%, white 1px, transparent 1px)', backgroundSize: '40px 40px' }}
                />
                <div className="relative flex flex-col md:flex-row justify-between md:items-center gap-6">
                    <div>
                        <p className="text-blue-200 text-xs font-semibold tracking-wider uppercase mb-1">{greeting}</p>
                        <h1 className="text-2xl font-black tracking-tight text-white mb-1">System Overview</h1>
                        <p className="text-blue-200 text-sm font-medium">Real-time activity management & engagement analytics</p>
                    </div>
                    <div className="flex gap-6">
                        <div className="text-center bg-white/10 backdrop-blur-sm rounded-xl px-5 py-3 border border-white/10">
                            <p className="text-3xl font-black text-white">{activeCount}</p>
                            <p className="text-[9px] font-bold text-blue-200 uppercase tracking-wider mt-0.5">Live Sessions</p>
                        </div>
                        <div className="text-center bg-white/10 backdrop-blur-sm rounded-xl px-5 py-3 border border-white/10">
                            <p className="text-3xl font-black text-white">{totalParticipants}</p>
                            <p className="text-[9px] font-bold text-blue-200 uppercase tracking-wider mt-0.5">Participants</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Quick Stats Row */}
            <div className="grid grid-cols-3 gap-4">
                {[
                    { label: 'Active Sessions', value: activeCount, icon: Activity, color: 'text-emerald-500', bg: 'bg-emerald-50', trend: 'Live now' },
                    { label: 'Joining', value: joiningCount, icon: Zap, color: 'text-blue-500', bg: 'bg-blue-50', trend: 'In queue' },
                    { label: 'Participants', value: totalParticipants, icon: TrendingUp, color: 'text-purple-500', bg: 'bg-purple-50', trend: 'Total scanned' },
                ].map((stat, i) => (
                    <motion.div
                        key={stat.label}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.08 }}
                        className="stat-card"
                    >
                        <div className="flex items-center justify-between mb-3">
                            <div className={`w-8 h-8 ${stat.bg} rounded-lg flex items-center justify-center`}>
                                <stat.icon className={`w-4 h-4 ${stat.color}`} />
                            </div>
                            <span className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">{stat.trend}</span>
                        </div>
                        <p className="text-2xl font-black text-slate-800">{stat.value}</p>
                        <p className="text-[10px] font-semibold text-slate-400 mt-0.5">{stat.label}</p>
                    </motion.div>
                ))}
            </div>

            {/* Live Session Monitor */}
            <div className="space-y-4">
                <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2.5">
                        <div className="p-1.5 bg-primary/10 rounded-lg">
                            <Activity className="w-4 h-4 text-primary" />
                        </div>
                        <h2 className="text-base font-bold text-slate-800">Live Session Monitor</h2>
                        {activeCount > 0 && (
                            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                        )}
                    </div>
                    <button
                        onClick={() => navigate('sessions')}
                        className="text-primary text-[11px] font-bold hover:bg-primary/5 px-3 py-1.5 rounded-lg transition-colors flex items-center gap-1.5"
                    >
                        View All <ArrowUpRight className="w-3.5 h-3.5" />
                    </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {liveSessions.length === 0 ? (
                        <div className="col-span-full bg-white border border-slate-100 border-dashed p-14 rounded-xl text-center">
                            <div className="w-11 h-11 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4 ring-4 ring-slate-50">
                                <Activity className="w-5 h-5 text-slate-200" />
                            </div>
                            <p className="text-slate-500 font-semibold text-sm">No active sessions right now</p>
                            <p className="text-slate-300 text-xs mt-1">Sessions will appear here once initiated.</p>
                        </div>
                    ) : (
                        liveSessions.map((session, idx) => (
                            <SessionCard
                                key={session.token_id || idx}
                                token={session}
                                index={idx}
                                onClick={() => navigate('sessions')}
                            />
                        ))
                    )}
                </div>
            </div>
        </div>
    );
};

export default AdminDashboard;
