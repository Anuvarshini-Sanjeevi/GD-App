import React from 'react';
import { motion } from 'framer-motion';
import { Trophy, Medal, Crown, Sparkles } from 'lucide-react';

interface Participant {
    id: number;
    name: string;
    table: string | null;
    rank: number | null;
    points: number;
}

interface SessionRankerBoardProps {
    participants: Participant[];
}

const SessionRankerBoard: React.FC<SessionRankerBoardProps> = ({ participants }) => {
    // Filter and sort ranked participants
    const rankedParticipants = participants
        .filter(p => p.rank !== null)
        .sort((a, b) => (a.rank || 0) - (b.rank || 0));

    const topThree = rankedParticipants.slice(0, 3);
    const rest = rankedParticipants.slice(3);

    return (
        <div className="w-full max-w-4xl mx-auto p-6 space-y-8">
            <motion.div
                initial={{ opacity: 0, y: -20 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-center space-y-2"
            >
                <div className="inline-flex items-center justify-center p-3 bg-blue-50 rounded-full mb-4 shadow-sm">
                    <Trophy className="w-8 h-8 text-blue-600" />
                </div>
                <h2 className="text-3xl font-black text-slate-800 tracking-tight">Session Governance Leaderboard</h2>
                <p className="text-slate-500 font-medium">Final Rankings & Performance Metrics</p>
            </motion.div>

            {/* Top 3 Podium */}
            <div className="flex flex-col md:flex-row items-end justify-center gap-4 md:gap-8 min-h-[300px] py-8">
                {/* 2nd Place */}
                {topThree[1] && (
                    <motion.div
                        initial={{ opacity: 0, y: 50 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="order-2 md:order-1 flex-1 w-full max-w-[240px] flex flex-col items-center"
                    >
                        <div className="relative w-full aspect-[3/4] bg-white rounded-t-3xl rounded-b-xl shadow-lg border-2 border-slate-100 flex flex-col items-center justify-end p-4 hover:shadow-xl transition-shadow overflow-hidden group">
                            <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-slate-50/50" />
                            <div className="absolute top-4 left-1/2 -translate-x-1/2">
                                <Medal className="w-12 h-12 text-slate-400 drop-shadow-sm" />
                            </div>
                            <div className="z-10 text-center space-y-1 mb-4">
                                <h3 className="font-bold text-slate-700 text-lg line-clamp-1">{topThree[1].name}</h3>
                                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">{topThree[1].table}</p>
                                <div className="mt-2 inline-block px-3 py-1 bg-slate-100 rounded-lg">
                                    <span className="font-black text-slate-600">{topThree[1].points}</span>
                                    <span className="text-[10px] text-slate-400 ml-1">PTS</span>
                                </div>
                            </div>
                            <div className="w-full h-2 bg-slate-300 rounded-full mb-2" />
                            <div className="text-4xl font-black text-slate-200">2</div>
                        </div>
                    </motion.div>
                )}

                {/* 1st Place */}
                {topThree[0] && (
                    <motion.div
                        initial={{ opacity: 0, y: 50, scale: 0.9 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        transition={{ delay: 0.4 }}
                        className="order-1 md:order-2 flex-1 w-full max-w-[280px] flex flex-col items-center z-10 -mt-8"
                    >
                        <div className="relative w-full aspect-[3/4] bg-gradient-to-br from-blue-600 to-indigo-600 rounded-t-3xl rounded-b-xl shadow-2xl border-4 border-white flex flex-col items-center justify-end p-6 hover:scale-105 transition-transform overflow-hidden">
                            <div className="absolute top-0 inset-x-0 h-32 bg-white/10 blur-xl rounded-full -translate-y-1/2" />
                            <div className="absolute top-6 left-1/2 -translate-x-1/2">
                                <Crown className="w-16 h-16 text-yellow-400 drop-shadow-lg animate-pulse" />
                            </div>
                            <div className="z-10 text-center space-y-2 mb-6">
                                <h3 className="font-bold text-white text-xl line-clamp-1">{topThree[0].name}</h3>
                                <p className="text-xs font-bold text-blue-200 uppercase tracking-widest">{topThree[0].table}</p>
                                <div className="mt-3 inline-block px-4 py-1.5 bg-white/20 backdrop-blur-md rounded-xl border border-white/20">
                                    <span className="font-black text-white text-lg">{topThree[0].points}</span>
                                    <span className="text-[10px] text-blue-100 ml-1 font-bold">PTS</span>
                                </div>
                            </div>
                            <div className="absolute inset-x-0 bottom-0 h-1/3 bg-gradient-to-t from-black/20 to-transparent" />
                            <div className="text-6xl font-black text-white/20 absolute bottom-4">1</div>
                            <Sparkles className="absolute top-10 right-8 text-yellow-300 w-6 h-6 animate-spin-slow" />
                        </div>
                    </motion.div>
                )}

                {/* 3rd Place */}
                {topThree[2] && (
                    <motion.div
                        initial={{ opacity: 0, y: 50 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.3 }}
                        className="order-3 flex-1 w-full max-w-[240px] flex flex-col items-center"
                    >
                        <div className="relative w-full aspect-[3/4] bg-white rounded-t-3xl rounded-b-xl shadow-lg border-2 border-orange-50 flex flex-col items-center justify-end p-4 hover:shadow-xl transition-shadow overflow-hidden group">
                            <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-orange-50/30" />
                            <div className="absolute top-4 left-1/2 -translate-x-1/2">
                                <Medal className="w-12 h-12 text-orange-400 drop-shadow-sm" />
                            </div>
                            <div className="z-10 text-center space-y-1 mb-4">
                                <h3 className="font-bold text-slate-700 text-lg line-clamp-1">{topThree[2].name}</h3>
                                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">{topThree[2].table}</p>
                                <div className="mt-2 inline-block px-3 py-1 bg-orange-50 rounded-lg">
                                    <span className="font-black text-orange-600">{topThree[2].points}</span>
                                    <span className="text-[10px] text-orange-400 ml-1">PTS</span>
                                </div>
                            </div>
                            <div className="w-full h-2 bg-orange-200 rounded-full mb-2" />
                            <div className="text-4xl font-black text-orange-100">3</div>
                        </div>
                    </motion.div>
                )}
            </div>

            {/* List View for Others */}
            {rest.length > 0 && (
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.6 }}
                    className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden"
                >
                    <div className="p-4 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
                        <h4 className="font-bold text-slate-700 text-sm uppercase tracking-wider">Honorable Mentions</h4>
                        <span className="text-xs font-semibold text-slate-400">{rest.length} Participants</span>
                    </div>
                    <div className="divide-y divide-slate-100">
                        {rest.map((participant, index) => (
                            <div key={participant.id} className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                                <div className="flex items-center gap-4">
                                    <div className="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-sm">
                                        {index + 4}
                                    </div>
                                    <div>
                                        <h5 className="font-bold text-slate-800 text-sm">{participant.name}</h5>
                                        <p className="text-xs text-slate-400">{participant.table}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className="font-bold text-slate-700">{participant.points}</span>
                                    <span className="text-[10px] font-bold text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded">PTS</span>
                                </div>
                            </div>
                        ))}
                    </div>
                </motion.div>
            )}
        </div>
    );
};

export default SessionRankerBoard;
