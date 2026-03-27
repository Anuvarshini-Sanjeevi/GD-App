import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
    LogOut, 
    Users, 
    Play, 
    CheckCircle, 
    MapPin, 
    Timer, 
    RefreshCcw,
    ChevronRight,
    Zap,
    AlertCircle,
    Loader2
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../../utils/api';

const SupervisorDashboard: React.FC = () => {
    const navigate = useNavigate();
    const [sessions, setSessions] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const fetchSessions = async (showRefresh = false) => {
        try {
            if (showRefresh) setRefreshing(true);
            const response = await api.get('/hall-qr-tokens'); // Automatically filtered by supervisor role in backend interceptor/controller
            setSessions(response.data);
            setError(null);
        } catch (err: any) {
            setError(err.message || 'Failed to fetch assigned sessions');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    useEffect(() => {
        fetchSessions();
        const interval = setInterval(() => fetchSessions(false), 30000);
        return () => clearInterval(interval);
    }, []);

    const handleLogout = () => {
        localStorage.removeItem('token');
        localStorage.removeItem('userData');
        navigate('/');
    };

    const handleStartSession = async (tokenId: number) => {
        try {
            await api.post(`/hall-qr-tokens/${tokenId}/start`);
            fetchSessions(true);
        } catch (err: any) {
            alert(err.response?.data?.message || 'Failed to start session');
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-8">
                <Loader2 className="w-10 h-10 text-blue-600 animate-spin mb-4" />
                <p className="text-slate-400 font-bold uppercase tracking-[0.2em] text-[10px]">Initializing Supervisor Console...</p>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-[#F8FAFC] p-6 md:p-10">
            <div className="max-w-5xl mx-auto">
                {/* Header */}
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 mb-12">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <div className="w-2 h-6 bg-blue-600 rounded-full" />
                            <h1 className="text-2xl font-black text-slate-900 tracking-tight uppercase">Supervisor Hub</h1>
                        </div>
                        <p className="text-slate-400 font-bold text-[10px] uppercase tracking-widest flex items-center gap-2">
                            <Zap size={12} className="text-blue-500" />
                            Active Monitoring & Control
                        </p>
                    </div>

                    <div className="flex items-center gap-3">
                        <button 
                            onClick={() => fetchSessions(true)}
                            className={`p-3 bg-white border border-slate-200 rounded-2xl text-slate-500 hover:text-blue-600 hover:border-blue-100 transition-all ${refreshing ? 'animate-spin' : ''}`}
                        >
                            <RefreshCcw size={18} />
                        </button>
                        <button
                            onClick={handleLogout}
                            className="flex items-center gap-2.5 px-6 py-3 bg-white border border-slate-200 rounded-2xl text-slate-600 hover:bg-slate-50 transition-all font-black text-[11px] uppercase tracking-widest shadow-sm active:scale-95"
                        >
                            <LogOut size={16} className="text-red-400" />
                            Term-Session
                        </button>
                    </div>
                </div>

                {error && (
                    <div className="mb-8 p-5 bg-red-50 border border-red-100 rounded-[2rem] flex items-center gap-4 text-red-600 animate-in fade-in slide-in-from-top-4">
                        <AlertCircle size={20} />
                        <span className="text-sm font-bold">{error}</span>
                    </div>
                )}

                {/* Session List */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <AnimatePresence mode="popLayout">
                        {sessions.length === 0 ? (
                            <motion.div 
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.95 }}
                                className="col-span-full py-20 bg-white border border-dashed border-slate-200 rounded-[3rem] flex flex-col items-center justify-center text-center"
                            >
                                <div className="w-16 h-16 bg-slate-50 rounded-3xl flex items-center justify-center mb-6 text-slate-300">
                                    <Users size={32} />
                                </div>
                                <h3 className="text-lg font-bold text-slate-800 mb-1">No Active Assigments</h3>
                                <p className="text-slate-400 text-xs font-medium max-w-xs mx-auto">You haven't been assigned to any sessions yet. Please contact the administrator.</p>
                            </motion.div>
                        ) : (
                            sessions.map((session: any, idx: number) => (
                                <SessionControlCard 
                                    key={session.token_id || idx} 
                                    session={session} 
                                    onStart={() => handleStartSession(session.token_id)}
                                    index={idx}
                                />
                            ))
                        )}
                    </AnimatePresence>
                </div>
            </div>
        </div>
    );
};

const SessionControlCard = ({ session, onStart, index }: any) => {
    const isStarted = !!session.started_at;
    const progress = session.expected_students > 0 ? (session.scan_count / session.expected_students) : 0;
    const threshold = session.quorum_threshold || 0.7;
    const isQuorumMet = progress >= threshold;
    const status = session.session_status || 'CREATED';

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="glass-card p-8 rounded-[2.5rem] group relative hover:shadow-[0_25px_60px_-15px_rgba(0,0,0,0.08)] transition-all duration-500"
        >
            {/* Status Badge */}
            <div className="absolute top-8 right-8">
                <span className={`px-3 py-1.5 rounded-xl text-[9px] font-black uppercase tracking-widest flex items-center gap-2 border ${
                    status === 'PROGRESS' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                    status === 'JOINING' ? 'bg-blue-50 text-blue-600 border-blue-100' : 
                    'bg-slate-50 text-slate-400 border-slate-100'
                }`}>
                    {status === 'PROGRESS' && <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" />}
                    {status}
                </span>
            </div>

            <div className="mb-8">
                <div className="flex items-center gap-3 mb-2">
                    <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                        <Zap size={18} />
                    </div>
                    <h3 className="text-xl font-black text-slate-900 leading-none">{session.hall_qr_token}</h3>
                </div>
                <div className="flex flex-wrap gap-4 mt-4">
                    <div className="flex items-center gap-1.5 text-slate-400">
                        <MapPin size={14} className="text-slate-300" />
                        <span className="text-[11px] font-bold uppercase tracking-wider">{session.location || 'N/A'}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-slate-400">
                        <Timer size={14} className="text-slate-300" />
                        <span className="text-[11px] font-bold uppercase tracking-wider">{session.expires_in_minutes} Min Duration</span>
                    </div>
                </div>
            </div>

            {/* Attendance Progress */}
            <div className="space-y-4 mb-10">
                <div className="flex justify-between items-end">
                    <div className="flex flex-col">
                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Arrival Stream</span>
                        <div className="flex items-baseline gap-1">
                            <span className="text-2xl font-black text-slate-900">{session.scan_count || 0}</span>
                            <span className="text-slate-300 font-bold text-sm">/ {session.expected_students || '??'}</span>
                        </div>
                    </div>
                    <div className="text-right">
                        <span className={`text-[10px] font-black uppercase tracking-widest px-2 py-0.5 rounded ${
                            isQuorumMet ? 'text-emerald-500 bg-emerald-50' : 'text-orange-500 bg-orange-50'
                        }`}>
                            {isQuorumMet ? 'Quorum Met' : 'Waiting for Quorum'}
                        </span>
                    </div>
                </div>

                <div className="relative h-2.5 w-full bg-slate-50 rounded-full overflow-hidden border border-slate-100/50 p-0.5">
                    {/* Threshold Marker */}
                    <div 
                        className="absolute top-0 bottom-0 w-0.5 bg-slate-200 z-10" 
                        style={{ left: `${threshold * 100}%` }}
                        title={`Quorum: ${threshold * 100}%`}
                    />
                    <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: `${Math.min(progress, 1) * 100}%` }}
                        className={`h-full rounded-full transition-colors duration-500 ${
                            isQuorumMet ? 'bg-gradient-to-r from-emerald-400 to-emerald-500' : 'bg-gradient-to-r from-blue-400 to-blue-500'
                        }`}
                    />
                </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3 pt-2">
                {!isStarted ? (
                    <button
                        onClick={onStart}
                        className="flex-1 py-4 bg-slate-900 text-white rounded-[1.5rem] font-black text-[11px] uppercase tracking-[0.2em] shadow-xl shadow-slate-900/10 hover:bg-slate-850 hover:shadow-slate-900/20 active:scale-[0.98] transition-all flex items-center justify-center gap-3"
                    >
                        <Play size={16} fill="currentColor" />
                        Force Start
                    </button>
                ) : (
                    <button
                        disabled
                        className="flex-1 py-4 bg-emerald-50 text-emerald-600 rounded-[1.5rem] font-black text-[11px] uppercase tracking-[0.2em] border border-emerald-100 flex items-center justify-center gap-3 opacity-80"
                    >
                        <CheckCircle size={16} />
                        Session Live
                    </button>
                )}
                <button 
                    disabled
                    className="p-4 bg-slate-50 text-slate-300 rounded-[1.5rem] border border-slate-100 hover:text-slate-600 hover:bg-white transition-all"
                >
                    <ChevronRight size={20} />
                </button>
            </div>

            {/* Start Mode Info Overlay */}
            <div className="mt-6 pt-5 border-t border-slate-50 flex justify-between items-center opacity-50 group-hover:opacity-100 transition-opacity">
                <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">Mode: {session.start_mode?.replace('_', ' ') || 'STANDARD'}</span>
                <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">Threshold: {Math.round(threshold * 100)}%</span>
            </div>
        </motion.div>
    );
};

export default SupervisorDashboard;
