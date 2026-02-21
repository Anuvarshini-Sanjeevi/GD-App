import React from 'react';
import { motion } from 'framer-motion';
import { LogOut } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const StudentDashboard: React.FC = () => {
    const navigate = useNavigate();

    return (
        <div className="min-h-screen bg-slate-50 p-8">
            <div className="max-w-4xl mx-auto">
                <div className="flex justify-between items-center mb-8">
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Student Portal</h1>
                    <button
                        onClick={() => navigate('/')}
                        className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-xl text-slate-600 hover:bg-slate-50 transition-colors font-semibold shadow-sm"
                    >
                        <LogOut size={18} />
                        Logout
                    </button>
                </div>

                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white p-10 rounded-[2.5rem] border border-slate-100 shadow-sm text-center"
                >
                    <div className="w-20 h-20 bg-indigo-50 rounded-3xl flex items-center justify-center mx-auto mb-6">
                        <span className="text-2xl font-bold text-indigo-600">P</span>
                    </div>
                    <p className="text-slate-500 font-medium">Welcome to your Student Portal. Your activities, scores, and progress will be displayed here.</p>
                </motion.div>
            </div>
        </div>
    );
};

export default StudentDashboard;
