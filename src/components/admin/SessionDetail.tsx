import React from 'react';
import { motion } from 'framer-motion';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronLeft,
    MoreHorizontal,
    Clock,
    Users,
    CheckCircle2,
    ArrowUpRight,
    ClipboardList
} from 'lucide-react';

// Mock data fetcher
const fetchSessionData = (id: string) => {
    return {
        id: id || '0001',
        title: id === '0002' ? "UX Lab Session" : "CS101 Finals",
        hall: id === '0002' ? "Block C" : "Hall A",
        attendance: id === '0002' ? 15 : 36,
        enrolled: id === '0002' ? 30 : 40,
        teams: id === '0002' ? 12 : 18,
        totalTeams: id === '0002' ? 30 : 20,
        peerRatings: id === '0002' ? 0 : 12,
        totalTables: id === '0002' ? 15 : 20
    };
};

export const SessionDetail: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const session = fetchSessionData(id || '');

    return (
        <div className="relative min-h-screen bg-slate-50/50 overflow-x-hidden">
            {/* --- Premium Background Effects --- */}
            <div className="fixed inset-0 pointer-events-none -z-10">
                <motion.div
                    animate={{ x: [0, 80, 0], y: [0, 40, 0], rotate: 360 }}
                    transition={{ duration: 25, repeat: Infinity, ease: "linear" }}
                    className="absolute -top-60 -left-60 w-[800px] h-[800px] bg-primary/5 rounded-full blur-[120px]"
                />
                <motion.div
                    animate={{ x: [0, -60, 0], y: [0, -30, 0], rotate: -360 }}
                    transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
                    className="absolute bottom-1/4 -right-40 w-[600px] h-[600px] bg-blue-400/5 rounded-full blur-[100px]"
                />
            </div>

            {/* --- Navigation Header --- */}
            <header className="sticky top-0 z-50 bg-white/40 backdrop-blur-3xl border-b border-white px-8 py-5 flex items-center justify-between">
                <div className="flex items-center gap-8">
                    <motion.button
                        whileHover={{ x: -2 }}
                        onClick={() => navigate(-1)}
                        className="flex items-center gap-2 text-slate-400 hover:text-slate-900 transition-all font-black text-[9px] uppercase tracking-[0.2em]"
                    >
                        <ChevronLeft className="w-4 h-4" />
                        Back
                    </motion.button>

                    <div className="h-5 w-px bg-slate-200 hidden md:block" />

                    <div>
                        <div className="flex items-center gap-3 mb-0.5">
                            <h1 className="text-xl font-black text-slate-800 tracking-tight leading-none">{session.title}</h1>
                            <div className="px-1.5 py-0.5 rounded-md bg-emerald-500/10 text-emerald-600 text-[8px] font-black uppercase tracking-widest border border-emerald-500/10">Live</div>
                        </div>
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">
                            {session.hall} • Session ID: #{session.id}
                        </p>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <button className="px-5 py-2 rounded-xl bg-white border border-slate-100 text-[9px] font-black text-slate-500 uppercase tracking-widest hover:bg-slate-50 transition-all shadow-sm">
                        Export Data
                    </button>
                    <button className="p-2 text-slate-300 hover:text-slate-600 transition-all">
                        <MoreHorizontal className="w-5 h-5" />
                    </button>
                </div>
            </header>

            <main className="max-w-5xl mx-auto px-8 py-8 space-y-10">
                {/* --- Focal Alert --- */}
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="p-6 rounded-2xl bg-white border border-white shadow-[0_4px_25px_rgba(0,0,0,0.02)] flex items-center justify-between group cursor-pointer hover:shadow-lg transition-all"
                >
                    <div className="flex items-center gap-5">
                        <div className="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center text-orange-500">
                            <Clock className="w-5 h-5" />
                        </div>
                        <div>
                            <h4 className="text-base font-black text-slate-900 leading-none mb-1.5">2 Students Pending Entry</h4>
                            <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">Manual approval required for Table 04</p>
                        </div>
                    </div>
                    <button className="px-6 py-2.5 rounded-xl bg-orange-500 text-white text-[9px] font-black uppercase tracking-widest shadow-lg shadow-orange-500/20 hover:scale-105 transition-all">
                        Review Access
                    </button>
                </motion.div>

                {/* --- Grid Data HUD --- */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div className="space-y-4 group">
                        <div className="flex items-center gap-2 text-slate-300 group-hover:text-emerald-500 transition-colors">
                            <Users className="w-4 h-4" />
                            <span className="text-[9px] font-black uppercase tracking-[0.2em]">Attendance</span>
                        </div>
                        <div className="space-y-2">
                            <h3 className="text-3xl font-black text-slate-800 tracking-tight">{Math.round((session.attendance / session.enrolled) * 100)}%</h3>
                            <div className="h-1 w-full bg-slate-100 rounded-full overflow-hidden">
                                <motion.div
                                    initial={{ width: 0 }}
                                    animate={{ width: `${(session.attendance / session.enrolled) * 100}%` }}
                                    className="h-full bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.2)]"
                                />
                            </div>
                            <div className="flex justify-between text-[9px] font-black text-slate-400 uppercase tracking-widest">
                                <span>{session.attendance} PRESENT</span>
                                <span>{session.enrolled} TOTAL</span>
                            </div>
                        </div>
                    </div>

                    <div className="space-y-4 group">
                        <div className="flex items-center gap-2 text-slate-300 group-hover:text-blue-500 transition-colors">
                            <CheckCircle2 className="w-4 h-4" />
                            <span className="text-[9px] font-black uppercase tracking-[0.2em]">Formation</span>
                        </div>
                        <div className="space-y-2">
                            <h3 className="text-3xl font-black text-slate-800 tracking-tight">{session.teams}/{session.totalTeams}</h3>
                            <div className="h-1 w-full bg-slate-100 rounded-full overflow-hidden">
                                <motion.div
                                    initial={{ width: 0 }}
                                    animate={{ width: `${(session.teams / session.totalTeams) * 100}%` }}
                                    className="h-full bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,0.2)]"
                                />
                            </div>
                            <div className="flex justify-between text-[9px] font-black text-slate-400 uppercase tracking-widest">
                                <span>STABLE SYNC</span>
                                <span>{session.totalTeams - session.teams} LEFT</span>
                            </div>
                        </div>
                    </div>

                    <div className="space-y-4 group">
                        <div className="flex items-center gap-2 text-slate-300 group-hover:text-orange-500 transition-colors">
                            <ArrowUpRight className="w-4 h-4" />
                            <span className="text-[9px] font-black uppercase tracking-[0.2em]">Valuations</span>
                        </div>
                        <div className="space-y-2">
                            <h3 className="text-3xl font-black text-slate-800 tracking-tight">{Math.round((session.peerRatings / session.totalTables) * 100)}%</h3>
                            <div className="h-1 w-full bg-slate-100 rounded-full overflow-hidden">
                                <motion.div
                                    initial={{ width: 0 }}
                                    animate={{ width: `${(session.peerRatings / session.totalTables) * 100}%` }}
                                    className="h-full bg-orange-400 shadow-[0_0_10px_rgba(251,146,60,0.2)]"
                                />
                            </div>
                            <div className="flex justify-between text-[9px] font-black text-slate-400 uppercase tracking-widest">
                                <span>AUTOMATED</span>
                                <span>{session.peerRatings}/{session.totalTables} TABLES</span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* --- Personnel Section --- */}
                <div className="space-y-8 pt-4">
                    <h2 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em]">Section Supervisors</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {[
                            { name: "Mike Ross", role: "Primary Session Monitor", status: "Active System", img: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=150" }
                        ].map((staff, i) => (
                            <div
                                key={i}
                                className="flex items-center justify-between p-6 rounded-[2rem] bg-white border border-white shadow-[0_2px_20px_rgba(0,0,0,0.02)] hover:shadow-lg transition-all"
                            >
                                <div className="flex items-center gap-6">
                                    <div className="relative">
                                        <div className="w-16 h-16 rounded-[1.5rem] overflow-hidden bg-slate-100 border-4 border-slate-50">
                                            <img src={staff.img} className="w-full h-full object-cover grayscale brightness-105" alt="" />
                                        </div>
                                        <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-emerald-500 border-4 border-white rounded-full shadow-lg" />
                                    </div>
                                    <div>
                                        <h4 className="text-lg font-black text-slate-900 mb-0.5">{staff.name}</h4>
                                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{staff.role}</p>
                                    </div>
                                </div>
                                <span className="text-[9px] font-black text-emerald-500 uppercase tracking-widest py-1.5 px-4 bg-emerald-50 rounded-full border border-emerald-100">
                                    {staff.status}
                                </span>
                            </div>
                        ))}
                    </div>
                </div>
            </main>

            <footer className="py-12 flex flex-col items-center gap-4">
                <div className="h-px w-10 bg-slate-200" />
                <button className="flex items-center gap-2 text-slate-300 hover:text-primary transition-all text-[9px] font-black uppercase tracking-[0.2em] group">
                    <ClipboardList className="w-4 h-4 group-hover:scale-110 transition-transform" />
                    Archive Logs
                </button>
            </footer>
        </div>
    );
};
