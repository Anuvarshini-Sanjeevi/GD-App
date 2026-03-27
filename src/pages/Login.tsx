import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate, Link } from 'react-router-dom';
import { GraduationCap, User, Lock, ChevronRight, AlertCircle } from 'lucide-react';
import { authApi } from '../utils/api';

const Login: React.FC = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError('');

        try {
            const response = await authApi.post('/login', { username, password });
            const { token, user } = response.data;
            const role = user.role.toUpperCase();

            // Store credentials
            localStorage.setItem('token', token);
            localStorage.setItem('userData', JSON.stringify(user));

            // Role-based redirection
            if (role === 'ADMIN') {
                navigate('/admin');
            } else if (role === 'SUPERVISOR') {
                navigate('/supervisor');
            } else if (role === 'STUDENT') {
                navigate('/student');
            } else {
                navigate('/admin'); // Default fallback
            }
        } catch (err: any) {
            console.error('Login failed:', err);
            setError(err.response?.data?.message || 'Invalid credentials or server connection issue');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen w-full flex items-center justify-center bg-background relative overflow-hidden">
            {/* Professional Background Orbs */}
            <div className="absolute inset-0 z-0 pointer-events-none">
                <div className="absolute top-[-15%] right-[-10%] w-[50%] h-[50%] bg-primary/5 rounded-full blur-[140px]" />
                <div className="absolute bottom-[-20%] left-[-10%] w-[60%] h-[60%] bg-indigo-500/5 rounded-full blur-[160px]" />
            </div>

            <div className="relative z-10 w-full max-w-[480px] px-6 py-12 flex flex-col items-center">
                {/* Branding */}
                <motion.div 
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="flex flex-col items-center mb-10 text-center"
                >
                    <div className="w-14 h-14 bg-white shadow-xl shadow-primary/10 rounded-2xl flex items-center justify-center border border-slate-100 mb-6">
                        <GraduationCap size={28} className="text-primary" />
                    </div>

                    <h1 className="text-2xl font-black text-slate-900 tracking-tight mb-2">
                        Education Portal
                    </h1>
                    <p className="text-slate-400 font-medium text-xs uppercase tracking-widest">
                        Professional Learning Management
                    </p>
                </motion.div>

                {/* Login Card */}
                <motion.div 
                    initial={{ opacity: 0, scale: 0.98 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.1 }}
                    className="w-full glass-card rounded-[2rem] p-10 overflow-hidden relative"
                >
                    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary/40 via-primary to-primary/40" />
                    
                    <div className="mb-8">
                        <h2 className="text-xl font-bold text-slate-800">Welcome Back</h2>
                        <p className="text-slate-400 text-sm mt-1">Please enter your details to continue</p>
                    </div>

                    {error && (
                        <motion.div 
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: 'auto' }}
                            className="mb-6 bg-red-50 border border-red-100 rounded-xl p-3.5 flex items-start gap-3 text-red-600 text-[13px] font-medium"
                        >
                            <AlertCircle size={16} className="flex-shrink-0 mt-0.5" />
                            <span>{error}</span>
                        </motion.div>
                    )}

                    <form onSubmit={handleLogin} className="space-y-5">
                        <div className="space-y-1.5">
                            <label className="text-slate-500 text-[10px] font-bold tracking-wider uppercase ml-1" htmlFor="username">
                                Username
                            </label>
                            <div className="relative">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                    <User size={17} />
                                </div>
                                <input
                                    id="username"
                                    type="text"
                                    placeholder="your-username"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    className="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary/30 focus:bg-white transition-all outline-none text-slate-700 placeholder:text-slate-300 font-medium text-sm"
                                    required
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <div className="flex justify-between items-center ml-1">
                                <label className="text-slate-500 text-[10px] font-bold tracking-wider uppercase" htmlFor="password">
                                    Password
                                </label>
                                <Link to="/forgot" className="text-primary hover:text-primary/80 text-[10px] font-bold uppercase tracking-wider transition-colors">
                                    Forgot?
                                </Link>
                            </div>
                            <div className="relative">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                    <Lock size={17} />
                                </div>
                                <input
                                    id="password"
                                    type="password"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary/30 focus:bg-white transition-all outline-none text-slate-700 placeholder:text-slate-300 font-medium text-sm"
                                    required
                                />
                            </div>
                        </div>

                        <div className="flex items-center gap-2.5 px-1 py-1">
                            <input
                                type="checkbox"
                                id="remember"
                                className="w-4 h-4 rounded-md border-slate-200 text-primary focus:ring-primary/20 cursor-pointer"
                            />
                            <label htmlFor="remember" className="text-slate-400 text-xs font-medium cursor-pointer select-none">
                                Remember this device
                            </label>
                        </div>

                        <button
                            disabled={isLoading}
                            type="submit"
                            className="btn-premium w-full py-3.5 bg-slate-900 text-white font-bold rounded-xl shadow-lg shadow-slate-900/10 hover:shadow-xl hover:shadow-slate-900/20 active:scale-[0.98] transition-all flex items-center justify-center gap-2 mt-2"
                        >
                            {isLoading ? (
                                <>
                                    <div className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                                    <span className="text-sm">Authenticating...</span>
                                </>
                            ) : (
                                <>
                                    <span className="text-sm">Sign Into Portal</span>
                                    <ChevronRight size={16} strokeWidth={3} />
                                </>
                            )}
                        </button>
                    </form>

                    {/* Divider */}
                    <div className="relative my-8 flex items-center justify-center">
                        <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-100"></div></div>
                        <div className="relative bg-white px-4">
                            <span className="text-[9px] font-black text-slate-300 uppercase tracking-[0.2em]">secure access</span>
                        </div>
                    </div>

                    <button
                        type="button"
                        className="w-full py-3.5 bg-white border border-slate-100 text-slate-600 font-bold rounded-xl flex items-center justify-center gap-3 hover:bg-slate-50 hover:border-slate-200 transition-all text-xs shadow-sm active:scale-[0.98]"
                    >
                        <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" className="w-4 h-4" />
                        Professional Account
                    </button>
                </motion.div>

                {/* Footer */}
                <motion.p 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.3 }}
                    className="mt-10 text-center text-slate-400 text-xs font-medium"
                >
                    Management access only. Need help?{' '}
                    <Link to="/support" className="text-primary font-bold hover:underline">
                        Contact IT
                    </Link>
                </motion.p>
            </div>

            {/* Subtle Grid Pattern Overlay */}
            <div className="absolute inset-x-0 top-0 h-full z-[-1] opacity-[0.03]" 
                style={{ 
                    backgroundImage: `linear-gradient(to right, #808080 1px, transparent 1px), linear-gradient(to bottom, #808080 1px, transparent 1px)`,
                    backgroundSize: '40px 40px'
                }} 
            />
        </div>
    );
};

export default Login;
