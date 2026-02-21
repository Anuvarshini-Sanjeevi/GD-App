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

export default api;
