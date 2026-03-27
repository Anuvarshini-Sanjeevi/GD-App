import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Plus,
    Search,
    QrCode,
    Users,
    Calendar,
    Zap,
    Loader2,
    RefreshCw
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { CreateSessionModal } from '../../components/admin/CreateSessionModal';
import api, { getCurrentUser } from '../../utils/api';

const SessionManager = () => {
    const navigate = useNavigate();
    const [showCreate, setShowCreate] = useState(false);
    const [sessionList, setSessionList] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [filter, setFilter] = useState('All');
    const [searchQuery, setSearchQuery] = useState('');
    const [refreshing, setRefreshing] = useState(false);

    const determineStatus = (token: any) => {
        if (token.status === 'INACTIVE') return 'Inactive';
        const createdDate = new Date(token.createdAt);
        let startDate = new Date(createdDate);
        if (token.start_time && token.start_time.includes(':')) {
            const [hours, minutes] = token.start_time.split(':').map(Number);
            startDate.setHours(hours, minutes, 0, 0);
        } else {
            startDate = createdDate;
        }
        const totalDurationMinutes = token.expires_in_minutes || 60;
        const joiningDurationMinutes = 5;
        const now = new Date();
        if (now < startDate) return 'Active';
        const minutesSinceStart = (now.getTime() - startDate.getTime()) / 60000;
        if (minutesSinceStart < joiningDurationMinutes) return 'Joining';
        if (minutesSinceStart < totalDurationMinutes) return 'InProgress';
        return 'Completed';
    };

    const fetchSessions = async (isManual = false) => {
        try {
            if (isManual) setRefreshing(true);
            else setLoading(true);

            const user = getCurrentUser();
            const adminId = user?.admin_id || 78;
            const response = await api.get('/hall-qr-tokens', {
                params: { created_by_admin_id: adminId }
            });
            const data = response.data;

            const mapped = data.map((token: any) => {
                const createdDate = new Date(token.createdAt);
                let displayTime = '';
                const startTime = token.start_time;
                if (startTime) {
                    const parsedDate = new Date(startTime);
                    if (!isNaN(parsedDate.getTime())) {
                        displayTime = parsedDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    } else if (startTime.includes(':')) {
                        const parts = startTime.split(':').map(Number);
                        if (parts.length >= 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
                            const date = new Date();
                            date.setHours(parts[0], parts[1], 0, 0);
                            displayTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                        }
                    }
                }
                if (!displayTime) {
                    displayTime = createdDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                }
                const displayDate = createdDate.toLocaleDateString([], { month: 'short', day: 'numeric' });

                return {
                    id: `T-${token.token_id}`,
                    type: token.hall_qr_token,
                    level: token.sessionConfig?.complexity_level || 'L1',
                    supervisor: token.supervisor?.name || 'Unassigned',
                    students: token.scan_count || 0,
                    status: token.session_status || determineStatus(token),
                    time: `${displayDate} at ${displayTime}`,
                    date: displayDate,
                    displayTime,
                    start_mode: token.start_mode,
                    duration: token.expires_in_minutes || 60,
                };
            });

            setSessionList(mapped);
            setError(null);
        } catch (err: any) {
            setError(err.message || 'Failed to load sessions');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    useEffect(() => {
        fetchSessions();
        const interval = setInterval(() => fetchSessions(), 30000);
        return () => clearInterval(interval);
    }, []);

    const handleCreateSession = () => {
        fetchSessions();
        setShowCreate(false);
    };

    // Status config
    const statusConfig: Record<string, { label: string; dot: string; badge: string }> = {
        'Active':      { label: 'Scheduled',   dot: 'bg-emerald-400',  badge: 'bg-emerald-50 text-emerald-700 ring-emerald-200' },
        'CREATED':     { label: 'Scheduled',   dot: 'bg-emerald-400',  badge: 'bg-emerald-50 text-emerald-700 ring-emerald-200' },
        'Joining':     { label: 'Joining',     dot: 'bg-amber-400 animate-pulse', badge: 'bg-amber-50 text-amber-700 ring-amber-200' },
        'JOINING':     { label: 'Joining',     dot: 'bg-amber-400 animate-pulse', badge: 'bg-amber-50 text-amber-700 ring-amber-200' },
        'InProgress':  { label: 'In Progress', dot: 'bg-blue-500 animate-pulse',  badge: 'bg-blue-50 text-blue-700 ring-blue-200' },
        'PROGRESS':    { label: 'In Progress', dot: 'bg-blue-500 animate-pulse',  badge: 'bg-blue-50 text-blue-700 ring-blue-200' },
        'Completed':   { label: 'Completed',   dot: 'bg-slate-300',    badge: 'bg-slate-50 text-slate-500 ring-slate-200' },
        'COMPLETED':   { label: 'Completed',   dot: 'bg-slate-300',    badge: 'bg-slate-50 text-slate-500 ring-slate-200' },
        'Inactive':    { label: 'Inactive',    dot: 'bg-red-400',      badge: 'bg-red-50 text-red-600 ring-red-200' },
    };

    const getStatusConfig = (status: string) =>
        statusConfig[status] || { label: status, dot: 'bg-slate-300', badge: 'bg-slate-50 text-slate-500 ring-slate-200' };

    const isPastSession = (status: string) =>
        status === 'Completed' || status === 'COMPLETED' || status === 'Inactive';

    const tabs = [
        { id: 'All',        label: 'ALL ACTIVITIES',        count: sessionList.length },
        { id: 'InProgress', label: 'PROGRESS ACTIVITY', count: sessionList.filter(s => s.status === 'InProgress' || s.status === 'PROGRESS').length },
        { id: 'Active',     label: 'CREATED ACTIVITY',   count: sessionList.filter(s => s.status === 'Active' || s.status === 'CREATED').length },
        { id: 'Joining',    label: 'JOINING',     count: sessionList.filter(s => s.status === 'Joining' || s.status === 'JOINING').length },
        { id: 'Completed',  label: 'PAST ACTIVITY',   count: sessionList.filter(s => s.status === 'Completed' || s.status === 'COMPLETED' || s.status === 'Inactive').length },
    ];

    const filteredSessions = sessionList.filter(session => {
        const matchesFilter =
            filter === 'All' ? true :
            filter === 'Active' ? (session.status === 'Active' || session.status === 'CREATED') :
            filter === 'Joining' ? (session.status === 'Joining' || session.status === 'JOINING') :
            filter === 'InProgress' ? (session.status === 'InProgress' || session.status === 'PROGRESS') :
            filter === 'Completed' ? (session.status === 'Completed' || session.status === 'COMPLETED' || session.status === 'Inactive') :
            true;

        const matchesSearch = !searchQuery ||
            session.type?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            session.supervisor?.toLowerCase().includes(searchQuery.toLowerCase());

        return matchesFilter && matchesSearch;
    }).sort((a, b) => {
        const order: Record<string, number> = { 'InProgress': 0, 'PROGRESS': 0, 'Joining': 1, 'JOINING': 1, 'Active': 2, 'CREATED': 2, 'Completed': 3, 'COMPLETED': 3, 'Inactive': 4 };
        return (order[a.status] ?? 5) - (order[b.status] ?? 5);
    });



    return (
        <div className="space-y-5">
            <AnimatePresence>
                {showCreate && (
                    <CreateSessionModal
                        onClose={() => setShowCreate(false)}
                        onExecute={handleCreateSession}
                    />
                )}
            </AnimatePresence>

            {/* ── Header ── */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 py-2">
                <div className="flex items-center gap-4">
                    <div className="w-14 h-14 rounded-3xl bg-[#E8EFFF] text-[#3B82F6] flex items-center justify-center shadow-sm">
                        <Zap className="w-6 h-6" fill="currentColor" />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-slate-800 tracking-tight leading-none mb-1">Session Manager</h1>
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.2em] leading-none">Activity Orchestration</p>
                    </div>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={e => setSearchQuery(e.target.value)}
                            placeholder="Search sessions..."
                            className="pl-11 pr-4 py-2.5 bg-white border border-slate-200 rounded-full text-xs font-semibold text-slate-700 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#3B82F6]/20 focus:border-[#3B82F6] w-64 transition-all shadow-[0_2px_10px_-4px_rgba(0,0,0,0.05)]"
                        />
                    </div>
                    <button
                        onClick={() => fetchSessions(true)}
                        disabled={refreshing}
                        className="p-3 rounded-full border border-slate-200 bg-white text-slate-500 hover:text-slate-800 hover:border-slate-300 transition-all shadow-sm"
                        title="Refresh"
                    >
                        <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin text-[#3B82F6]' : ''}`} />
                    </button>
                    <button
                        onClick={() => setShowCreate(true)}
                        className="flex items-center gap-1.5 px-5 py-2.5 bg-[#3B82F6] hover:bg-blue-700 text-white rounded-full font-bold text-[9px] uppercase tracking-widest shadow-lg shadow-blue-500/20 transition-all active:scale-95"
                    >
                        <Plus className="w-4 h-4" />
                        New Session
                    </button>
                </div>
            </div>

            {/* ── Tabs ── */}
            <div className="flex items-center gap-2 p-1.5 bg-white border border-slate-100 rounded-[2rem] shadow-sm overflow-x-auto hide-scrollbar">
                {tabs.map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => setFilter(tab.id)}
                        className={`flex items-center gap-1.5 px-5 py-2.5 rounded-full text-[9px] font-bold uppercase tracking-widest transition-all whitespace-nowrap ${
                            filter === tab.id
                                ? 'bg-white text-slate-800 shadow-[0_2px_12px_-4px_rgba(0,0,0,0.1)] ring-1 ring-slate-100'
                                : 'text-slate-400 hover:text-slate-600 hover:bg-slate-50'
                        }`}
                    >
                        {tab.label}
                        <span className={`px-2 py-0.5 rounded-md text-[9px] ${
                            filter === tab.id ? 'bg-[#EEF2FF] text-[#4F46E5]' : 'bg-slate-100 text-slate-400'
                        }`}>
                            {tab.count}
                        </span>
                    </button>
                ))}
            </div>

                {/* ── Session List ── */}
                <div className="py-6 space-y-4">
                    {loading && sessionList.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-20 gap-3">
                            <Loader2 className="w-7 h-7 text-blue-500 animate-spin" />
                            <p className="text-sm text-slate-500">Loading sessions...</p>
                        </div>
                    ) : error ? (
                        <div className="flex flex-col items-center justify-center py-20 gap-3">
                            <div className="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center">
                                <Zap className="w-5 h-5 text-red-400" />
                            </div>
                            <div className="text-center">
                                <p className="text-sm font-semibold text-slate-700">Failed to load sessions</p>
                                <p className="text-xs text-slate-400 mt-1">{error}</p>
                            </div>
                            <button
                                onClick={() => fetchSessions()}
                                className="px-4 py-2 bg-slate-900 text-white rounded-lg text-xs font-semibold hover:bg-slate-800 transition-all"
                            >
                                Try Again
                            </button>
                        </div>
                    ) : filteredSessions.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-20 gap-3">
                            <div className="w-12 h-12 rounded-full bg-slate-50 border-2 border-dashed border-slate-200 flex items-center justify-center">
                                <QrCode className="w-5 h-5 text-slate-300" />
                            </div>
                            <div className="text-center">
                                <p className="text-sm font-semibold text-slate-600">
                                    {searchQuery ? 'No matching sessions' : `No ${filter === 'All' ? '' : filter + ' '}sessions`}
                                </p>
                                <p className="text-xs text-slate-400 mt-1">
                                    {searchQuery ? 'Try a different search term' : 'Create a session to get started'}
                                </p>
                            </div>
                            {!searchQuery && (
                                <button
                                    onClick={() => setShowCreate(true)}
                                    className="flex items-center gap-1.5 px-4 py-2 bg-blue-600 text-white rounded-lg text-xs font-semibold hover:bg-blue-700 transition-all"
                                >
                                    <Plus className="w-3.5 h-3.5" />
                                    New Session
                                </button>
                            )}
                        </div>
                    ) : (
                        <AnimatePresence mode="popLayout">
                            {filteredSessions.map((session, index) => {
                                const sc = getStatusConfig(session.status);
                                const past = isPastSession(session.status);
                                return (
                                    <motion.div
                                        key={session.id}
                                        layout
                                        initial={{ opacity: 0, y: 8 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0 }}
                                        transition={{ delay: index * 0.03 }}
                                        onClick={() => navigate(`/admin/session-detail/${session.id}`, { state: { status: session.status } })}
                                        className={`group flex items-center justify-between p-5 rounded-3xl bg-white border border-slate-100 cursor-pointer transition-all hover:border-[#3B82F6]/30 hover:shadow-xl hover:shadow-[#3B82F6]/10 shadow-[0_4px_12px_-4px_rgba(0,0,0,0.05)] ${past ? 'opacity-60 hover:opacity-100 grayscale hover:grayscale-0' : ''}`}
                                    >
                                        <div className="flex items-center gap-6 w-full">
                                            {/* Name / Mode */}
                                            <div className="flex items-center gap-4 w-[28%] flex-shrink-0">
                                                <div className="w-12 h-12 rounded-2xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-center flex-shrink-0">
                                                    <QrCode className="w-5 h-5 text-slate-400" />
                                                </div>
                                                <div className="min-w-0">
                                                    <h3 className="text-xs font-bold text-slate-800 truncate mb-1">{session.type}</h3>
                                                    <div className="flex items-center gap-1.5 flex-wrap">
                                                        <span className="flex items-center gap-1 px-1.5 py-0.5 bg-[#EFF6FF] text-[#3B82F6] text-[8px] font-bold uppercase tracking-wider rounded border border-[#DBEAFE]">
                                                            <Zap className="w-2 h-2" />
                                                            {session.level}
                                                        </span>
                                                        {session.start_mode && (
                                                            <span className="px-1.5 py-0.5 bg-[#F8FAFC] text-slate-500 border border-slate-200 text-[6.5px] font-bold uppercase tracking-widest rounded">
                                                                {session.start_mode.replace('_', ' ')}
                                                            </span>
                                                        )}
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Scanned */}
                                            <div className="flex items-center justify-center gap-3 w-[15%]">
                                                <div className="flex items-center gap-2">
                                                    <Users className="w-4 h-4 text-slate-300 stroke-[2.5]" />
                                                    <div>
                                                        <p className="text-xs font-bold text-slate-800 leading-none mb-1">{session.students}</p>
                                                        <p className="text-[7px] font-semibold tracking-widest uppercase text-slate-400 leading-none">Scanned</p>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Schedule */}
                                            <div className="flex items-center justify-center gap-3 w-[25%] flex-shrink-0">
                                                <div className="flex items-center gap-2">
                                                    <Calendar className="w-4 h-4 text-slate-300 stroke-[2.5]" />
                                                    <div>
                                                        <p className="text-[10px] font-bold text-slate-800 leading-none mb-1">{session.time}</p>
                                                        <p className="text-[7px] font-semibold tracking-widest uppercase text-slate-400 leading-none">Scheduled</p>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Supervisor */}
                                            <div className="w-[18%] flex flex-col justify-center max-w-full">
                                                <p className="text-[7px] font-semibold tracking-widest uppercase text-slate-400 leading-none mb-1">Supervisor</p>
                                                <p className="text-[10px] font-bold text-slate-800 truncate block">{session.supervisor}</p>
                                            </div>

                                            {/* Status Badge */}
                                            <div className="flex justify-end w-[14%] flex-shrink-0">
                                                <span className={`inline-flex items-center justify-center px-3 py-1 rounded-full text-[7.5px] font-bold uppercase tracking-widest ring-1 ring-inset ${sc.badge}`}>
                                                    {sc.label}
                                                </span>
                                            </div>
                                        </div>
                                    </motion.div>
                                );
                            })}
                        </AnimatePresence>
                    )}
                </div>


        </div>
    );
};

export default SessionManager;
