import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
    ArrowLeft,
    Users,
    CheckCircle,
    XCircle,
    Clock,
    AlertCircle,
    Grid3x3,
    QrCode
} from 'lucide-react';
import SessionRankerBoard from '../../components/admin/SessionRankerBoard';

// Mock data - replace with API calls
const mockSessionData = {
    id: '1',
    title: 'Morning GD - Hall A',
    status: 'ACTIVE',
    startTime: '09:00 AM',
    duration: 60,
    expectedParticipants: 120,
    joinedParticipants: 98,
    totalTables: 20,
    occupiedTables: 16,
    missedQRScans: 8,
    activityCompleted: false,
    timeRemaining: 25 // minutes
};

const mockParticipants = [
    { id: 1, name: 'Alice Johnson', table: 'T-01', joined: true, scannedQR: true, rank: 1, points: 95 },
    { id: 2, name: 'Bob Smith', table: 'T-01', joined: true, scannedQR: true, rank: 2, points: 92 },
    { id: 3, name: 'Charlie Brown', table: 'T-02', joined: true, scannedQR: false, rank: null, points: 0 },
    { id: 4, name: 'Diana Prince', table: 'T-02', joined: true, scannedQR: true, rank: 3, points: 88 },
    { id: 5, name: 'Eve Wilson', table: null, joined: false, scannedQR: false, rank: null, points: 0 },
];

const SessionDetailView = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const [sessionData, setSessionData] = useState(mockSessionData);
    const [participants] = useState(mockParticipants);
    const [activityCompleted, setActivityCompleted] = useState(location.state?.status === 'Completed' || false);

    // Simulate real-time updates
    useEffect(() => {
        if (activityCompleted) return;

        const interval = setInterval(() => {
            setSessionData(prev => ({
                ...prev,
                timeRemaining: Math.max(0, prev.timeRemaining - 1),
                joinedParticipants: Math.min(prev.expectedParticipants, prev.joinedParticipants + Math.floor(Math.random() * 2))
            }));
        }, 60000); // Update every minute

        return () => clearInterval(interval);
    }, [activityCompleted]);

    // Check if activity is completed
    useEffect(() => {
        if (sessionData.timeRemaining === 0) {
            setActivityCompleted(true);
        }
    }, [sessionData.timeRemaining]);

    const joinRate = Math.round((sessionData.joinedParticipants / sessionData.expectedParticipants) * 100);
    const occupancyRate = Math.round((sessionData.occupiedTables / sessionData.totalTables) * 100);

    return (
        <div className="relative min-h-screen">
            {/* Header */}
            <div className="mb-4">
                <button
                    onClick={() => navigate('/admin/sessions')}
                    className="flex items-center gap-2 text-slate-600 hover:text-blue-600 font-semibold text-xs mb-3 transition-colors"
                >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Back to Sessions
                </button>
                <div className="flex justify-between items-start">
                    <div>
                        <h1 className="text-lg font-bold text-slate-900">{sessionData.title}</h1>
                        <p className="text-xs text-slate-500 mt-0.5">Started at {sessionData.startTime}</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <span className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase ${sessionData.status === 'ACTIVE'
                            ? 'bg-blue-100 text-blue-700 border border-blue-200'
                            : 'bg-slate-100 text-slate-700'
                            }`}>
                            {sessionData.status}
                        </span>
                    </div>
                </div>
            </div>

            {/* Live Statistics - Only show if active */}
            {!activityCompleted && (
                <div className="grid grid-cols-1 md:grid-cols-4 gap-3 mb-4">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <Users className="w-4 h-4 text-blue-500" />
                            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
                                {joinRate}%
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.joinedParticipants}/{sessionData.expectedParticipants}</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Participants Joined</p>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.05 }}
                        className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <Grid3x3 className="w-4 h-4 text-emerald-500" />
                            <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                                {occupancyRate}%
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.occupiedTables}/{sessionData.totalTables}</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Tables Occupied</p>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm"
                    >
                        <div className="flex items-center justify-between mb-2">
                            <AlertCircle className="w-4 h-4 text-orange-500" />
                            <span className="text-[10px] font-bold text-orange-600 bg-orange-50 px-2 py-0.5 rounded">
                                Alert
                            </span>
                        </div>
                        <h3 className="text-lg font-bold text-slate-900">{sessionData.missedQRScans}</h3>
                        <p className="text-[9px] font-semibold text-slate-500 uppercase mt-0.5">Missed QR Scans</p>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.15 }}
                        className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm"
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
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
                    {/* Participants List */}
                    <div className="lg:col-span-2">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm"
                        >
                            <div className="flex items-center justify-between mb-3">
                                <h2 className="text-sm font-bold text-slate-900">Participant Status</h2>
                                {/* TEMP: Dev button to force completion */}
                                <button
                                    onClick={() => setActivityCompleted(true)}
                                    className="text-[10px] text-blue-500 hover:text-blue-700 underline cursor-pointer"
                                >
                                    Force Complete (Dev)
                                </button>
                            </div>
                            <div className="space-y-2 max-h-[500px] overflow-y-auto">
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
                            className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm"
                        >
                            <h2 className="text-sm font-bold text-slate-900 mb-3">Table Occupancy</h2>
                            <div className="grid grid-cols-4 gap-2">
                                {Array.from({ length: sessionData.totalTables }, (_, i) => {
                                    const isOccupied = i < sessionData.occupiedTables;
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
                                            T-{String(i + 1).padStart(2, '0')}
                                        </motion.div>
                                    );
                                })}
                            </div>
                            <div className="flex items-center gap-3 mt-4 pt-3 border-t border-slate-200">
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
