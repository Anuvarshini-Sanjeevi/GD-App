import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8080/api', // Setting common base for /api
    headers: {
        'Content-Type': 'application/json',
    },
});

// For specific auth endpoints outside /api if needed
export const authApi = axios.create({
    baseURL: 'http://localhost:8080/auth',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Interceptor to add Authorization header
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => {
    return Promise.reject(error);
});

authApi.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => {
    return Promise.reject(error);
});

// Response interceptor to handle 401 errors globally
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response && error.response.status === 401) {
            console.error('Unauthorized access - Redirecting to login');
            localStorage.removeItem('token');
            localStorage.removeItem('userData');
            window.location.href = '/';
        }
        return Promise.reject(error);
    }
);

export const getCurrentUser = () => {
    const userData = localStorage.getItem('userData');
    return userData ? JSON.parse(userData) : null;
};

export default api;
