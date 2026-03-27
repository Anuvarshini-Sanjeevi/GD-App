import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useNavigate, useLocation, useParams } from 'react-router-dom';
import {
    ArrowLeft,
    Users,
    CheckCircle,
    XCircle,
    Clock,
    AlertCircle,
    Grid3x3,
    QrCode,
    Loader2,
    Play
} from 'lucide-react';
import SessionRankerBoard, { type Participant } from '../../components/admin/SessionRankerBoard';
import api from '../../utils/api';

interface ViewParticipant extends Participant {
    joined: boolean;
    scannedQR: boolean;
}

const SessionDetailView = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const { id } = useParams();
    const [sessionData, setSessionData] = useState<any>(null);
    const [participants, setParticipants] = useState<ViewParticipant[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [activityCompleted, setActivityCompleted] = useState(false);
    const [starting, setStarting] = useState(false);

    const fetchSessionDetails = async () => {
        try {
            setLoading(true);
            const tokenId = id?.replace('T-', '');
            
            // Parallel API calls for details, summary and rankings
            const [detailsRes, summaryRes, rankingsRes] = await Promise.all([
                api.get(`/hall-qr-tokens/${tokenId}`),
                api.get(`/hall-qr-tokens/${tokenId}/summary`).catch(() => ({ data: {} })),
                api.get(`/hall-qr-tokens/${tokenId}/rankings`).catch(() => ({ data: { rankings: [] } }))
            ]);

            const data = detailsRes.data;
            const summaryData = summaryRes.data || {};

            // Map backend data to frontend format
            const attendances = data.attendances || [];
            const occupiedTableNums = new Set(attendances.map((a: any) => a.table_number).filter((t: any) => t));

            setSessionData({
                id: data.token_id,
                title: data.hall_qr_token,
                status: data.session_status,
                startTime: data.start_time || new Date(data.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                duration: data.expires_in_minutes || 60,
                expectedParticipants: summaryData?.total_capacity || 120, 
                joinedParticipants: summaryData?.participants_joined || 0,
                totalTables: summaryData?.total_tables || 20,
                occupiedTables: summaryData?.tables_occupied || 0,
                occupiedTableList: Array.from(occupiedTableNums),
                missedQRScans: summaryData?.missed_qr_scans || 0,
                timeRemaining: summaryData?.time_remaining_minutes || 0,
                startMode: data.start_mode,
                quorumThreshold: data.quorum_threshold,
                startedAt: data.started_at,
                joinRate: summaryData?.joined_percentage || 0,
                occupancyRate: summaryData?.occupied_percentage || 0
            });

            setActivityCompleted(data.session_status === 'COMPLETED');
            
            // Map attendances to participants state, merging with ranking data
            if (attendances.length > 0) {
                const rankings = rankingsRes.data?.rankings || [];
                const rankingMap = new Map(rankings.map((r: any) => [r.student_id, r]));

                const mappedParticipants: ViewParticipant[] = attendances.map((att: any) => {
                    const ranking = rankingMap.get(att.student_id);
                    return {
                        id: att.id,
                        name: att.student?.name || att.student_name || 'Unknown',
                        table: att.table_number ? `Table ${String(att.table_number).padStart(2, '0')}` : 'Not assigned',
                        points: (ranking as any)?.points || 0,
                        rank: (ranking as any)?.rank || null,
                        joined: true,
                        scannedQR: true
                    };
                });
                setParticipants(mappedParticipants);
            } else {
                setParticipants([]);
            }
            setError(null);
        } catch (err: any) {
            setError(err.message || 'Failed to fetch session details');
        } finally {
            setLoading(false);
        }
    };
    
    const handleStartSession = async () => {
        if (!sessionData?.id || starting) return;
        try {
            setStarting(true);
            await api.post(`/hall-qr-tokens/${sessionData.id}/start`);
            await fetchSessionDetails();
        } catch (err: any) {
            alert(err.response?.data?.message || 'Failed to start session');
        } finally {
            setStarting(false);
        }
    };

    useEffect(() => {
        fetchSessionDetails();
        const interval = setInterval(fetchSessionDetails, 30000);
        return () => clearInterval(interval);
    }, [id]);

    useEffect(() => {
        if (location.state?.status === 'Completed') {
            setActivityCompleted(true);
        }
    }, [location.state]);

    if (loading && !sessionData) {
        return (
            <div className="flex flex-col items-center justify-center py-40">
                <Loader2 className="w-8 h-8 text-primary animate-spin mb-4" />
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Decoding Session Stream...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center py-40 bg-white/40 rounded-3xl border border-red-100 backdrop-blur-sm">
                <AlertCircle className="w-8 h-8 text-red-400 mb-4 opacity-50" />
                <p className="text-[10px] font-black text-red-500 uppercase tracking-widest mb-1">Retrieval Error</p>
                <p className="text-[8px] font-bold text-slate-400 uppercase tracking-widest">{error}</p>
                <button
                    onClick={() => navigate('/admin/sessions')}
                    className="mt-6 px-4 py-2 bg-slate-900 text-white rounded-xl text-[10px] font-bold uppercase tracking-widest"
                >
                    Return to Fleet
                </button>
            </div>
        );
    }

    if (!sessionData) return null;

    const joinRate = sessionData.joinRate ?? 0;
    const occupancyRate = sessionData.occupancyRate ?? 0;

    return (
        <div className="relative">
            {/* Header */}
            <div className="mb-3">
                <button
                    onClick={() => navigate('/admin/sessions')}
                    className="flex items-center gap-2 text-slate-600 hover:text-blue-600 font-semibold text-xs mb-3 transition-colors"
                >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Back to Sessions
                </button>
                <div className="flex justify-between items-start">
                    <div>
                        <div className="flex items-center gap-3">
                            <h1 className="text-lg font-bold text-slate-900">{sessionData.title}</h1>
                            {sessionData.startMode && (
                                <span className="px-2 py-0.5 bg-slate-900 text-white text-[8px] font-black uppercase tracking-widest rounded-md">
                                    {sessionData.startMode.replace('_', ' ')}
                                </span>
                            )}
                        </div>
                        <p className="text-xs text-slate-500 mt-0.5">
                            {sessionData.startedAt 
                                ? `Started at ${new Date(sessionData.startedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`
                                : `Scheduled for ${sessionData.startTime}`
                            }
                        </p>
                    </div>
                    <div className="flex items-center gap-2">
                        {!sessionData.startedAt && (sessionData.startMode === 'ALL_MEMBERS' || sessionData.startMode === 'HYBRID') && (
                            <button
                                onClick={handleStartSession}
                                disabled={starting}
                                className="flex items-center gap-2 px-4 py-2 bg-slate-900 text-white rounded-xl text-[10px] font-black uppercase tracking-widest shadow-lg shadow-slate-900/10 hover:bg-slate-800 transition-all active:scale-95 disabled:opacity-50"
                            >
                                {starting ? <Loader2 className="w-3 h-3 animate-spin" /> : <Play className="w-3 h-3 fill-current" />}
                                Start Session
                            </button>
                        )}
                        <span className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase ${['PROGRESS', 'JOINING'].includes(sessionData.status)
                            ? 'bg-blue-100 text-blue-700 border border-blue-200'
                            : sessionData.status === 'COMPLETED' ? 'bg-emerald-100 text-emerald-700 border border-emerald-200'
                            : 'bg-slate-100 text-slate-700 border border-slate-200'
                            }`}>
                            {sessionData.status}
                        </span>
                    </div>
                </div>
            </div>

            {/* Live Statistics - Only show if active */}
            {!activityCompleted && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="stat-card"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <Users className="w-4 h-4 text-blue-500" />
                            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
                                {joinRate}%
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.joinedParticipants}</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Participants Joined</p>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.05 }}
                        className="stat-card"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <Grid3x3 className="w-4 h-4 text-emerald-500" />
                            <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                                {occupancyRate}%
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.occupiedTables}</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Tables Occupied</p>
                    </motion.div>


                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.15 }}
                        className="stat-card"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <Clock className="w-4 h-4 text-purple-500" />
                            <span className="text-[10px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded">
                                Live
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.timeRemaining}m</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Time Remaining</p>
                    </motion.div>
                </div>
            )}

            {/* Main Content */}
            {activityCompleted ? (
                // Full width Ranker Board for completed sessions
                <div className="w-full">
                    <SessionRankerBoard participants={participants} />
                </div>
            ) : (
                // Standard Grid for Active Session
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
                    {/* Participants List */}
                    <div className="lg:col-span-2">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="glass-card rounded-2xl p-4"
                        >
                            <div className="flex items-center justify-between mb-2">
                                <h2 className="text-sm font-bold text-slate-900">Participant Status</h2>
                                {/* TEMP: Dev button to force completion */}
                                <button
                                    onClick={() => setActivityCompleted(true)}
                                    className="text-[10px] text-blue-500 hover:text-blue-700 underline cursor-pointer"
                                >
                                    Force Complete (Dev)
                                </button>
                            </div>
                            <div className="space-y-2 max-h-[420px] overflow-y-auto">
                                {participants.map((participant, index) => (
                                    <motion.div
                                        key={participant.id}
                                        initial={{ opacity: 0, x: -10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        transition={{ delay: 0.3 + index * 0.02 }}
                                        className="flex items-center justify-between p-2.5 rounded-lg bg-slate-50 hover:bg-slate-100 transition-colors"
                                    >
                                        <div className="flex items-center gap-2.5">
                                            <div className={`w-7 h-7 rounded-lg flex items-center justify-center ${participant.joined ? 'bg-emerald-100' : 'bg-red-100'
                                                }`}>
                                                {participant.joined ? (
                                                    <CheckCircle className="w-3.5 h-3.5 text-emerald-600" />
                                                ) : (
                                                    <XCircle className="w-3.5 h-3.5 text-red-500" />
                                                )}
                                            </div>
                                            <div>
                                                <p className="text-xs font-semibold text-slate-900">{participant.name}</p>
                                                <p className="text-[10px] text-slate-500">
                                                    {participant.table || 'Not assigned'}
                                                </p>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            {participant.scannedQR ? (
                                                <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded flex items-center gap-1">
                                                    <QrCode className="w-2.5 h-2.5" />
                                                    Scanned
                                                </span>
                                            ) : participant.joined ? (
                                                <span className="text-[10px] font-bold text-orange-600 bg-orange-50 px-2 py-0.5 rounded flex items-center gap-1">
                                                    <AlertCircle className="w-2.5 h-2.5" />
                                                    Missed QR
                                                </span>
                                            ) : (
                                                <span className="text-[10px] font-bold text-red-600 bg-red-50 px-2 py-0.5 rounded">
                                                    Absent
                                                </span>
                                            )}
                                        </div>
                                    </motion.div>
                                ))}
                            </div>
                        </motion.div>
                    </div>

                    {/* Table Occupancy Grid */}
                    <div>
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.25 }}
                            className="glass-card rounded-2xl p-4"
                        >
                            <h2 className="text-sm font-bold text-slate-900 mb-3">Table Occupancy</h2>
                            <div className="grid grid-cols-4 gap-2">
                                {Array.from({ length: sessionData.totalTables }, (_, i) => {
                                    const tableNum = i + 1;
                                    const isOccupied = sessionData.occupiedTableList?.includes(tableNum);
                                    return (
                                        <motion.div
                                            key={i}
                                            initial={{ opacity: 0, scale: 0.8 }}
                                            animate={{ opacity: 1, scale: 1 }}
                                            transition={{ delay: 0.3 + i * 0.02 }}
                                            className={`aspect-square rounded-lg flex items-center justify-center text-[10px] font-bold transition-all ${isOccupied
                                                ? 'bg-emerald-100 text-emerald-700 border-2 border-emerald-300'
                                                : 'bg-slate-100 text-slate-400 border-2 border-slate-200'
                                                }`}
                                        >
                                            T-{String(tableNum).padStart(2, '0')}
                                        </motion.div>
                                    );
                                })}
                            </div>
                            <div className="flex items-center gap-3 mt-3 pt-3 border-t border-slate-200">
                                <div className="flex items-center gap-1.5">
                                    <div className="w-3 h-3 rounded bg-emerald-100 border-2 border-emerald-300"></div>
                                    <span className="text-[10px] font-semibold text-slate-600">Occupied</span>
                                </div>
                                <div className="flex items-center gap-1.5">
                                    <div className="w-3 h-3 rounded bg-slate-100 border-2 border-slate-200"></div>
                                    <span className="text-[10px] font-semibold text-slate-600">Empty</span>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default SessionDetailView;
