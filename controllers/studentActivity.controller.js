const { ActivitySettings, StudentActivityProgress } = require('../models');

exports.getActivities = async (req, res) => {
    try {
        const student_id = req.user.id;

        // Fetch all activities
        const activities = await ActivitySettings.findAll({
            attributes: ['activity_type', 'category', 'total_levels']
        });

        // Fetch student progress
        const progress = await StudentActivityProgress.findAll({
            where: { student_id }
        });

        // Map progress for easy lookup
        const progressMap = {};
        progress.forEach(p => {
            progressMap[p.activity_type] = p.completed_levels;
        });

        // Combine data
        const result = activities.map(activity => {
            const completed = progressMap[activity.activity_type] || 0;
            const total = activity.total_levels || 10;
            const percent = total > 0 ? (completed / total) * 100 : 0;

            return {
                activity_type: activity.activity_type,
                name: formatActivityName(activity.activity_type),
                category: activity.category,
                total_levels: total,
                completed_levels: completed,
                progress_percent: parseFloat(percent.toFixed(2)),
                status: completed === total ? 'COMPLETED' : (completed > 0 ? 'PENDING' : 'NOT_STARTED')
            };
        });

        res.json(result);

    } catch (error) {
        console.error('Get Activities Error:', error);
        res.status(500).json({ message: 'Server error while fetching activities.' });
    }
};

exports.updateProgress = async (req, res) => {
    try {
        const student_id = req.user.id;
        const { activity_type, completed_levels } = req.body;

        if (!activity_type || completed_levels === undefined) {
            return res.status(400).json({ message: 'activity_type and completed_levels are required.' });
        }

        // Check if progress record exists
        let progress = await StudentActivityProgress.findOne({
            where: { student_id, activity_type }
        });

        if (progress) {
            // Update existing record
            progress.completed_levels = completed_levels;
            await progress.save();
        } else {
            // Create new record
            progress = await StudentActivityProgress.create({
                student_id,
                activity_type,
                completed_levels
            });
        }

        res.json({
            message: 'Progress updated successfully.',
            progress: {
                activity_type: progress.activity_type,
                completed_levels: progress.completed_levels
            }
        });

    } catch (error) {
        console.error('Update Progress Error:', error);
        res.status(500).json({ message: 'Server error while updating progress.' });
    }
};

function formatActivityName(type) {
    return type.split('_').map(word =>
        word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    ).join(' ');
}
