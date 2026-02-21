import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Plus,
    Search,
    MoreVertical,
    QrCode,
    Users,
    Calendar,
    ChevronRight,
    Zap,
    Loader2
} from 'lucide-react';
import { CreateSessionModal } from '../../components/admin/CreateSessionModal';

const SessionManager = () => {
    const navigate = useNavigate();
    const [showCreate, setShowCreate] = useState(false);
    const [sessionList, setSessionList] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Helper function to determine the final status
    const determineStatus = (token: any) => {
        // If backend says INACTIVE manually (e.g. cancelled), return Inactive
        if (token.status === 'INACTIVE') return 'Inactive';

        // 1. Parsing Start Time
        // token.start_time is "HH:MM" string. token.createdAt is ISO Date string.
        // We assume session is for "Today" if start_time is just time. 
        // OR better: use createdAt's date combined with start_time's time.

        const createdDate = new Date(token.createdAt);
        let startDate = new Date(createdDate); // Clone date

        if (token.start_time && token.start_time.includes(':')) {
            const [hours, minutes] = token.start_time.split(':').map(Number);
            startDate.setHours(hours, minutes, 0, 0);

            // Edge case: If start time is earlier than created time (e.g. created at 9:05 for 9:00 start), 
            // it means it started immediately or slightly in past. 
            // If created yesterday for today? Unlikely in this MVP. 
            // Assume "Today" based on createdDate.
        } else {
            // Fallback if no start_time string
            startDate = createdDate;
        }

        // 2. Duration Config
        const totalDurationMinutes = token.expires_in_minutes || 60;
        const joiningDurationMinutes = 5; // Fixed joining window (5 mins)

        // 3. Current Time
        const now = new Date();

        // 4. Status Logic
        if (now < startDate) {
            return 'Active'; // Scheduled / Coming Up
        }

        const minutesSinceStart = (now.getTime() - startDate.getTime()) / 60000;

        if (minutesSinceStart < joiningDurationMinutes) {
            return 'Joining'; // Within the first 10 mins
        }

        if (minutesSinceStart < totalDurationMinutes) {
            return 'InProgress'; // After joining, before expiry
        }

        return 'Completed'; // After expiry
    };

    const fetchSessions = async () => {
        try {
            setLoading(true);
            const response = await fetch('http://localhost:8080/api/hall-qr-tokens');
            if (!response.ok) throw new Error('Failed to synchronize tokens');
            const data = await response.json();

            // Map backend HallQrToken to frontend Session format
            const mapped = data.map((token: any) => ({
                id: `T-${token.token_id}`,
                type: token.hall_qr_token,
                level: 'System Sync',
                students: token.scan_count || 0,
                status: determineStatus(token),
                time: token.start_time || new Date(token.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
            }));

            setSessionList(mapped);
            setError(null);
        } catch (err: any) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSessions();
        const interval = setInterval(fetchSessions, 30000); // Auto-refresh status every 30s
        return () => clearInterval(interval);
    }, []);

    const handleCreateSession = (newSession: any) => {
        setSessionList(prev => [newSession, ...prev]);
    };

    const [filter, setFilter] = useState('All');

    // Filter sessions based on selected tab
    const filteredSessions = sessionList.filter(session => {
        if (filter === 'All') return true; // Show all sessions
        if (filter === 'Active') return session.status === 'Active';
        if (filter === 'Joining') return session.status === 'Joining';
        if (filter === 'InProgress') return session.status === 'InProgress';
        if (filter === 'Completed') return session.status === 'Completed';
        return true;
    }).sort((a, b) => {
        // Custom sort order: Active/Joining/InProgress first (order by time if needed?), Completed last
        if (a.status === 'Completed' && b.status !== 'Completed') return 1;
        if (a.status !== 'Completed' && b.status === 'Completed') return -1;

        // Secondary sort: Time? For now just keep existing order (likely created desc)
        // Actually backend returns recent first? Let's assume input list is sorted by date/time
        return 0;
    });

    const tabs = [
        { id: 'All', label: 'All Activities', count: sessionList.length, color: 'text-indigo-600 bg-indigo-50 border-indigo-100' },
        { id: 'InProgress', label: 'Progress Activity', count: sessionList.filter(s => s.status === 'InProgress').length, color: 'text-blue-600 bg-blue-50 border-blue-100' },
        { id: 'Active', label: 'Created Activity', count: sessionList.filter(s => s.status === 'Active').length, color: 'text-emerald-600 bg-emerald-50 border-emerald-100' },
        { id: 'Joining', label: 'Joining', count: sessionList.filter(s => s.status === 'Joining').length, color: 'text-orange-600 bg-orange-50 border-orange-100' },
        { id: 'Completed', label: 'Past Activity', count: sessionList.filter(s => s.status === 'Completed').length, color: 'text-slate-600 bg-slate-50 border-slate-200' },
    ];

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {showCreate && (
                <CreateSessionModal
                    onClose={() => setShowCreate(false)}
                    onExecute={handleCreateSession}
                />
            )}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-xl font-black text-slate-800 tracking-tight leading-none mb-1">Session Manager</h1>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none">Activity Orchestration</p>
                </div>
                <div className="flex items-center gap-3">
                    <button className="p-2.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all">
                        <Search className="w-5 h-5" />
                    </button>
                    <button
                        onClick={() => setShowCreate(true)}
                        className="px-5 py-2.5 bg-primary text-white rounded-xl font-black text-[10px] uppercase tracking-widest flex items-center gap-2 shadow-lg shadow-primary/20 transition-all active:scale-95"
                    >
                        <Plus className="w-4 h-4" />
                        <span>New Session</span>
                    </button>
                </div>
            </div>

            {/* Premium Tab Toggle */}
            <div className="p-1.5 bg-white/60 border border-slate-100 rounded-2xl overflow-x-auto">
                <div className="flex gap-1 min-w-max">
                    {tabs.map((tab) => (
                        <button
                            key={tab.id}
                            onClick={() => setFilter(tab.id)}
                            className={`flex items-center gap-2.5 px-4 py-2.5 rounded-xl text-[11px] font-bold uppercase tracking-wider transition-all duration-300 border ${filter === tab.id
                                ? `bg-white shadow-md shadow-slate-200/50 ${tab.color.replace('bg-', 'border-').split(' ')[2] || 'border-slate-200'} scale-100`
                                : 'border-transparent text-slate-400 hover:text-slate-600 hover:bg-slate-50'
                                }`}
                        >
                            <span className={filter === tab.id ? 'text-slate-900' : ''}>{tab.label}</span>
                            <span className={`px-1.5 py-0.5 rounded text-[9px] font-black ${filter === tab.id ? tab.color : 'bg-slate-100 text-slate-400'
                                }`}>
                                {tab.count}
                            </span>
                        </button>
                    ))}
                </div>
            </div>

            <div className="grid grid-cols-1 gap-3">
                {loading ? (
                    <div className="flex flex-col items-center justify-center py-20 bg-white/40 rounded-3xl border border-slate-100/50 backdrop-blur-sm">
                        <Loader2 className="w-8 h-8 text-primary animate-spin mb-4" />
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Bridging API Surface...</p>
                    </div>
                ) : error ? (
                    <div className="flex flex-col items-center justify-center py-20 bg-white/40 rounded-3xl border border-red-100 backdrop-blur-sm">
                        <Zap className="w-8 h-8 text-red-400 mb-4 opacity-50" />
                        <p className="text-[10px] font-black text-red-500 uppercase tracking-widest mb-1">API Handshake Failed</p>
                        <p className="text-[8px] font-bold text-slate-400 uppercase tracking-widest">{error}</p>
                    </div>
                ) : filteredSessions.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 bg-white/40 rounded-3xl border border-dashed border-slate-200 backdrop-blur-sm">
                        <QrCode className="w-8 h-8 text-slate-200 mb-4" />
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">
                            No {filter} Sessions<br />
                            <span className="text-[8px] font-bold mt-1 block">Check other tabs or create a new session</span>
                        </p>
                    </div>
                ) : (
                    filteredSessions.map((session) => {
                        const isClickable = true;

                        return (
                            <div
                                key={session.id}
                                onClick={() => {
                                    if (isClickable) {
                                        navigate(`/admin/session-detail/${session.id}`, { state: { status: session.status } });
                                    } else {
                                        alert(`Cannot access session: Session is ${session.status}`);
                                    }
                                }}
                                className={`glass-card group p-5 rounded-2xl border border-slate-100/50 transition-all bg-white/70 ${isClickable
                                    ? 'hover:border-primary/20 cursor-pointer'
                                    : 'opacity-60 cursor-not-allowed'
                                    }`}
                            >
                                <div className="flex items-center gap-5">
                                    <div className="w-12 h-12 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center flex-shrink-0 group-hover:bg-primary/5 transition-colors">
                                        <QrCode className="w-6 h-6 text-slate-400 group-hover:text-primary transition-colors" />
                                    </div>

                                    <div className="flex-1 grid grid-cols-2 md:grid-cols-4 gap-4">
                                        <div>
                                            <h4 className="font-black text-sm text-slate-800 leading-none mb-1.5">{session.type}</h4>
                                            <div className="flex items-center gap-1.5 text-[8px] font-black text-primary uppercase tracking-widest">
                                                <Zap className="w-2.5 h-2.5" />
                                                {session.level}
                                            </div>
                                        </div>

                                        <div className="flex flex-col justify-center">
                                            <div className="flex items-center gap-2 text-slate-400 text-[10px] font-bold">
                                                <Users className="w-3.5 h-3.5" />
                                                <span>{session.students} Scans</span>
                                            </div>
                                        </div>

                                        <div className="flex flex-col justify-center">
                                            <div className="flex items-center gap-2 text-slate-400 text-[10px] font-bold">
                                                <Calendar className="w-3.5 h-3.5" />
                                                <span>{session.time} Time</span>
                                            </div>
                                        </div>

                                        <div className="flex items-center justify-end md:pr-4">
                                            <span className={`px-2.5 py-0.5 rounded-lg text-[8px] font-black uppercase tracking-widest border ${session.status === 'Joining' ? 'bg-orange-50 text-orange-600 border-orange-100' :
                                                session.status === 'InProgress' ? 'bg-blue-50 text-blue-600 border-blue-100' :
                                                    session.status === 'Completed' ? 'bg-slate-100 text-slate-600 border-slate-200' :
                                                        session.status === 'Active' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' :
                                                            'bg-slate-50 text-slate-400 border-slate-100'
                                                }`}>
                                                {session.status}
                                            </span>
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-1">
                                        <button className="p-2 hover:bg-slate-50 rounded-lg transition-colors">
                                            <MoreVertical className="w-4 h-4 text-slate-300" />
                                        </button>
                                        <ChevronRight className="w-4 h-4 text-slate-300 group-hover:translate-x-1 transition-transform" />
                                    </div>
                                </div>
                            </div>
                        );
                    })
                )}
            </div>
        </div>
    );
};

export default SessionManager;
