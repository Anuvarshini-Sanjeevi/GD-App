import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import {
    MessageSquare,
    Monitor,
    Presentation,
    Zap,
    Users,
    Save,
    Activity,
    Loader2,
    Upload,
    X,
    Shield,
    Plus,
    Minus,
    Database
} from 'lucide-react';
import { AnimatePresence } from 'framer-motion';
import api from '../../utils/api';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

const ACTIVITIES = [
    { id: 'gd', name: 'Group Discussion', icon: MessageSquare, backend: 'GROUP_DISCUSSION' },
    { id: 'tech', name: 'Technical Events', icon: Monitor, backend: 'TECHNICAL_EVENTS' },
    { id: 'pres', name: 'Presentation', icon: Presentation, backend: 'PRESENTATION' },
    { id: 'case', name: 'Case Study', icon: Zap, backend: 'CASE_STUDY' },
    { id: 'debate', name: 'Debate Club', icon: Users, backend: 'DEBATE_CLUB' },
];

const Settings = () => {
    const [selectedActivity, setSelectedActivity] = useState('gd');
    const [isSaving, setIsSaving] = useState(false);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Bulk Upload States
    const [isUploading, setIsUploading] = useState(false);
    const [uploadStatus, setUploadStatus] = useState<'idle' | 'success' | 'error'>('idle');
    const [message, setMessage] = useState('');
    const fileInputRef = useRef<HTMLInputElement>(null);

    // Question Bulk Upload States
    const [isUploadingQuestions, setIsUploadingQuestions] = useState(false);
    const [questionUploadStatus, setQuestionUploadStatus] = useState<'idle' | 'success' | 'error'>('idle');
    const [questionMessage, setQuestionMessage] = useState('');
    const questionFileInputRef = useRef<HTMLInputElement>(null);

    const [configs, setConfigs] = useState<Record<string, any>>({
        gd: { minStudents: 5, maxStudents: 15, quorumThreshold: 70, duration: 45, warning: 5, cooldown: 120, weights: { technical: 40, delivery: 35, synergy: 25 }, rewards: true, intel: true },
        tech: { minStudents: 3, maxStudents: 8, quorumThreshold: 60, duration: 60, warning: 10, cooldown: 180, weights: { technical: 60, delivery: 20, synergy: 20 }, rewards: true, intel: true },
        pres: { minStudents: 4, maxStudents: 10, quorumThreshold: 70, duration: 30, warning: 3, cooldown: 60, weights: { technical: 30, delivery: 50, synergy: 20 }, rewards: false, intel: true },
        case: { minStudents: 4, maxStudents: 12, quorumThreshold: 80, duration: 90, warning: 15, cooldown: 300, weights: { technical: 50, delivery: 30, synergy: 20 }, rewards: true, intel: false },
        debate: { minStudents: 2, maxStudents: 6, quorumThreshold: 75, duration: 40, warning: 5, cooldown: 120, weights: { technical: 20, delivery: 40, synergy: 40 }, rewards: true, intel: true }
    });

    useEffect(() => {
        const fetchSettings = async () => {
            try {
                setLoading(true);
                const activity = ACTIVITIES.find(a => a.id === selectedActivity);
                if (!activity) return;

                const response = await fetch(`http://localhost:8080/api/activity-settings/${activity.backend}`);
                if (!response.ok) throw new Error('Failed to fetch activity settings');

                const data = await response.json();

                // Extract settings from either a single object or an array (for robustness)
                const setting = Array.isArray(data) ? data[0] : (data.value ? data.value[0] : data);

                if (setting) {
                    setConfigs(prev => ({
                        ...prev,
                        [selectedActivity]: {
                            minStudents: setting.min_students || 5,
                            maxStudents: setting.max_students || 15,
                            quorumThreshold: Math.round((setting.quorum_threshold || 0.7) * 100),
                            duration: setting.time_limit_min,
                            warning: prev[selectedActivity]?.warning || 5,
                            cooldown: setting.cool_down_sec,
                            weights: {
                                technical: setting.weight_technical,
                                delivery: setting.weight_communication,
                                synergy: setting.weight_synergy
                            },
                            rewards: setting.auto_rewards,
                            intel: setting.intel_feedback
                        }
                    }));
                }
                setError(null);
            } catch (err: any) {
                console.error(err);
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        fetchSettings();
    }, [selectedActivity]);

    const currentConfig = configs[selectedActivity];

    const updateConfig = (field: string, value: any) => {
        setConfigs(prev => ({ ...prev, [selectedActivity]: { ...prev[selectedActivity], [field]: value } }));
    };



    const handleSave = async () => {
        setIsSaving(true);
        try {
            const activity = ACTIVITIES.find(a => a.id === selectedActivity);
            if (!activity) return;

            const payload = {
                activity_type: activity.backend,
                min_students: currentConfig.minStudents,
                max_students: currentConfig.maxStudents,
                quorum_threshold: currentConfig.quorumThreshold / 100,
                time_limit_min: currentConfig.duration,
                cool_down_sec: currentConfig.cooldown,
                weight_technical: currentConfig.weights.technical,
                weight_communication: currentConfig.weights.delivery,
                weight_synergy: currentConfig.weights.synergy,
                auto_rewards: currentConfig.rewards,
                intel_feedback: currentConfig.intel
            };

            const response = await fetch(`http://localhost:8080/api/activity-settings/${activity.backend}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || 'Failed to update settings');
            }

            // Re-fetch to confirm changes and sync with any backend-side transformations
            const refreshResponse = await fetch(`http://localhost:8080/api/activity-settings/${activity.backend}`);
            if (refreshResponse.ok) {
                const refreshedData = await refreshResponse.json();
                const setting = Array.isArray(refreshedData) ? refreshedData[0] : (refreshedData.value ? refreshedData.value[0] : refreshedData);
                if (setting) {
                    setConfigs(prev => ({
                        ...prev,
                        [selectedActivity]: {
                            minStudents: setting.min_students || 5,
                            maxStudents: setting.max_students || 15,
                            quorumThreshold: Math.round((setting.quorum_threshold || 0.7) * 100),
                            duration: setting.time_limit_min,
                            warning: prev[selectedActivity]?.warning || 5,
                            cooldown: setting.cool_down_sec,
                            weights: {
                                technical: setting.weight_technical,
                                delivery: setting.weight_communication,
                                synergy: setting.weight_synergy
                            },
                            rewards: setting.auto_rewards,
                            intel: setting.intel_feedback
                        }
                    }));
                }
            }

            setIsSaving(false);
        } catch (err: any) {
            console.error(err);
            alert('Error updating settings: ' + err.message);
            setIsSaving(false);
        }
    };

    const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('file', file);

        setIsUploading(true);
        setUploadStatus('idle');
        setMessage('');

        try {
            const response = await api.post('/users/bulk-upload', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });

            const data = response.data;
            setUploadStatus('success');
            setMessage(`Successfully processed ${data.count || 'all'} students.`);
        } catch (error: any) {
            console.error('Upload error:', error);
            setUploadStatus('error');
            setMessage(error.response?.data?.message || error.message || 'Failed to upload file.');
        } finally {
            setIsUploading(false);
            if (fileInputRef.current) {
                fileInputRef.current.value = ''; // Reset input
            }
        }
    };

    const handleQuestionUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('file', file);
        formData.append('activity_type', ACTIVITIES.find(a => a.id === selectedActivity)?.backend || '');

        setIsUploadingQuestions(true);
        setQuestionUploadStatus('idle');
        setQuestionMessage('');

        try {
            const response = await api.post('/evaluation-questions/bulk-upload', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });

            const data = response.data;
            setQuestionUploadStatus('success');
            setQuestionMessage(`Successfully processed ${data.count || 'all'} questions.`);
        } catch (error: any) {
            console.error('Question upload error:', error);
            setQuestionUploadStatus('error');
            setQuestionMessage(error.response?.data?.message || error.message || 'Failed to upload questions.');
        } finally {
            setIsUploadingQuestions(false);
            if (questionFileInputRef.current) {
                questionFileInputRef.current.value = '';
            }
        }
    };

    const triggerFileInput = () => {
        fileInputRef.current?.click();
    };

    if (loading) {
        return (
            <div className="h-full min-h-screen flex flex-col items-center justify-center bg-white">
                <Loader2 className="w-10 h-10 text-[#3B82F6] animate-spin mb-4" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Loading configurations...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="h-full min-h-screen flex flex-col items-center justify-center bg-white">
                <div className="flex flex-col items-center justify-center p-8 bg-red-50 rounded-2xl border border-red-100 max-w-md text-center">
                    <Activity className="w-10 h-10 text-red-400 mb-4" />
                    <h2 className="text-sm font-black text-red-500 uppercase tracking-widest mb-1">Configuration Error</h2>
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-6">{error}</p>
                    <button
                        onClick={() => window.location.reload()}
                        className="px-6 py-2.5 bg-red-500 text-white rounded-xl text-[10px] font-black uppercase tracking-widest transition-all hover:bg-red-600 active:scale-95"
                    >
                        Retry Connection
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="relative min-h-screen bg-slate-50/50 selection:bg-blue-500/30 overflow-x-hidden">
            {/* Floating Background Orbs - Match Dashboard */}
            <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
                <motion.div
                    animate={{ rotate: 360, x: [0, 100, 0], y: [0, 50, 0] }}
                    transition={{ duration: 25, repeat: Infinity, ease: "linear" }}
                    className="absolute -top-40 -left-40 w-96 h-96 bg-blue-500/10 rounded-full blur-[100px]"
                />
                <motion.div
                    animate={{ rotate: -360, x: [0, -100, 0], y: [0, -50, 0] }}
                    transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
                    className="absolute top-1/2 -right-40 w-[500px] h-[500px] bg-cyan-400/10 rounded-full blur-[120px]"
                />
            </div>

            <div className="w-full pt-2 pb-16 px-4 md:px-8 space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-700">
                {/* Simplified Header */}
                {/* Enhanced Header */}
                <header className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                        <div className="relative group">
                            <div className="absolute inset-0 bg-primary/20 rounded-2xl blur-xl group-hover:bg-primary/30 transition-all duration-500" />
                            <div className="relative w-12 h-12 rounded-2xl border border-white bg-white/50 backdrop-blur-xl shadow-lg shadow-primary/5 flex items-center justify-center group-hover:scale-105 transition-transform duration-500">
                                <Shield className="w-6 h-6 text-primary" />
                            </div>
                        </div>
                        <div>
                            <h2 className="text-lg font-black text-slate-900 tracking-tight leading-none mb-1.5 flex items-center gap-2">
                                System Configuration
                                <span className="px-2 py-0.5 rounded-full bg-primary/10 text-[8px] font-black text-primary uppercase tracking-widest">Master</span>
                            </h2>
                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.1em]">Manage global activity behavior</p>
                        </div>
                    </div>

                    <motion.button
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={handleSave}
                        disabled={isSaving}
                        className={cn(
                            "group relative flex items-center gap-2.5 px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-[0.12em] transition-all overflow-hidden",
                            isSaving
                                ? "bg-slate-100 text-slate-400 border border-slate-200"
                                : "bg-primary text-white shadow-[0_10px_25px_-5px_rgba(var(--primary),0.3)] hover:shadow-[0_20px_35px_-10px_rgba(var(--primary),0.4)]"
                        )}
                    >
                        {!isSaving && <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent -translate-x-[120%] group-hover:translate-x-[120%] transition-transform duration-1000" />}
                        {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4 group-hover:rotate-12 transition-transform" />}
                        <span className="relative z-10">{isSaving ? 'Syncing...' : 'Apply Settings'}</span>
                    </motion.button>
                </header>

                {/* Compact Navigation */}
                {/* Modern Capsule Navigation */}
                <div className="p-1.5 bg-white border border-slate-200/60 rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.02)] flex items-center">
                    <nav className="flex items-center gap-2 w-full">
                        {ACTIVITIES.map((activity) => (
                            <button
                                key={activity.id}
                                onClick={() => setSelectedActivity(activity.id)}
                                className={cn(
                                    "relative flex-1 py-2.5 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all duration-300",
                                    selectedActivity === activity.id
                                        ? "text-primary scale-[1.02]"
                                        : "text-slate-400 hover:text-slate-600 hover:bg-slate-50/50"
                                )}
                            >
                                <div className="flex items-center justify-center gap-3 relative z-10">
                                    <activity.icon className={cn(
                                        "w-4 h-4 transition-transform duration-500",
                                        selectedActivity === activity.id ? "scale-110 rotate-3" : "opacity-60"
                                    )} />
                                    <span>{activity.name}</span>
                                </div>
                                {selectedActivity === activity.id && (
                                    <motion.div
                                        layoutId="activeTab"
                                        className="absolute inset-0 bg-primary/5 border border-primary/10 rounded-2xl z-0 shadow-inner"
                                        transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                                    />
                                )}
                            </button>
                        ))}
                    </nav>
                </div>

                {/* Parameters Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <motion.div
                        className="glass-card p-6 rounded-2xl relative overflow-hidden group border-white/40 bg-white/70 backdrop-blur-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_50px_rgba(0,0,0,0.1)] transition-all"
                    >
                        <div className="absolute top-0 right-0 w-32 h-32 bg-primary/5 blur-3xl rounded-full -translate-y-16 translate-x-16 group-hover:bg-primary/10 transition-colors duration-700" />
                        
                        <div className="relative z-10">
                            <div className="flex items-center gap-4 mb-8">
                                <div className="p-3 bg-primary/10 rounded-2xl text-primary transition-all duration-500 group-hover:scale-110 group-hover:rotate-3">
                                    <Users className="w-4 h-4" />
                                </div>
                                <div>
                                    <span className="text-[10px] font-black text-slate-900 uppercase tracking-[0.15em]">Student Range</span>
                                    <p className="text-[9px] font-bold text-slate-400 mt-0.5 uppercase tracking-wider">Per active session</p>
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-8 mb-10">
                                <div className="space-y-3">
                                    <div className="flex items-center justify-between">
                                        <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Minimum</span>
                                        <div className="flex gap-1.5">
                                            <button onClick={() => updateConfig('minStudents', Math.max(1, currentConfig.minStudents - 1))} className="w-7 h-7 rounded-lg border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-primary"><Minus className="w-3 h-3" /></button>
                                            <button onClick={() => updateConfig('minStudents', Math.min(currentConfig.maxStudents, currentConfig.minStudents + 1))} className="w-7 h-7 rounded-lg border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-primary"><Plus className="w-3 h-3" /></button>
                                        </div>
                                    </div>
                                    <div className="flex items-baseline gap-1.5">
                                        <span className="text-2xl font-black text-slate-900 tabular-nums tracking-tighter">{currentConfig.minStudents}</span>
                                        <span className="text-[10px] font-bold text-slate-300 uppercase">Pax</span>
                                    </div>
                                </div>
                                <div className="space-y-3">
                                    <div className="flex items-center justify-between">
                                        <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Maximum</span>
                                        <div className="flex gap-1.5">
                                            <button onClick={() => updateConfig('maxStudents', Math.max(currentConfig.minStudents, currentConfig.maxStudents - 1))} className="w-7 h-7 rounded-lg border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-primary"><Minus className="w-3 h-3" /></button>
                                            <button onClick={() => updateConfig('maxStudents', Math.min(200, currentConfig.maxStudents + 1))} className="w-7 h-7 rounded-lg border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-primary"><Plus className="w-3 h-3" /></button>
                                        </div>
                                    </div>
                                    <div className="flex items-baseline gap-1.5">
                                        <span className="text-2xl font-black text-slate-900 tabular-nums tracking-tighter">{currentConfig.maxStudents}</span>
                                        <span className="text-[10px] font-bold text-slate-300 uppercase">Pax</span>
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-3">
                                <div className="h-2.5 w-full bg-slate-100/50 rounded-full overflow-hidden flex p-0.5 border border-slate-50">
                                    <motion.div 
                                        initial={{ width: 0 }}
                                        animate={{ width: `${(currentConfig.minStudents / 200) * 100}%` }}
                                        className="h-full bg-slate-200/50 rounded-l-full" 
                                    />
                                    <motion.div 
                                        initial={{ width: 0 }}
                                        animate={{ width: `${((currentConfig.maxStudents - currentConfig.minStudents) / 200) * 100}%` }}
                                        className="h-full bg-gradient-to-r from-primary to-cyan-400 rounded-full shadow-[0_0_15px_rgba(var(--primary),0.3)]" 
                                    />
                                </div>
                                <div className="flex justify-between items-center">
                                    <span className="text-[9px] font-bold text-slate-300 uppercase tracking-widest">Range indicator</span>
                                    <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest"><span className="text-primary/60">Limit:</span> 200</div>
                                </div>
                            </div>
                        </div>
                    </motion.div>

                    <motion.div
                        className="glass-card p-6 rounded-2xl relative overflow-hidden group border-white/40 bg-white/70 backdrop-blur-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_50px_rgba(0,0,0,0.1)] transition-all"
                    >
                        <div className="absolute top-0 left-0 w-32 h-32 bg-cyan-400/5 blur-3xl rounded-full -translate-y-16 -translate-x-16 group-hover:bg-cyan-400/10 transition-colors duration-700" />

                        <div className="relative z-10">
                            <div className="flex items-center justify-between mb-10">
                                <div className="flex items-center gap-4">
                                    <div className="p-3 bg-cyan-400/10 rounded-2xl text-cyan-600 transition-all duration-500 group-hover:scale-110 group-hover:-rotate-3">
                                        <Activity className="w-4 h-4" />
                                    </div>
                                    <div>
                                        <span className="text-[10px] font-black text-slate-900 uppercase tracking-[0.15em]">Quorum Threshold</span>
                                        <p className="text-[9px] font-bold text-slate-400 mt-0.5 uppercase tracking-wider">Pass requirement</p>
                                    </div>
                                </div>
                                <div className="flex gap-1.5">
                                    <button onClick={() => updateConfig('quorumThreshold', Math.max(10, currentConfig.quorumThreshold - 5))} className="w-8 h-8 rounded-xl border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-cyan-500"><Minus className="w-4 h-4" /></button>
                                    <button onClick={() => updateConfig('quorumThreshold', Math.min(100, currentConfig.quorumThreshold + 5))} className="w-8 h-8 rounded-xl border border-slate-100 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white hover:shadow-md active:scale-90 transition-all text-slate-400 hover:text-cyan-500"><Plus className="w-4 h-4" /></button>
                                </div>
                            </div>

                            <div className="flex items-baseline gap-2 mb-8">
                                <span className="text-3xl font-black text-slate-900 tabular-nums tracking-tighter">{currentConfig.quorumThreshold}</span>
                                <span className="text-lg font-black text-slate-300 tracking-tighter">%</span>
                            </div>

                            <div className="space-y-4">
                                <div className="h-3 w-full bg-slate-100/50 rounded-full overflow-hidden p-1 border border-slate-50">
                                    <motion.div 
                                        initial={{ width: 0 }}
                                        animate={{ width: `${currentConfig.quorumThreshold}%` }} 
                                        className="h-full bg-gradient-to-r from-cyan-400 to-blue-500 rounded-full shadow-[0_0_15px_rgba(34,211,238,0.4)]" 
                                    />
                                </div>
                                <div className="flex justify-between items-center text-[9px] font-black uppercase tracking-widest text-slate-400">
                                    <span>Critical</span>
                                    <span className="text-cyan-500">Target</span>
                                    <span>Optimal</span>
                                </div>
                            </div>
                        </div>
                    </motion.div>
                </div>

                {/* Integration Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <motion.div 
                        className="glass-card p-6 rounded-2xl group relative overflow-hidden border-white/40 bg-white/70 backdrop-blur-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_50px_rgba(0,0,0,0.1)] transition-all"
                    >
                        <div className="flex items-center justify-between mb-8">
                            <div className="flex items-center gap-4">
                                <div className="p-3 bg-blue-500/10 rounded-2xl text-blue-600 transition-all duration-500 group-hover:scale-110 group-hover:rotate-3">
                                    <Database className="w-4 h-4" />
                                </div>
                                <div>
                                    <span className="text-[10px] font-black text-slate-900 uppercase tracking-[0.15em]">Student Repository</span>
                                    <p className="text-[9px] font-bold text-slate-400 mt-0.5 uppercase tracking-wider">Bulk database management</p>
                                </div>
                            </div>
                            <input type="file" ref={fileInputRef} onChange={handleFileUpload} accept=".xlsx,.xls,.csv" className="hidden" />
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={triggerFileInput}
                                disabled={isUploading}
                                className="px-5 py-2.5 bg-slate-900 text-white rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-black transition-all flex items-center gap-2.5 shadow-lg shadow-black/10"
                            >
                                {isUploading ? <Loader2 className="w-3 h-3 animate-spin" /> : <Upload className="w-3 h-3" />}
                                {isUploading ? 'Processing' : 'Import Data'}
                            </motion.button>
                        </div>
                        
                        <AnimatePresence>
                            {uploadStatus !== 'idle' && (
                                <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} className="mb-6 overflow-hidden">
                                    <div className={cn(
                                        "p-3 rounded-xl text-[9px] font-black flex items-center justify-between border", 
                                        uploadStatus === 'success' ? "bg-emerald-50 text-emerald-700 border-emerald-100" : "bg-red-50 text-red-700 border-red-100"
                                    )}>
                                        <span className="uppercase tracking-wider">{message}</span>
                                        <X className="w-4 h-4 cursor-pointer hover:rotate-90 transition-transform" onClick={() => setUploadStatus('idle')} />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>

                        <div className="flex items-center gap-3 text-[10px] font-black text-slate-400 bg-slate-50/50 backdrop-blur-sm px-4 py-3 rounded-xl border border-slate-100/50 group-hover:bg-blue-50/50 group-hover:border-blue-100/50 transition-colors duration-500">
                            <span className="uppercase tracking-[0.15em] opacity-40">Required Fields</span>
                            <div className="h-1 w-1 rounded-full bg-slate-300" />
                            <span className="text-slate-600 font-bold">name, email, roll</span>
                        </div>
                    </motion.div>

                    <motion.div 
                        className="glass-card p-6 rounded-2xl group relative overflow-hidden border-white/40 bg-white/70 backdrop-blur-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_50px_rgba(0,0,0,0.1)] transition-all"
                    >
                        <div className="flex items-center justify-between mb-8">
                            <div className="flex items-center gap-4">
                                <div className="p-3 bg-purple-500/10 rounded-2xl text-purple-600 transition-all duration-500 group-hover:scale-110 group-hover:-rotate-3">
                                    <Zap className="w-4 h-4" />
                                </div>
                                <div>
                                    <span className="text-[10px] font-black text-slate-900 uppercase tracking-[0.15em]">Evaluation Library</span>
                                    <p className="text-[9px] font-bold text-slate-400 mt-0.5 uppercase tracking-wider">Global logic parameters</p>
                                </div>
                            </div>
                            <input type="file" ref={questionFileInputRef} onChange={handleQuestionUpload} accept=".xlsx,.xls,.csv" className="hidden" />
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={() => questionFileInputRef.current?.click()}
                                disabled={isUploadingQuestions}
                                className="px-5 py-2.5 bg-slate-900 text-white rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-black transition-all flex items-center gap-2.5 shadow-lg shadow-black/10"
                            >
                                {isUploadingQuestions ? <Loader2 className="w-3 h-3 animate-spin" /> : <Upload className="w-3 h-3" />}
                                {isUploadingQuestions ? 'Syncing' : 'Bulk Sync'}
                            </motion.button>
                        </div>

                        <AnimatePresence>
                            {questionUploadStatus !== 'idle' && (
                                <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} className="mb-6 overflow-hidden">
                                    <div className={cn(
                                        "p-3 rounded-xl text-[9px] font-black flex items-center justify-between border", 
                                        questionUploadStatus === 'success' ? "bg-emerald-50 text-emerald-700 border-emerald-100" : "bg-red-50 text-red-700 border-red-100"
                                    )}>
                                        <span className="uppercase tracking-wider">{questionMessage}</span>
                                        <X className="w-4 h-4 cursor-pointer hover:rotate-90 transition-transform" onClick={() => setQuestionUploadStatus('idle')} />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>

                        <div className="flex items-center gap-3 text-[10px] font-black text-slate-400 bg-slate-50/50 backdrop-blur-sm px-4 py-3 rounded-xl border border-slate-100/50 group-hover:bg-purple-50/50 group-hover:border-purple-100/50 transition-colors duration-500">
                            <span className="uppercase tracking-[0.15em] opacity-40">Protocol</span>
                            <div className="h-1 w-1 rounded-full bg-slate-300" />
                            <span className="text-slate-600 font-bold italic">Type, Text, Weighting</span>
                        </div>
                    </motion.div>
                </div>
            </div>
        </div>
    );
};

export default Settings;
