
const fs = require('fs');
fetch('http://localhost:8080/api/admin-analytics/rankings?activity=GROUP_DISCUSSION&level=OVERALL')
    .then(res => res.json())
    .then(data => fs.writeFileSync('repro_output.json', JSON.stringify(data, null, 2)))
    .catch(err => console.error(err));
