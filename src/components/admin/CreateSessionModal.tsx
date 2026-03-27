import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { X, Zap, Users, MousePointer2, ChevronDown, GraduationCap, Timer, UserCheck, MapPin, MessageSquare } from 'lucide-react';
import api, { getCurrentUser } from '../../utils/api';

interface CreateSessionProps {
    onClose: () => void;
    onExecute: (session: any) => void;
}

export const CreateSessionModal = ({ onClose, onExecute }: CreateSessionProps) => {
    const [selectedType, setSelectedType] = useState('Group Discussion');
    const [selectedLevel, setSelectedLevel] = useState(1);
    const [selectedVenue, setSelectedVenue] = useState('Vedanayagam');
    const [joinWindow, setJoinWindow] = useState(60); // Acts as Total Duration
    const [startTime, setStartTime] = useState(new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false }));

    const [isLoading, setIsLoading] = useState(false);
    const [supervisors, setSupervisors] = useState<any[]>([]);
    const [selectedSupervisorId, setSelectedSupervisorId] = useState<string>('');
    const [startMode, setStartMode] = useState('SUPERVISOR_ONLY');
    const [expectedStudents, setExpectedStudents] = useState(8);
    const [quorumThreshold, setQuorumThreshold] = useState(0.7);
    const [totalLevels, setTotalLevels] = useState(4);

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

    useEffect(() => {
        const fetchActivitySettings = async () => {
            try {
                const backendType = selectedType.toUpperCase().replace(/ /g, '_');
                const response = await api.get(`/activity-settings/${backendType}`);
                const settings = Array.isArray(response.data) ? response.data[0] : response.data;
                
                if (settings) {
                    if (settings.min_students) setExpectedStudents(settings.min_students);
                    if (settings.quorum_threshold) setQuorumThreshold(Math.round(settings.quorum_threshold * 100));
                    if (settings.total_levels) {
                        setTotalLevels(settings.total_levels);
                        setSelectedLevel(1); // reset to first level on activity change
                    }
                }
            } catch (error) {
                console.error('Failed to fetch activity defaults:', error);
            }
        };
        fetchActivitySettings();
    }, [selectedType]);

    const handleExecute = async () => {
        setIsLoading(true);
        const user = getCurrentUser();
        const adminId = user?.admin_id || 1;

        const payload = {
            hall_qr_token: selectedType,
            session_id: Math.floor(Math.random() * 1000) + 1,
            created_by_admin_id: adminId || 1,
            expires_in_minutes: joinWindow,
            start_time: startTime,
            status: 'ACTIVE',
            supervisor_id: selectedSupervisorId,
            level: `L${selectedLevel}`,
            complexity_level: selectedLevel,
            location: selectedVenue,
            start_mode: startMode,
            expected_students: expectedStudents,
            quorum_threshold: quorumThreshold
        };

        try {
            const response = await api.post('/hall-qr-tokens', payload);
            const savedToken = response.data;

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
            alert(`Execution Protocol Failed: ${error.message || 'Unknown error'}`);
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
                className="w-full max-w-xl glass-card rounded-[2.5rem] relative overflow-hidden flex flex-col max-h-[90.5vh] shadow-[0_30px_80px_-15px_rgba(0,0,0,0.15)] ring-1 ring-white/60"
            >
                {/* --- Compact Header --- */}
                <div className="px-8 py-6 flex justify-between items-center bg-white/40 backdrop-blur-md border-b border-white/50 relative z-10">
                    <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/30">
                            <GraduationCap size={22} strokeWidth={2.5} />
                        </div>
                        <div>
                            <h2 className="text-xl font-bold text-slate-900 tracking-tight leading-loose">Create Session</h2>
                            <p className="text-[10px] font-bold text-indigo-600 uppercase tracking-widest mt-0.5">Configure your session parameters</p>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2.5 text-slate-400 hover:text-red-500 hover:bg-white rounded-xl transition-all shadow-sm block"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* --- Body: Focused & Neat --- */}
                <div className="px-8 py-7 overflow-y-auto space-y-7 custom-scrollbar flex-1 bg-gradient-to-b from-white/30 to-slate-50/10">

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
                                { name: 'Debate Club', icon: MessageSquare }
                            ].map((type) => (
                                <button
                                    key={type.name}
                                    onClick={() => setSelectedType(type.name)}
                                    className={`px-4 py-3 rounded-2xl border-2 transition-all flex items-center gap-3 group ${selectedType === type.name
                                        ? 'bg-blue-600 border-blue-600 text-white shadow-lg shadow-blue-500/20 scale-[1.02]'
                                        : 'bg-white/50 border-white text-slate-500 hover:border-blue-200 hover:bg-white hover:text-blue-600 shadow-sm'
                                        }`}
                                >
                                    <type.icon className={`w-4 h-4 transition-colors ${selectedType === type.name ? 'text-white' : 'text-slate-400 group-hover:text-blue-500'}`} />
                                    <span className="text-[10px] font-bold uppercase tracking-widest truncate">{type.name}</span>
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Operational Parameters Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5 pt-1">
                        <div className="space-y-2.5">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Start Mode</label>
                            <div className="relative">
                                <select 
                                    value={startMode}
                                    onChange={(e) => setStartMode(e.target.value)}
                                    className="w-full h-11 bg-slate-50 border border-transparent rounded-xl px-4 appearance-none focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/10 focus:bg-white transition-all font-bold text-xs text-slate-700 cursor-pointer"
                                >
                                    <option value="SUPERVISOR_ONLY">Supervisor Only</option>
                                    <option value="ALL_MEMBERS">All Members</option>
                                    <option value="QUORUM">Quorum</option>
                                    <option value="HYBRID">Hybrid</option>
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

                        <div className="space-y-2.5">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Location</label>
                            <div className="relative group">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-600 transition-colors pointer-events-none">
                                    <MapPin size={16} />
                                </div>
                                <select
                                    value={selectedVenue}
                                    onChange={(e) => setSelectedVenue(e.target.value)}
                                    className="w-full h-11 bg-slate-50 border border-transparent rounded-xl pl-11 pr-10 appearance-none focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/10 focus:bg-white transition-all font-bold text-xs text-slate-700 cursor-pointer"
                                >
                                    <option value="Vedanayagam">Vedanayagam</option>
                                    <option value="Main Auditorium">Main Auditorium</option>
                                </select>
                                <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-300 pointer-events-none" />
                            </div>
                        </div>

                        <div className="space-y-2.5 col-span-full">
                            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">Complexity Level</label>
                            <div className="flex gap-2">
                                {Array.from({ length: totalLevels }, (_, i) => i + 1).map((l) => (
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


                </div>

                {/* --- Footer: Condensed --- */}
                <div className="px-8 py-6 flex gap-4 bg-white/60 backdrop-blur-md border-t border-white/50 relative z-10">
                    <button
                        onClick={onClose}
                        className="flex-1 py-4 rounded-full border-2 border-slate-200/60 bg-white/50 font-bold text-[11px] uppercase tracking-widest text-slate-500 hover:text-slate-900 hover:border-slate-300 hover:bg-white transition-all shadow-sm"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleExecute}
                        disabled={isLoading}
                        className="flex-[1.8] py-4 rounded-full btn-premium font-black text-[11px] uppercase tracking-widest shadow-xl flex items-center justify-center gap-2.5"
                    >
                        {isLoading ? (
                            <div className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                        ) : (
                            <>
                                <span>Initialize Protocol</span>
                                <Zap size={16} />
                            </>
                        )}
                    </button>
                </div>
            </motion.div>
        </div>
    );
};
