import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { X, Zap, Users, Clock, Shield, Target, MousePointer2, ChevronDown, GraduationCap, Timer, UserCheck } from 'lucide-react';
import api from '../../utils/api';

interface CreateSessionProps {
    onClose: () => void;
    onExecute: (session: any) => void;
}

export const CreateSessionModal = ({ onClose, onExecute }: CreateSessionProps) => {
    const [selectedType, setSelectedType] = useState('Group Discussion');
    const [selectedLevel, setSelectedLevel] = useState(1);
    const [joinWindow, setJoinWindow] = useState(60); // Acts as Total Duration
    const [startTime, setStartTime] = useState(new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false }));
    const [quizEnabled, setQuizEnabled] = useState(false);
    const [antiRepeatEnabled, setAntiRepeatEnabled] = useState(true);
    const [isLoading, setIsLoading] = useState(false);
    const [supervisors, setSupervisors] = useState<any[]>([]);
    const [selectedSupervisorId, setSelectedSupervisorId] = useState<string>('');

    useEffect(() => {
        const fetchSupervisors = async () => {
            try {
                const response = await api.get('/users?role=supervisor');
                const subs = response.data;
                setSupervisors(subs);
                if (subs.length > 0) setSelectedSupervisorId(subs[0].user_id);
            } catch (error) {
                console.error('Failed to fetch supervisors:', error);
            }
        };
        fetchSupervisors();
    }, []);

    const handleExecute = async () => {
        setIsLoading(true);
        const payload = {
            hall_qr_token: selectedType,
            session_id: Math.floor(Math.random() * 1000) + 1,
            created_by_admin_id: 1,
            expires_in_minutes: joinWindow,
            start_time: startTime,
            status: 'ACTIVE',
            supervisor_id: selectedSupervisorId
        };

        try {
            const response = await fetch('http://localhost:8080/api/hall-qr-tokens', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
            });

            if (!response.ok) throw new Error('Failed to persist session');

            const savedToken = await response.json();

            const newSession = {
                id: `T-${savedToken.token_id}`,
                type: savedToken.hall_qr_token,
                level: `Level 0${selectedLevel}`,
                students: savedToken.scan_count || 0,
                status: 'Active',
                time: new Date(savedToken.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
            };

            onExecute(newSession);
            onClose();
        } catch (error: any) {
            console.error('Session Execution Error:', error);
            alert(`Execution Protocol Failed: ${error.message}`);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="absolute inset-0 bg-slate-900/10 backdrop-blur-sm"
                onClick={onClose}
            />

            <motion.div
                initial={{ opacity: 0, scale: 0.98, y: 10 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.98, y: 10 }}
                className="w-full max-w-xl bg-white rounded-[2rem] border border-slate-100 shadow-[0_20px_60px_-15px_rgba(0,0,0,0.1)] relative overflow-hidden flex flex-col max-h-[90vh]"
            >
                {/* --- Compact Header --- */}
                <div className="px-8 py-5 flex justify-between items-center bg-white border-b border-slate-50">
                    <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
                            <GraduationCap size={20} strokeWidth={2.5} />
                        </div>
                        <div>
                            <h2 className="text-lg font-bold text-slate-800 tracking-tight leading-tight">Create Session</h2>
                            <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">New Orchestration</p>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 text-slate-300 hover:text-slate-900 hover:bg-slate-50 rounded-xl transition-all"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* --- Body: Focused & Neat --- */}
                <div className="px-8 py-7 overflow-y-auto space-y-7 custom-scrollbar flex-1 bg-white">

                    {/* Activity Type Selection */}
                    <div className="space-y-3">
                        <div className="flex items-center gap-2">
                            <div className="w-1 h-2.5 bg-blue-600 rounded-full" />
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Activity Type</label>
                        </div>
                        <div className="grid grid-cols-2 gap-2.5">
                            {[
                                { name: 'Group Discussion', icon: Users },
                                { name: 'Technical', icon: Zap },
                                { name: 'Presentation', icon: MousePointer2 },
                                { name: 'Mixed', icon: Target }
                            ].map((type) => (
                                <button
                                    key={type.name}
                                    onClick={() => setSelectedType(type.name)}
                                    className={`px-4 py-3 rounded-xl border-2 transition-all flex items-center gap-3 group ${selectedType === type.name
                                        ? 'bg-blue-600 border-blue-600 text-white shadow-md'
                                        : 'bg-slate-50 border-slate-50 text-slate-600 hover:border-blue-100 hover:bg-white'
                                        }`}
                                >
                                    <type.icon className={`w-4 h-4 ${selectedType === type.name ? 'text-white' : 'text-slate-400 group-hover:text-blue-600'}`} />
                                    <span className="text-[10px] font-bold uppercase tracking-widest">{type.name}</span>
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Operational Parameters Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5 pt-1">
                        <div className="space-y-2.5">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Protocol</label>
                            <div className="relative">
                                <select className="w-full h-11 bg-slate-50 border border-transparent rounded-xl px-4 appearance-none focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/10 focus:bg-white transition-all font-bold text-xs text-slate-700 cursor-pointer">
                                    <option>Hybrid Protocol</option>
                                    <option>Supervisor Only</option>
                                    <option>Open Access</option>
                                </select>
                                <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-300 pointer-events-none" />
                            </div>
                        </div>

                        <div className="space-y-2.5">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Supervisor</label>
                            <div className="relative group">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-600 transition-colors pointer-events-none">
                                    <UserCheck size={16} />
                                </div>
                                <select
                                    value={selectedSupervisorId}
                                    onChange={(e) => setSelectedSupervisorId(e.target.value)}
                                    className="w-full h-11 bg-slate-50 border border-transparent rounded-xl pl-11 pr-10 appearance-none focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/10 focus:bg-white transition-all font-bold text-xs text-slate-700 cursor-pointer"
                                >
                                    <option value="" disabled>Select Supervisor</option>
                                    {supervisors.map(s => (
                                        <option key={s.user_id} value={s.user_id}>{s.name}</option>
                                    ))}
                                </select>
                                <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-300 pointer-events-none" />
                            </div>
                        </div>

                        <div className="space-y-2.5">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Start Time</label>
                            <div className="relative group">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-600 transition-colors pointer-events-none">
                                    <Timer size={16} />
                                </div>
                                <input
                                    type="time"
                                    value={startTime}
                                    onChange={(e) => setStartTime(e.target.value)}
                                    className="w-full h-11 bg-slate-50 border border-transparent rounded-xl pl-11 pr-4 focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/10 focus:bg-white transition-all font-bold text-xs text-slate-700 cursor-pointer"
                                />
                            </div>
                        </div>

                        <div className="space-y-2.5 col-span-full">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Complexity Level</label>
                            <div className="flex gap-2">
                                {[1, 2, 3, 4].map((l) => (
                                    <button
                                        key={l}
                                        onClick={() => setSelectedLevel(l)}
                                        className={`flex-1 h-11 rounded-xl border-2 font-black text-xs transition-all ${selectedLevel === l
                                            ? 'bg-blue-600 border-blue-600 text-white shadow-lg shadow-blue-600/10'
                                            : 'bg-slate-50 border-slate-50 text-slate-400 hover:bg-white hover:border-slate-200 hover:text-blue-600'
                                            }`}
                                    >
                                        L{l}
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>

                    {/* Session Duration: Condensed Slider */}
                    <div className="space-y-4 bg-slate-50/50 p-6 rounded-2xl border border-slate-50">
                        <div className="flex justify-between items-center">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Session Duration</label>
                            <span className="text-[10px] font-black text-blue-600 bg-white border border-blue-100 px-3 py-1 rounded-lg tabular-nums">
                                {joinWindow.toString().padStart(2, '0')} MIN (Total)
                            </span>
                        </div>
                        <div className="px-1">
                            <input
                                type="range"
                                min="15" max="120" step="15"
                                value={joinWindow}
                                onChange={(e) => setJoinWindow(parseInt(e.target.value))}
                                className="w-full h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-blue-600"
                            />
                            <div className="flex justify-between text-[8px] font-black text-slate-300 uppercase tracking-widest mt-3 px-1">
                                <span className={joinWindow === 15 ? 'text-blue-600' : ''}>Rush (15M)</span>
                                <span className={joinWindow === 60 ? 'text-blue-600' : ''}>Std (60M)</span>
                                <span className={joinWindow === 120 ? 'text-blue-600' : ''}>Ext (120M)</span>
                            </div>
                        </div>
                    </div>

                    {/* Operational Toggles: Small & Neat */}
                    <div className="grid grid-cols-1 gap-2.5">
                        {[
                            { state: quizEnabled, setState: setQuizEnabled, icon: Clock, label: 'Entry Quiz', desc: 'Pre-flight Check' },
                            { state: antiRepeatEnabled, setState: setAntiRepeatEnabled, icon: Shield, label: 'Anti-Repeat', desc: 'Member Rotation' }
                        ].map((toggle, idx) => (
                            <div
                                key={idx}
                                onClick={() => toggle.setState(!toggle.state)}
                                className={`flex items-center justify-between p-4 rounded-xl border-2 transition-all cursor-pointer ${toggle.state ? 'bg-white border-blue-50' : 'bg-slate-50 border-transparent'
                                    }`}
                            >
                                <div className="flex items-center gap-4">
                                    <div className={`w-8 h-8 rounded-lg flex items-center justify-center transition-all ${toggle.state ? 'bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'bg-slate-200 text-slate-400'}`}>
                                        <toggle.icon size={16} />
                                    </div>
                                    <div>
                                        <span className="text-[11px] font-bold text-slate-800 leading-none block mb-0.5">{toggle.label}</span>
                                        <span className="text-[9px] font-medium text-slate-400 uppercase tracking-wider leading-none">{toggle.desc}</span>
                                    </div>
                                </div>
                                <div className={`w-8 h-4 rounded-full relative transition-all duration-300 ${toggle.state ? 'bg-blue-600' : 'bg-slate-200'}`}>
                                    <motion.div
                                        animate={{ x: toggle.state ? 16 : 0 }}
                                        className="w-3 h-3 bg-white rounded-full mt-0.5 ml-0.5 shadow-sm"
                                    />
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* --- Footer: Condensed --- */}
                <div className="px-8 py-6 flex gap-3 bg-white border-t border-slate-50">
                    <button
                        onClick={onClose}
                        className="flex-1 py-3 rounded-xl border border-slate-100 bg-white font-bold text-[10px] uppercase tracking-widest text-slate-400 hover:text-slate-900 transition-all"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleExecute}
                        disabled={isLoading}
                        className="flex-[1.8] py-3 rounded-xl bg-slate-900 text-white font-bold text-[10px] uppercase tracking-widest shadow-lg shadow-slate-900/10 hover:bg-slate-800 active:scale-[0.98] transition-all flex items-center justify-center gap-2"
                    >
                        {isLoading ? (
                            <div className="w-3.5 h-3.5 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                        ) : (
                            <>
                                <span>Initialize Protocol</span>
                                <Zap size={14} />
                            </>
                        )}
                    </button>
                </div>
            </motion.div>
        </div>
    );
};
