import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { GraduationCap, User, Lock, ChevronRight, AlertCircle, CheckCircle2 } from 'lucide-react';
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
            const { role } = response.data;

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
        <div className="min-h-screen w-full flex items-center justify-center bg-[#F8FAFC]">
            {/* Static Background Accents */}
            <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden">
                <div className="absolute top-[-10%] right-[-5%] w-[40%] h-[40%] bg-blue-50 rounded-full blur-[120px]" />
                <div className="absolute bottom-[-10%] left-[-5%] w-[50%] h-[50%] bg-indigo-50/50 rounded-full blur-[150px]" />
            </div>

            <div className="relative z-10 w-full max-w-[460px] px-6 py-12 flex flex-col items-center">
                {/* Branding Header */}
                <div className="flex flex-col items-center mb-10 text-center">
                    <div className="w-16 h-16 bg-white shadow-[0_12px_24px_-8px_rgba(59,130,246,0.15)] rounded-2xl flex items-center justify-center border border-slate-100 mb-6">
                        <GraduationCap size={32} className="text-blue-600" />
                    </div>

                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight mb-2">
                        Welcome Back
                    </h1>
                    <p className="text-slate-500 font-medium text-sm">
                        Sign in to access your dashboard
                    </p>
                </div>

                {/* Main Login Card */}
                <div className="w-full bg-white border border-slate-200/60 rounded-[2.5rem] p-10 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.03)] transition-all">
                    {/* Status Display: Error or Success */}
                    {error && (
                        <div className="mb-6 bg-red-50 border border-red-100 rounded-2xl p-4 flex items-start gap-3 text-red-600 text-sm font-medium animate-in fade-in duration-300">
                            <AlertCircle size={18} className="flex-shrink-0 mt-0.5" />
                            <span>{error}</span>
                        </div>
                    )}

                    <form onSubmit={handleLogin} className="space-y-6">
                        <div className="space-y-2">
                            <label className="text-slate-500 text-[11px] font-bold tracking-widest uppercase ml-1" htmlFor="username">
                                Username
                            </label>
                            <div className="relative">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                    <User size={18} strokeWidth={2} />
                                </div>
                                <input
                                    id="username"
                                    type="text"
                                    placeholder="Enter username"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/20 focus:bg-white transition-all outline-none text-slate-700 placeholder:text-slate-300 font-medium text-sm"
                                    required
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <div className="flex justify-between items-center ml-1">
                                <label className="text-slate-500 text-[11px] font-bold tracking-widest uppercase" htmlFor="password">
                                    Password
                                </label>
                                <Link to="/forgot" className="text-blue-600 hover:text-blue-700 text-[11px] font-bold uppercase tracking-wider">
                                    Forgot?
                                </Link>
                            </div>
                            <div className="relative">
                                <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                    <Lock size={18} strokeWidth={2} />
                                </div>
                                <input
                                    id="password"
                                    type="password"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500/20 focus:bg-white transition-all outline-none text-slate-700 placeholder:text-slate-300 font-medium text-sm"
                                    required
                                />
                            </div>
                        </div>

                        {/* Remember Me */}
                        <div className="flex items-center gap-2 px-1">
                            <input
                                type="checkbox"
                                id="remember"
                                className="w-4 h-4 rounded border-slate-200 text-blue-600 focus:ring-blue-500/10 cursor-pointer"
                            />
                            <label htmlFor="remember" className="text-slate-500 text-xs font-medium cursor-pointer">
                                Keep me signed in
                            </label>
                        </div>

                        <button
                            disabled={isLoading}
                            type="submit"
                            className="w-full py-4 bg-slate-900 text-white font-bold rounded-2xl shadow-xl shadow-slate-900/10 hover:bg-slate-800 active:scale-[0.98] transition-all flex items-center justify-center gap-2"
                        >
                            {isLoading ? (
                                <>
                                    <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                                    <span>Signing in...</span>
                                </>
                            ) : (
                                <>
                                    <span>Sign In</span>
                                    <ChevronRight size={18} strokeWidth={3} />
                                </>
                            )}
                        </button>
                    </form>

                    {/* Minimalist Divider */}
                    <div className="relative my-9 flex items-center justify-center">
                        <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-100"></div></div>
                        <div className="relative bg-white px-4">
                            <span className="text-[10px] font-black text-slate-300 uppercase tracking-[0.3em]">OR</span>
                        </div>
                    </div>

                    <button
                        type="button"
                        className="w-full py-4 bg-white border border-slate-100 text-slate-600 font-bold rounded-2xl flex items-center justify-center gap-3 hover:bg-slate-50 hover:border-slate-200 transition-all text-sm shadow-sm active:scale-[0.98]"
                    >
                        <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" className="w-5 h-5" />
                        Continue with Google
                    </button>
                </div>

                {/* Footer */}
                <p className="mt-10 text-center text-slate-400 text-sm font-medium">
                    Don't have an account?{' '}
                    <Link to="/signup" className="text-blue-600 font-bold hover:underline">
                        Get started
                    </Link>
                </p>
            </div>

            {/* Subtle Pattern Overlay */}
            <div className="absolute inset-0 z-[-1] opacity-[0.02]" style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 0)', backgroundSize: '32px 32px' }} />
        </div>
    );
};

export default Login;
