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
    AlertCircle
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
                    headers: {
                        'Content-Type': 'application/json',
                    }
                });

                // If /auth/me fails, fallback to /api/admins/1
                if (!response.ok) {
                    console.warn('/auth/me failed, trying fallback /api/admins/1');
                    response = await fetch('http://localhost:8080/api/admins/1', {
                        method: 'GET',
                        headers: {
                            'Content-Type': 'application/json',
                        }
                    });
                }

                if (!response.ok) {
                    throw new Error(`Failed to fetch profile: ${response.status} ${response.statusText}`);
                }

                const data = await response.json();
                console.log('Profile API Response:', data);

                // Handle the response data structure
                let admin = null;
                if (Array.isArray(data)) {
                    admin = data[0];
                } else if (data.value && Array.isArray(data.value)) {
                    admin = data.value[0];
                } else if (data.admin) {
                    admin = data.admin; // Handle { admin: {...} } structure
                } else if (data.user) {
                    admin = data.user; // Handle { user: {...} } structure
                } else {
                    admin = data; // Single object
                }

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
                console.error('Profile fetch error:', err);
                setError(err.message || 'Failed to load profile');
            } finally {
                setLoading(false);
            }
        };

        fetchProfile();
    }, []);

    if (loading) {
        return (
            <div className="h-full min-h-screen flex flex-col items-center justify-center bg-white">
                <Loader2 className="w-10 h-10 text-[#3B82F6] animate-spin mb-4" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Loading profile...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="h-full min-h-screen flex flex-col items-center justify-center bg-white p-6">
                <div className="bg-red-50 border border-red-100 p-8 rounded-3xl text-center max-w-md w-full">
                    <AlertCircle className="w-12 h-12 text-red-400 mx-auto mb-4" />
                    <h3 className="text-sm font-bold text-red-600 uppercase tracking-wide mb-2">Error Loading Profile</h3>
                    <p className="text-[11px] font-medium text-slate-500 leading-relaxed mb-6">{error}</p>
                    <button
                        onClick={() => window.location.reload()}
                        className="px-6 py-2 bg-white border border-red-100 text-red-500 rounded-xl text-[10px] font-bold uppercase tracking-wide hover:bg-red-100 transition-colors"
                    >
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="relative min-h-screen">
            {/* Floating Background Orbs */}
            <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
                <motion.div
                    animate={{ rotate: 360, x: [0, 100, 0], y: [0, 50, 0] }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                    className="absolute -top-40 -left-40 w-96 h-96 bg-primary/5 rounded-full blur-[100px]"
                />
                <motion.div
                    animate={{ rotate: -360, x: [0, -100, 0], y: [0, -50, 0] }}
                    transition={{ duration: 25, repeat: Infinity, ease: "linear" }}
                    className="absolute top-1/2 -right-40 w-[500px] h-[500px] bg-cyan-400/5 rounded-full blur-[120px]"
                />
            </div>

            <div className="max-w-5xl mx-auto space-y-6 pb-10 pt-4 px-4">
                {/* Header */}
                <motion.div
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="flex justify-between items-center"
                >
                    <div>
                        <p className="text-slate-400 text-[9px] font-black uppercase tracking-widest mb-0.5">Admin Console</p>
                        <h1 className="text-2xl font-black text-slate-900 leading-none">Profile</h1>
                    </div>
                </motion.div>

                {/* Profile Card */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 }}
                    className="bg-white rounded-2xl border border-slate-200 p-8 shadow-sm"
                >
                    <div className="flex flex-col md:flex-row gap-8">
                        {/* Profile Picture */}
                        <div className="relative group flex-shrink-0">
                            <div className="w-32 h-32 rounded-2xl overflow-hidden border-2 border-slate-200 bg-slate-50 flex items-center justify-center">
                                {profileData.photo ? (
                                    <img
                                        src={profileData.photo}
                                        alt="Profile"
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <Shield className="w-12 h-12 text-slate-200" />
                                )}
                            </div>
                        </div>

                        {/* Profile Info */}
                        <div className="flex-1 space-y-6">
                            <div>
                                <h2 className="text-2xl font-bold text-slate-900">{profileData.name}</h2>
                                <div className="flex items-center gap-2 mt-2">
                                    <Shield className="w-4 h-4 text-primary" />
                                    <p className="text-sm font-semibold text-primary">{profileData.role}</p>
                                </div>
                            </div>

                            {/* Contact Info */}
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-50">
                                    <Mail className="w-5 h-5 text-slate-400" />
                                    <div>
                                        <p className="text-[10px] font-bold text-slate-400 uppercase">Email</p>
                                        <p className="text-sm font-medium text-slate-700">{profileData.email}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-50">
                                    <Phone className="w-5 h-5 text-slate-400" />
                                    <div>
                                        <p className="text-[10px] font-bold text-slate-400 uppercase">Phone</p>
                                        <p className="text-sm font-medium text-slate-700">{profileData.phone}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-50">
                                    <MapPin className="w-5 h-5 text-slate-400" />
                                    <div>
                                        <p className="text-[10px] font-bold text-slate-400 uppercase">Location</p>
                                        <p className="text-sm font-medium text-slate-700">{profileData.location}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-50">
                                    <Building2 className="w-5 h-5 text-slate-400" />
                                    <div>
                                        <p className="text-[10px] font-bold text-slate-400 uppercase">Department</p>
                                        <p className="text-sm font-medium text-slate-700">{profileData.department}</p>
                                    </div>
                                </div>
                            </div>

                            {/* Bio */}
                            <div>
                                <label className="text-[10px] font-bold text-slate-400 uppercase block mb-2">About</label>
                                <p className="text-sm text-slate-600 leading-relaxed">{profileData.bio}</p>
                            </div>
                        </div>
                    </div>
                </motion.div>

                {/* Settings */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm"
                >
                    <h3 className="text-lg font-bold text-slate-900 mb-4">Settings</h3>
                    <div className="space-y-2">
                        <motion.button
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.3 }}
                            whileHover={{ x: 5 }}
                            className="w-full flex items-center gap-4 p-4 rounded-lg hover:bg-slate-50 transition-all text-left group"
                        >
                            <div className="w-10 h-10 rounded-lg bg-red-50 flex items-center justify-center group-hover:bg-red-100 transition-colors">
                                <LogOut className="w-5 h-5 text-red-500" />
                            </div>
                            <div className="flex-1">
                                <p className="text-sm font-semibold text-slate-900">Sign Out</p>
                                <p className="text-xs text-slate-500">Logout from your account</p>
                            </div>
                        </motion.button>
                    </div>
                </motion.div>
            </div>
        </div>
    );
};

export default AdminProfile;


