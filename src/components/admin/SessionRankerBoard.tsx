import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Trophy, Medal, Crown, Award, Stars, TrendingUp } from 'lucide-react';

export interface Participant {
    id: number;
    name: string;
    table: string | null;
    rank: number | null;
    points: number;
}

interface SessionRankerBoardProps {
    participants: Participant[];
}

const rankStyles: Record<number, { 
    icon: React.ElementType; 
    bg: string; 
    text: string; 
    border: string; 
    badge: string; 
    ring: string;
    shadow: string;
    iconColor: string;
}> = {
    1: { 
        icon: Crown, 
        bg: 'bg-gradient-to-br from-amber-50/50 to-amber-100/50', 
        text: 'text-amber-800', 
        border: 'border-amber-200/40', 
        badge: 'bg-amber-100/60 text-amber-600', 
        ring: 'ring-amber-200/30',
        shadow: 'shadow-sm shadow-amber-200/10',
        iconColor: 'text-amber-500'
    },
    2: { 
        icon: Medal, 
        bg: 'bg-gradient-to-br from-slate-50/50 to-slate-100/50', 
        text: 'text-slate-700', 
        border: 'border-slate-200/40', 
        badge: 'bg-slate-100/60 text-slate-500', 
        ring: 'ring-slate-200/30',
        shadow: 'shadow-sm shadow-slate-200/10',
        iconColor: 'text-slate-400'
    },
    3: { 
        icon: Award, 
        bg: 'bg-gradient-to-br from-orange-50/50 to-orange-100/50', 
        text: 'text-orange-800', 
        border: 'border-orange-200/40', 
        badge: 'bg-orange-100/60 text-orange-500', 
        ring: 'ring-orange-200/30',
        shadow: 'shadow-sm shadow-orange-200/10',
        iconColor: 'text-orange-400'
    },
};

const SessionRankerBoard: React.FC<SessionRankerBoardProps> = ({ participants }) => {
    const rankedParticipants = participants
        .filter(p => p.rank !== null)
        .sort((a, b) => (a.rank || 0) - (b.rank || 0));

    if (rankedParticipants.length === 0) {
        return (
            <motion.div 
                initial={{ opacity: 0, scale: 0.98 }}
                animate={{ opacity: 1, scale: 1 }}
                className="w-full py-16 text-center glass-card rounded-2xl border-dashed border border-slate-200"
            >
                <div className="relative inline-block mb-3">
                    <Trophy className="w-12 h-12 text-slate-200 mx-auto" />
                </div>
                <h3 className="text-xs font-bold text-slate-400 uppercase tracking-widest">Awaiting Results</h3>
                <p className="text-[10px] text-slate-300 mt-1 font-medium italic">Rankings will appear upon evaluation</p>
            </motion.div>
        );
    }

    const maxPoints = Math.max(...rankedParticipants.map(p => p.points), 1);

    return (
        <div className="w-full space-y-6">
            {/* Header Section */}
            <div className="flex items-center justify-between px-1">
                <div className="flex items-center gap-3">
                    <div className="p-1.5 bg-blue-50 rounded-lg">
                        <Stars className="w-3.5 h-3.5 text-blue-500" />
                    </div>
                    <div>
                        <h2 className="text-xl font-bold text-slate-800 tracking-tight">Session Leaderboard</h2>
                        <p className="text-[9px] font-semibold text-slate-400 uppercase tracking-wider">Evaluation Summary</p>
                    </div>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1 bg-slate-50 border border-slate-100 rounded-full">
                    <TrendingUp className="w-3 h-3 text-emerald-500" />
                    <span className="text-[9px] font-bold text-slate-500 uppercase">
                        {rankedParticipants.length} Ranked
                    </span>
                </div>
            </div>

            {/* Top 3 Podium — Subtle Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <AnimatePresence>
                    {rankedParticipants.slice(0, 3).map((p, idx) => {
                        const rank = idx + 1;
                        const style = rankStyles[rank as keyof typeof rankStyles] || rankStyles[2];
                        const Icon = style.icon;
                        const barWidth = maxPoints > 0 ? (Math.max(0, p.points) / maxPoints) * 100 : 0;

                        return (
                            <motion.div
                                key={p.id}
                                initial={{ opacity: 0, y: 15 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: idx * 0.1 }}
                                className={`relative p-5 rounded-2xl border ${style.border} ${style.bg} ${style.shadow} transition-all duration-300 cursor-default`}
                            >
                                <div className="absolute top-2 right-4 opacity-5 pointer-events-none">
                                    <Icon size={64} />
                                </div>

                                <div className="flex items-start justify-between mb-6">
                                    <div className={`w-9 h-9 rounded-xl ${style.badge} flex items-center justify-center shadow-sm`}>
                                        <Icon className="w-4.5 h-4.5" />
                                    </div>
                                    <div className="flex flex-col items-end opacity-20">
                                        <span className={`text-2xl font-bold ${style.text} leading-none`}>#{rank}</span>
                                    </div>
                                </div>

                                <div className="space-y-0.5">
                                    <h3 className={`font-bold text-sm ${style.text} truncate`}>{p.name}</h3>
                                    <p className={`text-[9px] font-semibold ${style.text} opacity-50 uppercase tracking-wider`}>
                                        {p.table || 'Evaluated'}
                                    </p>
                                </div>

                                <div className="mt-6 flex items-end justify-between">
                                    <div className="flex flex-col">
                                        <span className={`text-[8px] font-bold uppercase tracking-wider ${style.text} opacity-40`}>Score</span>
                                        <div className="flex items-baseline gap-0.5 mt-0.5">
                                            <span className={`text-2xl font-bold ${style.text}`}>{p.points}</span>
                                            <span className={`text-[9px] font-bold uppercase ${style.text} opacity-40`}>pts</span>
                                        </div>
                                    </div>
                                    <TrendingUp className={`w-4 h-4 ${style.iconColor} opacity-40`} />
                                </div>
                                
                                <div className="mt-3 h-1 w-full bg-slate-200/30 rounded-full overflow-hidden">
                                    <motion.div 
                                        initial={{ width: 0 }}
                                        animate={{ width: `${barWidth}%` }}
                                        transition={{ duration: 1, delay: 0.3 + idx * 0.1 }}
                                        className={`h-full ${rank === 1 ? 'bg-amber-400/40' : rank === 2 ? 'bg-slate-400/40' : 'bg-orange-400/40'}`}
                                    />
                                </div>
                            </motion.div>
                        );
                    })}
                </AnimatePresence>
            </div>

            {/* Remaining Participants — Clean List */}
            {rankedParticipants.length > 3 && (
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.4 }}
                    className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden"
                >
                    <div className="px-5 py-3.5 bg-slate-50/50 border-b border-slate-100 flex items-center justify-between">
                        <div className="flex items-center gap-2">
                            <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Extended Rankings</span>
                        </div>
                        <span className="text-[9px] font-semibold text-slate-400">
                            {rankedParticipants.length - 3} more participants
                        </span>
                    </div>

                    <div className="divide-y divide-slate-50">
                        {rankedParticipants.slice(3).map((p, idx) => {
                            const barWidth = maxPoints > 0 ? (Math.max(0, p.points) / maxPoints) * 100 : 0;
                            return (
                                <motion.div 
                                    key={p.id} 
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    transition={{ delay: 0.5 + idx * 0.05 }}
                                    className="px-5 py-3 flex items-center gap-4 group hover:bg-slate-50/50 transition-colors"
                                >
                                    <div className="w-7 h-7 rounded bg-slate-100 flex-shrink-0 flex items-center justify-center text-[10px] font-bold text-slate-400 group-hover:bg-slate-200 group-hover:text-slate-600 transition-colors">
                                        {idx + 4}
                                    </div>

                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center justify-between mb-1">
                                            <div>
                                                <h5 className="font-semibold text-xs text-slate-700 truncate tracking-tight">
                                                    {p.name}
                                                </h5>
                                                <p className="text-[8px] font-semibold text-slate-400 uppercase tracking-wider">
                                                    {p.table || 'Standard Track'}
                                                </p>
                                            </div>
                                            <div className="flex items-baseline gap-0.5">
                                                <span className="font-bold text-sm text-slate-800 tracking-tight">
                                                    {p.points}
                                                </span>
                                                <span className="text-[8px] font-bold text-slate-300 uppercase">pts</span>
                                            </div>
                                        </div>
                                        <div className="h-1 w-full bg-slate-100 rounded-full overflow-hidden">
                                            <motion.div
                                                initial={{ width: 0 }}
                                                animate={{ width: `${barWidth}%` }}
                                                transition={{ duration: 0.8, delay: 0.6 + idx * 0.05 }}
                                                className="h-full rounded-full bg-blue-400/20"
                                            />
                                        </div>
                                    </div>
                                </motion.div>
                            );
                        })}
                    </div>
                </motion.div>
            )}
        </div>
    );
};

export default SessionRankerBoard;
