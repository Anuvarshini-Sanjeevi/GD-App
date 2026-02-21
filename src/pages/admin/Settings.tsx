import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import {
    Settings as SettingsIcon,
    MessageSquare,
    Monitor,
    Presentation,
    Zap,
    Users,
    Clock,
    Save,
    ArrowUpCircle,
    Shield,
    Activity,
    Trophy,
    Loader2,
    Upload,
    X,
    CheckCircle2,
    AlertCircle,
    FileSpreadsheet,
    Download
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

    const [configs, setConfigs] = useState<Record<string, any>>({
        gd: { promotionScore: 85, capacity: 10, duration: 45, warning: 5, cooldown: 120, weights: { technical: 40, delivery: 35, synergy: 25 }, rewards: true, intel: true },
        tech: { promotionScore: 90, capacity: 5, duration: 60, warning: 10, cooldown: 180, weights: { technical: 60, delivery: 20, synergy: 20 }, rewards: true, intel: true },
        pres: { promotionScore: 80, capacity: 8, duration: 30, warning: 3, cooldown: 60, weights: { technical: 30, delivery: 50, synergy: 20 }, rewards: false, intel: true },
        case: { promotionScore: 88, capacity: 6, duration: 90, warning: 15, cooldown: 300, weights: { technical: 50, delivery: 30, synergy: 20 }, rewards: true, intel: false },
        debate: { promotionScore: 92, capacity: 4, duration: 40, warning: 5, cooldown: 120, weights: { technical: 20, delivery: 40, synergy: 40 }, rewards: true, intel: true }
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
                            promotionScore: setting.advancement_pts,
                            capacity: setting.max_capacity,
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

    const updateWeight = (key: string, value: number) => {
        setConfigs(prev => ({
            ...prev,
            [selectedActivity]: {
                ...prev[selectedActivity],
                weights: { ...prev[selectedActivity].weights, [key]: value }
            }
        }));
    };

    const handleSave = async () => {
        setIsSaving(true);
        try {
            const activity = ACTIVITIES.find(a => a.id === selectedActivity);
            if (!activity) return;

            const payload = {
                activity_type: activity.backend,
                advancement_pts: currentConfig.promotionScore,
                max_capacity: currentConfig.capacity,
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
                            promotionScore: setting.advancement_pts,
                            capacity: setting.max_capacity,
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
        <div className="h-full flex flex-col bg-[#F9FAFB] animate-in fade-in duration-500">
            {/* Sync Header Scale */}
            <header className="px-8 py-6 flex items-center justify-between bg-white border-b border-slate-100 sticky top-0 z-40">
                <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center border border-blue-100">
                        <SettingsIcon className="w-5 h-5 text-[#3B82F6]" />
                    </div>
                    <div>
                        <h1 className="text-xl font-black text-slate-900 tracking-tight leading-none mb-1.5">Calibration Panel</h1>
                        <p className="text-[10px] font-bold text-[#3B82F6] uppercase tracking-widest leading-none">System Settings</p>
                    </div>
                </div>

                <div className="flex items-center gap-5">
                    <button
                        onClick={handleSave}
                        disabled={isSaving}
                        className={cn(
                            "flex items-center gap-2 px-5 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all",
                            isSaving
                                ? "bg-slate-100 text-slate-400 cursor-wait"
                                : "bg-[#3B82F6] text-white hover:bg-[#2563EB] shadow-lg shadow-blue-500/20 active:scale-95"
                        )}
                    >
                        <Save className={cn("w-4 h-4", isSaving && "animate-spin")} />
                        {isSaving ? 'Updating...' : 'Save Changes'}
                    </button>
                </div>
            </header>

            {/* Sync Tab Scale */}
            <nav className="px-8 bg-white border-b border-slate-100 flex items-center gap-1 overflow-x-auto scrollbar-hide">
                {ACTIVITIES.map((activity) => (
                    <button
                        key={activity.id}
                        onClick={() => setSelectedActivity(activity.id)}
                        className={cn(
                            "relative px-6 py-4 text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap group",
                            selectedActivity === activity.id ? "text-[#3B82F6]" : "text-slate-400 hover:text-slate-600"
                        )}
                    >
                        <div className="flex items-center gap-2.5">
                            <activity.icon className={cn("w-3.5 h-3.5", selectedActivity === activity.id ? "opacity-100" : "opacity-40 group-hover:opacity-100")} />
                            {activity.name}
                        </div>
                        {selectedActivity === activity.id && (
                            <motion.div
                                layoutId="vibrantBlueTab"
                                className="absolute bottom-0 left-0 right-0 h-[2.5px] bg-[#3B82F6] rounded-t-full z-10"
                                transition={{ type: "spring", bounce: 0, duration: 0.4 }}
                            />
                        )}
                    </button>
                ))}
            </nav>

            {/* Content Area - Synced Scaling */}
            <main className="flex-1 overflow-y-auto p-8 scrollbar-hide">
                <div className="max-w-6xl mx-auto">
                    <div className="grid grid-cols-12 gap-6">

                        {/* Logic Column */}
                        <div className="col-span-12 lg:col-span-8 space-y-8">

                            {/* Operational Parameters */}
                            <div className="space-y-4">
                                <div className="flex items-center gap-2 px-1">
                                    <div className="w-1 h-3 bg-[#3B82F6] rounded-full" />
                                    <h2 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Operational Matrix</h2>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                                    {[
                                        { label: 'Advancement', key: 'promotionScore', unit: 'pts', icon: ArrowUpCircle },
                                        { label: 'Max Capacity', key: 'capacity', unit: 'unit', icon: Users },
                                        { label: 'Time Limit', key: 'duration', unit: 'min', icon: Clock },
                                        { label: 'Cool Down', key: 'cooldown', unit: 'sec', icon: Shield },
                                    ].map(card => (
                                        <div key={card.key} className="bg-white border border-slate-100 p-5 rounded-2xl shadow-sm hover:border-blue-100 transition-all group">
                                            <div className="flex items-center justify-between mb-4">
                                                <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest leading-none">{card.label}</p>
                                                <card.icon className="w-3.5 h-3.5 text-slate-200 group-hover:text-[#3B82F6] transition-colors" />
                                            </div>
                                            <div className="flex items-baseline gap-2">
                                                <input
                                                    type="number"
                                                    value={currentConfig[card.key]}
                                                    onChange={(e) => updateConfig(card.key, parseInt(e.target.value) || 0)}
                                                    className="bg-transparent text-2xl font-black text-slate-800 outline-none w-14 tracking-tighter tabular-nums focus:text-[#3B82F6]"
                                                />
                                                <span className="text-[8px] font-black text-slate-300 uppercase">{card.unit}</span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* Performance Weighing */}
                            <div className="space-y-4">
                                <div className="flex items-center gap-2 px-1">
                                    <div className="w-1 h-3 bg-[#3B82F6] rounded-full" />
                                    <h2 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Performance Weighing</h2>
                                </div>

                                <div className="space-y-3">
                                    {[
                                        { name: 'Technical Excellence', key: 'technical' },
                                        { name: 'Communication Depth', key: 'delivery' },
                                        { name: 'Collaborative Synergy', key: 'synergy' },
                                    ].map((m) => (
                                        <div key={m.key} className="bg-white border border-slate-100 p-5 rounded-2xl shadow-sm flex items-center justify-between group hover:border-blue-100 transition-all">
                                            <div className="flex-1 max-w-sm">
                                                <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest mb-3 leading-none">{m.name}</p>
                                                <div className="h-1 bg-slate-50 rounded-full overflow-hidden">
                                                    <motion.div
                                                        animate={{ width: `${currentConfig.weights[m.key]}%` }}
                                                        className="h-full bg-[#3B82F6]"
                                                    />
                                                </div>
                                            </div>
                                            <div className="flex items-baseline gap-2">
                                                <input
                                                    type="number"
                                                    value={currentConfig.weights[m.key]}
                                                    onChange={(e) => updateWeight(m.key, parseInt(e.target.value) || 0)}
                                                    className="bg-transparent text-2xl font-black text-slate-800 outline-none w-12 text-right tabular-nums focus:text-[#3B82F6]"
                                                />
                                                <span className="text-[8px] font-black text-slate-300 uppercase">%</span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>

                        {/* Modules Column */}
                        <div className="col-span-12 lg:col-span-4 space-y-4">
                            <div className="flex items-center gap-2 px-1">
                                <div className="w-1 h-3 bg-[#3B82F6] rounded-full" />
                                <h2 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">System Switches</h2>
                            </div>

                            <div className="grid grid-cols-1 gap-3">
                                {[
                                    { label: 'Automatic Rewards', key: 'rewards', icon: Trophy, desc: 'Merit system' },
                                    { label: 'Intel Feedback', key: 'intel', icon: Activity, desc: 'In-app feed' }
                                ].map((t) => (
                                    <div
                                        key={t.key}
                                        onClick={() => updateConfig(t.key, !currentConfig[t.key])}
                                        className="bg-white border border-slate-100 p-5 rounded-2xl shadow-sm cursor-pointer group hover:border-blue-100 transition-all flex items-center justify-between"
                                    >
                                        <div className="flex items-center gap-4">
                                            <div className={cn(
                                                "w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-300",
                                                currentConfig[t.key] ? "bg-[#3B82F6] text-white shadow-lg shadow-blue-500/10" : "bg-slate-50 text-slate-300"
                                            )}>
                                                <t.icon className="w-5 h-5" />
                                            </div>
                                            <div>
                                                <p className="text-sm font-black text-slate-800 uppercase tracking-tight leading-none mb-1.5">{t.label}</p>
                                                <p className="text-[8px] font-bold text-slate-400 uppercase tracking-widest leading-none">{t.desc}</p>
                                            </div>
                                        </div>
                                        <div className={cn(
                                            "w-9 h-5 rounded-full relative transition-colors duration-500 p-0.5",
                                            currentConfig[t.key] ? "bg-[#3B82F6]" : "bg-slate-100"
                                        )}>
                                            <motion.div
                                                animate={{ x: currentConfig[t.key] ? 16 : 0 }}
                                                className="w-4 h-4 bg-white rounded-full shadow-sm"
                                            />
                                        </div>
                                    </div>
                                ))}
                            </div>

                            {/* Data Management Section */}
                            <div className="space-y-4 mt-8">
                                <div className="flex items-center gap-2 px-1">
                                    <div className="w-1 h-3 bg-[#3B82F6] rounded-full" />
                                    <h2 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Data Management</h2>
                                </div>

                                <div className="bg-white border border-slate-100 p-6 rounded-2xl shadow-sm space-y-4">
                                    <div className="flex items-center justify-between">
                                        <div>
                                            <p className="text-sm font-black text-slate-800 uppercase tracking-tight leading-none mb-1.5">Student Database</p>
                                            <p className="text-[8px] font-bold text-slate-400 uppercase tracking-widest leading-none">Bulk enrollment via Excel/CSV</p>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <input
                                                type="file"
                                                ref={fileInputRef}
                                                onChange={handleFileUpload}
                                                accept=".xlsx,.xls,.csv"
                                                className="hidden"
                                            />
                                            <button
                                                onClick={triggerFileInput}
                                                disabled={isUploading}
                                                className="px-4 py-2 bg-[#3B82F6] text-white rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-[#2563EB] transition-all flex items-center gap-2 disabled:opacity-50"
                                            >
                                                {isUploading ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Upload className="w-3.5 h-3.5" />}
                                                <span>{isUploading ? 'Processing...' : 'Bulk Upload'}</span>
                                            </button>
                                        </div>
                                    </div>

                                    {/* Upload Status Banner */}
                                    <AnimatePresence mode="wait">
                                        {uploadStatus !== 'idle' && (
                                            <motion.div
                                                initial={{ opacity: 0, height: 0 }}
                                                animate={{ opacity: 1, height: 'auto' }}
                                                exit={{ opacity: 0, height: 0 }}
                                                className={`p-4 rounded-xl border flex items-center justify-between ${uploadStatus === 'success'
                                                    ? 'bg-emerald-50 border-emerald-100 text-emerald-700'
                                                    : 'bg-red-50 border-red-100 text-red-700'
                                                    }`}
                                            >
                                                <div className="flex items-center gap-3">
                                                    <div className={`w-8 h-8 rounded-full flex items-center justify-center ${uploadStatus === 'success' ? 'bg-emerald-100' : 'bg-red-100'}`}>
                                                        {uploadStatus === 'success' ? <CheckCircle2 className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
                                                    </div>
                                                    <div>
                                                        <p className="text-[10px] font-black uppercase tracking-wider">{uploadStatus === 'success' ? 'Success' : 'Error'}</p>
                                                        <p className="text-[9px] font-medium opacity-80">{message}</p>
                                                    </div>
                                                </div>
                                                <button onClick={() => setUploadStatus('idle')} className="p-1 hover:bg-slate-200/50 rounded-lg transition-colors">
                                                    <X className="w-3.5 h-3.5" />
                                                </button>
                                            </motion.div>
                                        )}
                                    </AnimatePresence>

                                    <div className="grid grid-cols-2 gap-3 pt-2">
                                        <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 group cursor-pointer hover:border-blue-100 transition-all">
                                            <div className="flex items-center gap-3 mb-2">
                                                <div className="p-2 bg-white rounded-lg shadow-sm">
                                                    <Download className="w-4 h-4 text-slate-400 group-hover:text-[#3B82F6]" />
                                                </div>
                                                <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Template</span>
                                            </div>
                                            <p className="text-[10px] font-bold text-slate-600">Download formatting guide</p>
                                        </div>
                                        <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 group cursor-pointer hover:border-blue-100 transition-all">
                                            <div className="flex items-center gap-3 mb-2">
                                                <div className="p-2 bg-white rounded-lg shadow-sm">
                                                    <FileSpreadsheet className="w-4 h-4 text-slate-400 group-hover:text-[#3B82F6]" />
                                                </div>
                                                <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Fields</span>
                                            </div>
                                            <p className="text-[10px] font-bold text-slate-600">RegNo, Name, Dept, Sec</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

export default Settings;
