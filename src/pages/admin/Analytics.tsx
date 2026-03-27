import { motion, AnimatePresence } from 'framer-motion';
import { useState, useEffect } from 'react';
import {
    Trophy,
    Medal,
    Monitor,
    MessageSquare,
    Presentation,
    Users as UsersIcon,
    ArrowRight,
    TrendingUp,
    Loader2,
    AlertCircle,
    Inbox
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import api from '../../utils/api';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

// --- Types & Mock Data ---
interface Participant {
    rank: number;
    name: string;
    score: number;
    stats: string;
    photo?: string;
    initials: string;
    level?: string;
}

const ACTIVITIES = [
    { id: 'gd', name: 'Group Discussion', icon: MessageSquare, hasLevels: true },
    { id: 'tech', name: 'Technical Events', icon: Monitor, hasLevels: true },
    { id: 'pres', name: 'Presentation', icon: Presentation, hasLevels: true },
    { id: 'debate', name: 'Debate Club', icon: UsersIcon, hasLevels: true },
];


const Analytics = () => {
    const [selectedActivity, setSelectedActivity] = useState(ACTIVITIES[0].id);
    const [participants, setParticipants] = useState<Participant[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const typeMap: Record<string, string> = {
        gd: 'GROUP_DISCUSSION',
        tech: 'TECHNICAL_EVENTS',
        pres: 'PRESENTATION',
        debate: 'DEBATE_CLUB'
    };



    const fetchAnalytics = async () => {
        try {
            setLoading(true);
            const backendType = typeMap[selectedActivity];
            const response = await api.get(`/admin-analytics/rankings?activity=${backendType}&level=ALL LEVELS`);

            const data = response.data;

            // Handle both direct array and nested 'value' object structure
            const rankings = Array.isArray(data) ? data : (data.value || []);

            if (rankings && rankings.length > 0) {
                const mapped = rankings.map((item: any, index: number) => {
                    // The API returns the raw user/team data directly coupled with metrics
                    const name = item.name || item.student_name || item.title || 'Unknown Participant';
                    const photo = item.photo_url || item.photo || item.image || item.avatar;

                    // Use points if available, otherwise total_score or score
                    const scoreValue = item.points ?? item.total_score ?? item.score;
                    const score = Number(scoreValue) || 0;

                    // Formatting initials
                    const initials = name
                        .split(' ')
                        .filter(Boolean)
                        .map((n: string) => n[0])
                        .join('')
                        .toUpperCase()
                        .slice(0, 2) || '??';

                    // Level and status
                    const level = item.level?.toLowerCase() || 'intermediate';
                    const stats = item.stats || (item.rank === 1 ? 'Top Performer' : `${level.charAt(0).toUpperCase() + level.slice(1)} Level`);

                    return {
                        rank: Number(item.rank) || index + 1,
                        name,
                        score,
                        stats,
                        photo,
                        initials,
                        level
                    };
                });

                setParticipants(mapped);
            } else {
                setParticipants([]);
            }
            setError(null);
        } catch (err: any) {
            console.error(err);
            setError(err.message);
            setParticipants([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAnalytics();
    }, [selectedActivity]);

    // specific level filtering is now done by backend, so we just use participants directly
    const filteredParticipants = participants;

    const topper = filteredParticipants[0];
    const others = filteredParticipants.slice(1);



    return (
        <div className="h-full flex flex-col bg-[#F9FAFB] animate-in fade-in duration-500">
            {/* Header */}
            <header className="px-6 py-4 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-40">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center border border-blue-100">
                        <TrendingUp className="w-4 h-4 text-[#3B82F6]" />
                    </div>
                    <div>
                        <h1 className="text-sm font-bold text-slate-900 tracking-tight leading-none mb-0.5">Activity Analytics</h1>
                        <p className="text-[9px] font-semibold text-[#3B82F6] uppercase tracking-wider leading-none">Level-wise Performance</p>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <div className="px-3 py-1.5 rounded-lg bg-blue-50 border border-blue-100 flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-[#3B82F6] animate-pulse" />
                        <span className="text-[9px] font-bold text-[#3B82F6] uppercase tracking-wider">Active</span>
                    </div>
                </div>
            </header>

            {/* Navigation */}
            <nav className="px-6 bg-white border-b border-slate-100 flex items-center gap-1 overflow-x-auto scrollbar-hide py-2">
                {ACTIVITIES.map((activity) => (
                    <button
                        key={activity.id}
                        onClick={() => {
                            setSelectedActivity(activity.id);
                        }}
                        className={cn(
                            "flex-shrink-0 flex items-center gap-2 px-4 py-2 rounded-lg transition-all duration-300",
                            selectedActivity === activity.id
                                ? "bg-blue-50 text-[#3B82F6] border border-blue-100"
                                : "text-slate-400 hover:text-slate-600 hover:bg-slate-50"
                        )}
                    >
                        <activity.icon className={cn(
                            "w-3.5 h-3.5",
                            selectedActivity === activity.id ? "text-[#3B82F6]" : "text-slate-300"
                        )} />
                        <span className="text-[9px] font-bold uppercase tracking-wide">{activity.name}</span>
                    </button>
                ))}
            </nav>



            <main className="flex-1 overflow-y-auto p-6 scrollbar-hide">
                <div className="max-w-6xl mx-auto space-y-6">
                    {loading ? (
                        <div className="flex flex-col items-center justify-center py-24">
                            <Loader2 className="w-10 h-10 text-blue-500 animate-spin mb-4" />
                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Loading data...</p>
                        </div>
                    ) : error ? (
                        <div className="flex flex-col items-center justify-center py-24 bg-white rounded-2xl border border-red-50">
                            <AlertCircle className="w-10 h-10 text-red-200 mb-4" />
                            <h3 className="text-xs font-bold text-red-500 uppercase tracking-wide mb-1">Error</h3>
                            <p className="text-[9px] font-semibold text-slate-400 uppercase tracking-wide">{error}</p>
                        </div>
                    ) : filteredParticipants.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-24 bg-white rounded-2xl border border-slate-50 border-dashed">
                            <Inbox className="w-10 h-10 text-slate-100 mb-4" />
                            <h3 className="text-xs font-bold text-slate-300 uppercase tracking-wide mb-1">No Data</h3>
                            <p className="text-[9px] font-semibold text-slate-300 uppercase tracking-wide">
                                No data for {selectedActivity.toUpperCase()}
                            </p>
                        </div>
                    ) : (
                        <>
                            {/* Hero Spotlight Card */}
                            <motion.div
                                key={`hero-${selectedActivity}-${topper?.name}`}
                                initial={{ opacity: 0, y: 15 }}
                                animate={{ opacity: 1, y: 0 }}
                                className="glass-card border-blue-100/50 p-6 rounded-2xl flex items-center justify-between shadow-lg shadow-blue-500/5 relative overflow-hidden group"
                            >
                                <div className="absolute top-0 right-0 p-6 opacity-5 group-hover:opacity-10 transition-opacity rotate-12">
                                    <Trophy className="w-24 h-24 text-[#3B82F6]" />
                                </div>

                                <div className="relative z-10 flex items-center gap-6">
                                    <div className="w-16 h-16 rounded-xl bg-blue-50 flex items-center justify-center border border-blue-100 overflow-hidden relative group/hero shadow-sm">
                                        {topper?.photo ? (
                                            <img src={topper.photo} alt={topper.name} className="w-full h-full object-cover transition-transform duration-500 group-hover/hero:scale-110" />
                                        ) : (
                                            <div className="flex flex-col items-center">
                                                <span className="text-xl font-bold text-[#3B82F6]">{topper?.initials}</span>
                                                <UsersIcon className="w-3 h-3 text-blue-200 mt-0.5" />
                                            </div>
                                        )}
                                        <div className="absolute inset-0 bg-gradient-to-t from-blue-500/10 to-transparent opacity-0 group-hover/hero:opacity-100 transition-opacity" />
                                    </div>
                                    <div>
                                        <div className="flex items-center gap-2 mb-2">
                                            <span className="px-2.5 py-0.5 rounded-lg bg-[#3B82F6] text-white text-[8px] font-bold uppercase tracking-wider shadow-sm shadow-blue-500/20">
                                                Champion #1
                                            </span>
                                            <Medal className="w-3 h-3 text-[#3B82F6]" />
                                        </div>
                                        <h2 className="text-xl font-bold text-slate-900 tracking-tight leading-none mb-1">{topper?.name}</h2>
                                        <p className="text-[9px] font-semibold text-slate-400 uppercase tracking-wide">{topper?.stats}</p>
                                    </div>
                                </div>

                                <div className="relative z-10 text-right pr-3">
                                    <p className="text-[8px] font-bold text-slate-400 uppercase tracking-wide mb-0.5">Score</p>
                                    <div className="flex items-baseline gap-1.5">
                                        <span className="text-3xl font-bold text-[#3B82F6] tracking-tight leading-none">{topper?.score}</span>
                                        <span className="text-xs font-bold text-slate-300 uppercase">pts</span>
                                    </div>
                                </div>
                            </motion.div>

                            {/* Standing Rows */}
                            <div className="space-y-2">
                                <div className="px-6 flex items-center text-[9px] font-bold text-slate-400 uppercase tracking-wide mb-2">
                                    <div className="w-12">Rank</div>
                                    <div className="flex-1">Participant</div>
                                    <div className="w-40 text-center">Progress</div>
                                    <div className="w-24 text-right">Points</div>
                                </div>

                                <AnimatePresence mode="popLayout">
                                    {others.map((item, idx) => (
                                        <motion.div
                                            key={`${selectedActivity}-${item.name}`}
                                            initial={{ opacity: 0, x: -10 }}
                                            animate={{ opacity: 1, x: 0 }}
                                            exit={{ opacity: 0, x: 10 }}
                                            transition={{ delay: idx * 0.03 }}
                                            className="group glass-card p-4 rounded-xl flex items-center transition-all hover:border-blue-200 hover:shadow-md cursor-pointer"
                                        >
                                            <div className="w-12">
                                                <div className="w-7 h-7 rounded-lg flex items-center justify-center text-[9px] font-bold bg-slate-50 text-slate-400 group-hover:bg-blue-50 group-hover:text-[#3B82F6] transition-all">
                                                    #{item.rank}
                                                </div>
                                            </div>

                                            <div className="flex-1 flex items-center gap-3">
                                                <div className="w-9 h-9 rounded-lg bg-white border border-slate-100 flex items-center justify-center overflow-hidden relative group/row shadow-sm transition-all group-hover:border-blue-100">
                                                    {item.photo ? (
                                                        <img src={item.photo} alt={item.name} className="w-full h-full object-cover transition-transform duration-500 group-hover/row:scale-110" />
                                                    ) : (
                                                        <div className="flex flex-col items-center">
                                                            <span className="text-[9px] font-bold text-slate-400 group-hover:text-[#3B82F6]">{item.initials}</span>
                                                        </div>
                                                    )}
                                                    <div className="absolute inset-0 bg-gradient-to-t from-blue-500/5 to-transparent opacity-0 group-hover/row:opacity-100 transition-opacity" />
                                                </div>
                                                <div>
                                                    <p className="text-xs font-bold text-slate-800 leading-none mb-1">{item.name}</p>
                                                    <p className="text-[8px] font-semibold text-slate-400 uppercase tracking-wide">{item.stats}</p>
                                                </div>
                                            </div>

                                            <div className="w-40 flex justify-center px-3">
                                                <div className="w-full h-1 bg-slate-50 rounded-full overflow-hidden">
                                                    <motion.div
                                                        initial={{ width: 0 }}
                                                        animate={{ width: `${item.score}%` }}
                                                        className="h-full bg-blue-200 group-hover:bg-[#3B82F6] transition-colors"
                                                    />
                                                </div>
                                            </div>

                                            <div className="w-24 text-right">
                                                <span className="text-lg font-bold text-slate-800 group-hover:text-[#3B82F6] transition-colors tracking-tight leading-none">{item.score}</span>
                                                <span className="text-[8px] font-bold text-slate-200 uppercase ml-1">pts</span>
                                            </div>

                                            <div className="w-8 flex justify-end opacity-0 group-hover:opacity-100 transition-opacity">
                                                <ArrowRight className="w-3.5 h-3.5 text-[#3B82F6]" />
                                            </div>
                                        </motion.div>
                                    ))}
                                </AnimatePresence>
                            </div>
                        </>
                    )}
                </div>
            </main>
        </div>
    );
};

export default Analytics;
