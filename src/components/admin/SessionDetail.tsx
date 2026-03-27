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

    const attendancePercent = Math.round((session.attendance / session.enrolled) * 100);
    const formationPercent = Math.round((session.teams / session.totalTeams) * 100);
    const valuationPercent = Math.round((session.peerRatings / session.totalTables) * 100);

    const metrics = [
        {
            icon: Users,
            label: 'Attendance',
            value: `${attendancePercent}%`,
            detail: `${session.attendance} of ${session.enrolled}`,
            percent: attendancePercent,
            color: 'emerald',
            barClass: 'bg-emerald-500',
            iconBg: 'bg-emerald-50 text-emerald-500',
        },
        {
            icon: CheckCircle2,
            label: 'Formation',
            value: `${session.teams}/${session.totalTeams}`,
            detail: `${session.totalTeams - session.teams} remaining`,
            percent: formationPercent,
            color: 'blue',
            barClass: 'bg-blue-500',
            iconBg: 'bg-blue-50 text-blue-500',
        },
        {
            icon: ArrowUpRight,
            label: 'Valuations',
            value: `${valuationPercent}%`,
            detail: `${session.peerRatings} of ${session.totalTables} tables`,
            percent: valuationPercent,
            color: 'amber',
            barClass: 'bg-amber-500',
            iconBg: 'bg-amber-50 text-amber-500',
        },
    ];

    return (
        <div className="min-h-screen">
            {/* Clean Navigation Header */}
            <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-xl border-b border-slate-100 px-6 py-3.5 flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <motion.button
                        whileHover={{ x: -2 }}
                        onClick={() => navigate(-1)}
                        className="flex items-center gap-1.5 text-slate-400 hover:text-slate-800 transition-colors text-xs font-semibold"
                    >
                        <ChevronLeft className="w-4 h-4" />
                        Back
                    </motion.button>

                    <div className="h-4 w-px bg-slate-200" />

                    <div>
                        <div className="flex items-center gap-2.5">
                            <h1 className="text-base font-bold text-slate-800 leading-none">{session.title}</h1>
                            <span className="px-1.5 py-0.5 rounded bg-emerald-50 text-emerald-600 text-[8px] font-bold uppercase tracking-wider border border-emerald-100">
                                Live
                            </span>
                        </div>
                        <p className="text-[10px] font-medium text-slate-400 mt-0.5">
                            {session.hall} · #{session.id}
                        </p>
                    </div>
                </div>

                <div className="flex items-center gap-2">
                    <button className="px-3.5 py-1.5 rounded-lg bg-white border border-slate-200 text-[10px] font-bold text-slate-500 uppercase tracking-wider hover:bg-slate-50 transition-all">
                        Export
                    </button>
                    <button className="p-1.5 text-slate-300 hover:text-slate-600 transition-colors rounded-lg hover:bg-slate-50">
                        <MoreHorizontal className="w-4 h-4" />
                    </button>
                </div>
            </header>

            <main className="max-w-5xl mx-auto px-6 py-6 space-y-6">
                {/* Pending Action Alert */}
                <motion.div
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="p-5 rounded-2xl bg-gradient-to-r from-orange-50 to-orange-100/50 border border-orange-200 flex items-center justify-between shadow-sm"
                >
                    <div className="flex items-center gap-3.5">
                        <div className="w-9 h-9 rounded-lg bg-orange-100 flex items-center justify-center text-orange-500">
                            <Clock className="w-4 h-4" />
                        </div>
                        <div>
                            <h4 className="text-sm font-bold text-slate-800 leading-none mb-0.5">2 Students Pending Entry</h4>
                            <p className="text-[10px] font-medium text-slate-500">Manual approval required for Table 04</p>
                        </div>
                    </div>
                    <button className="px-4 py-2 rounded-lg bg-orange-500 text-white text-[10px] font-bold uppercase tracking-wider shadow-sm hover:bg-orange-600 active:scale-95 transition-all">
                        Review
                    </button>
                </motion.div>

                {/* Metrics Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {metrics.map((m, i) => (
                        <motion.div
                            key={m.label}
                            initial={{ opacity: 0, y: 12 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.08 }}
                            className="stat-card"
                        >
                            <div className="flex items-center justify-between mb-3">
                                <div className="flex items-center gap-2">
                                    <div className={`w-8 h-8 rounded-lg ${m.iconBg} flex items-center justify-center`}>
                                        <m.icon className="w-4 h-4" />
                                    </div>
                                    <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{m.label}</span>
                                </div>
                            </div>
                            <h3 className="text-2xl font-black text-slate-800 tracking-tight mb-1">{m.value}</h3>
                            <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden mb-2">
                                <motion.div
                                    initial={{ width: 0 }}
                                    animate={{ width: `${m.percent}%` }}
                                    transition={{ duration: 0.8, ease: "easeOut" }}
                                    className={`h-full rounded-full ${m.barClass}`}
                                />
                            </div>
                            <p className="text-[10px] font-medium text-slate-400">{m.detail}</p>
                        </motion.div>
                    ))}
                </div>

                {/* Supervisor Section */}
                <div className="space-y-3">
                    <h2 className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Supervisors</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                        {[
                            { name: "Mike Ross", role: "Primary Session Monitor", status: "Active", img: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=150" }
                        ].map((staff, i) => (
                            <div
                                key={i}
                                className="glass-card flex items-center justify-between p-5 rounded-2xl group transition-all"
                            >
                                <div className="flex items-center gap-3.5">
                                    <div className="relative">
                                        <div className="w-11 h-11 rounded-xl overflow-hidden bg-slate-100 border-2 border-white shadow-sm">
                                            <img src={staff.img} className="w-full h-full object-cover" alt="" />
                                        </div>
                                        <div className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-emerald-500 border-2 border-white rounded-full" />
                                    </div>
                                    <div>
                                        <h4 className="text-sm font-bold text-slate-800">{staff.name}</h4>
                                        <p className="text-[10px] font-medium text-slate-400">{staff.role}</p>
                                    </div>
                                </div>
                                <span className="text-[9px] font-bold text-emerald-600 uppercase tracking-wider py-1 px-2.5 bg-emerald-50 rounded-md border border-emerald-100">
                                    {staff.status}
                                </span>
                            </div>
                        ))}
                    </div>
                </div>
            </main>

            <footer className="py-8 flex flex-col items-center gap-3">
                <div className="h-px w-8 bg-slate-200" />
                <button className="flex items-center gap-1.5 text-slate-300 hover:text-primary transition-colors text-[9px] font-bold uppercase tracking-wider group">
                    <ClipboardList className="w-3.5 h-3.5" />
                    Archive Logs
                </button>
            </footer>
        </div>
    );
};
