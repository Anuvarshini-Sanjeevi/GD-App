import {
    Users,
    Search,
    Filter
} from 'lucide-react';


const StudentManager = () => {
    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {/* Header Section */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-xl font-black text-slate-800 tracking-tight leading-none mb-1">Student Manager</h1>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none">Directory & Enrollment</p>
                </div>
                <div className="flex items-center gap-3">
                    <button className="p-2.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all">
                        <Search className="w-5 h-5" />
                    </button>
                    <button className="p-2.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all">
                        <Filter className="w-5 h-5" />
                    </button>
                </div>
            </div>

            {/* Empty State / Placeholder */}
            <div className="flex flex-col items-center justify-center py-32 bg-white/40 rounded-3xl border border-dashed border-slate-200 backdrop-blur-sm">
                <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mb-6 shadow-sm">
                    <Users className="w-8 h-8 text-slate-300" />
                </div>
                <h3 className="text-sm font-black text-slate-900 uppercase tracking-widest mb-2">Student Directory</h3>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest text-center max-w-xs leading-relaxed">
                    Access and manage student profiles.
                    <br />
                    Use the configuration panel for bulk data operations.
                </p>
            </div>
        </div>
    );
};

export default StudentManager;
