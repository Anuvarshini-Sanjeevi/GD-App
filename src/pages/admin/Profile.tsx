import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import {
    Mail,
    Phone,
    MapPin,
    Building2,
    Shield,
    LogOut,
    Loader2,
    AlertCircle,
    User
} from 'lucide-react';

const AdminProfile = () => {
    const [profileData, setProfileData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchProfile = async () => {
            try {
                setLoading(true);

                // Try /auth/me first
                let response = await fetch('http://localhost:8080/auth/me', {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/json' }
                });

                // If /auth/me fails, fallback to /api/admins/1
                if (!response.ok) {
                    response = await fetch('http://localhost:8080/api/admins/1', {
                        method: 'GET',
                        headers: { 'Content-Type': 'application/json' }
                    });
                }

                if (!response.ok) {
                    throw new Error(`Failed to fetch profile: ${response.status} ${response.statusText}`);
                }

                const data = await response.json();

                let admin = null;
                if (Array.isArray(data)) admin = data[0];
                else if (data.value && Array.isArray(data.value)) admin = data.value[0];
                else if (data.admin) admin = data.admin;
                else if (data.user) admin = data.user;
                else admin = data;

                if (admin) {
                    setProfileData({
                        name: admin.name || 'Admin User',
                        role: admin.role || 'Administrator',
                        email: admin.email || 'N/A',
                        phone: admin.phone || 'Not Provided',
                        location: admin.location || 'Headquarters',
                        department: admin.department || 'Computer Science & Engineering',
                        bio: admin.bio || 'Educational administrator with a focus on student engagement and academic excellence.',
                        photo: admin.photo
                    });
                    setError(null);
                } else {
                    setError('No admin data found in response');
                }
            } catch (err: any) {
                setError(err.message || 'Failed to load profile');
            } finally {
                setLoading(false);
            }
        };

        fetchProfile();
    }, []);

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-24">
                <Loader2 className="w-8 h-8 text-primary animate-spin mb-3" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Loading profile...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center py-20">
                <div className="bg-red-50 border border-red-100 p-8 rounded-2xl text-center max-w-sm w-full">
                    <AlertCircle className="w-10 h-10 text-red-400 mx-auto mb-3" />
                    <h3 className="text-sm font-bold text-red-600 mb-1">Error Loading Profile</h3>
                    <p className="text-[11px] font-medium text-slate-500 mb-5">{error}</p>
                    <button
                        onClick={() => window.location.reload()}
                        className="px-5 py-2 bg-white border border-red-100 text-red-500 rounded-lg text-[10px] font-bold uppercase tracking-wide hover:bg-red-50 transition-colors"
                    >
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    const contactItems = [
        { icon: Mail, label: 'Email', value: profileData.email, color: 'text-blue-500', bg: 'bg-blue-50' },
        { icon: Phone, label: 'Phone', value: profileData.phone, color: 'text-emerald-500', bg: 'bg-emerald-50' },
        { icon: MapPin, label: 'Location', value: profileData.location, color: 'text-orange-500', bg: 'bg-orange-50' },
        { icon: Building2, label: 'Department', value: profileData.department, color: 'text-purple-500', bg: 'bg-purple-50' },
    ];

    const initials = profileData.name.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase();

    return (
        <div className="space-y-6 pb-12 animate-in fade-in slide-in-from-bottom-2 duration-700">
            {/* Profile Hero Section */}
            <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="relative overflow-hidden bg-white border border-slate-100 rounded-[1.5rem] shadow-sm"
            >
                {/* Refined Banner */}
                <div className="h-28 bg-gradient-to-r from-primary to-indigo-600 relative">
                    <div className="absolute inset-0 opacity-[0.05]"
                        style={{ backgroundImage: 'radial-gradient(circle at 2px 2px, white 1px, transparent 0)', backgroundSize: '24px 24px' }}
                    />
                </div>

                <div className="px-8 pb-8">
                    {/* Premium Avatar */}
                    <div className="relative -mt-12 mb-5 inline-block">
                        <div className="w-24 h-24 rounded-3xl border-4 border-white bg-white flex items-center justify-center shadow-xl shadow-slate-200/50 overflow-hidden">
                            {profileData.photo ? (
                                <img src={profileData.photo} alt="Profile" className="w-full h-full object-cover" />
                            ) : (
                                <div className="w-full h-full bg-gradient-to-br from-primary to-indigo-600 flex items-center justify-center">
                                    <span className="text-2xl font-black text-white">{initials}</span>
                                </div>
                            )}
                        </div>
                        <div className="absolute bottom-1 right-1 w-5 h-5 bg-emerald-500 border-3 border-white rounded-full shadow-sm" />
                    </div>

                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                        <div className="space-y-1">
                            <h2 className="text-2xl font-black text-slate-900 tracking-tight">{profileData.name}</h2>
                            <div className="flex items-center gap-3">
                                <div className="flex items-center gap-1.5 px-2 py-0.5 bg-primary/10 rounded-full">
                                    <Shield className="w-3 h-3 text-primary" />
                                    <span className="text-[10px] font-bold text-primary uppercase tracking-wider">{profileData.role}</span>
                                </div>
                                <span className="w-1 h-1 rounded-full bg-slate-300" />
                                <div className="flex items-center gap-1 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                                    <Building2 className="w-3 h-3" />
                                    {profileData.department}
                                </div>
                            </div>
                        </div>


                    </div>

                    {profileData.bio && (
                        <div className="mt-6 pt-6 border-t border-slate-50">
                            <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">About Reference</h4>
                            <p className="text-sm text-slate-500 leading-relaxed max-w-2xl">
                                {profileData.bio}
                            </p>
                        </div>
                    )}
                </div>
            </motion.div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Contact Details */}
                <motion.div
                    initial={{ opacity: 0, scale: 0.98 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.1 }}
                    className="lg:col-span-2 space-y-6"
                >
                    <div className="bg-white border border-slate-100 rounded-2xl p-6 shadow-sm">
                        <div className="flex items-center justify-between mb-6">
                            <h3 className="text-xs font-black text-slate-900 uppercase tracking-widest">Contact Information</h3>
                            <span className="px-2.5 py-1 bg-emerald-50 text-emerald-600 text-[10px] font-bold rounded-lg border border-emerald-100/50">Verified</span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            {contactItems.map(({ icon: Icon, label, value, color, bg }) => (
                                <div key={label} className="group flex items-center gap-4 p-4 rounded-2xl bg-slate-50/50 border border-slate-50 hover:bg-white hover:border-slate-100 hover:shadow-sm transition-all duration-300">
                                    <div className={`w-10 h-10 rounded-xl ${bg} flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110`}>
                                        <Icon className={`w-4 h-4 ${color}`} />
                                    </div>
                                    <div className="min-w-0">
                                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">{label}</p>
                                        <p className="text-sm font-semibold text-slate-700 truncate">{value}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </motion.div>

                {/* Sidebar Actions */}
                <motion.div
                    initial={{ opacity: 0, scale: 0.98 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.2 }}
                    className="space-y-6"
                >
                    <div className="bg-white border border-slate-100 rounded-2xl p-6 shadow-sm">
                        <h3 className="text-xs font-black text-slate-900 uppercase tracking-widest mb-6">Account Settings</h3>
                        <div className="space-y-3">
                            <motion.button
                                whileHover={{ x: 4 }}
                                className="w-full flex items-center gap-3 p-3.5 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-white hover:shadow-sm transition-all group"
                            >
                                <div className="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center flex-shrink-0 group-hover:bg-primary/10 transition-colors">
                                    <User className="w-3.5 h-3.5 text-slate-500 group-hover:text-primary" />
                                </div>
                                <div className="text-left">
                                    <p className="text-[13px] font-bold text-slate-800">Security</p>
                                    <p className="text-[10px] text-slate-400">Manage password</p>
                                </div>
                            </motion.button>

                            <motion.button
                                whileHover={{ x: 4 }}
                                className="w-full flex items-center gap-3 p-3.5 rounded-xl border border-rose-100 bg-rose-50/30 hover:bg-rose-50 transition-all group"
                            >
                                <div className="w-8 h-8 rounded-lg bg-red-100 flex items-center justify-center flex-shrink-0">
                                    <LogOut className="w-3.5 h-3.5 text-red-500" />
                                </div>
                                <div className="text-left">
                                    <p className="text-[13px] font-bold text-slate-800">Sign Out</p>
                                    <p className="text-[10px] text-slate-400">End your session</p>
                                </div>
                            </motion.button>
                        </div>
                    </div>
                </motion.div>
            </div>
        </div>
    );
};

export default AdminProfile;
