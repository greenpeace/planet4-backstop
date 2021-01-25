const fs = require('fs');

const baseConfig = JSON.parse(fs.readFileSync('backstop.json'));
let localConfig;
try {
    localConfig = JSON.parse(fs.readFileSync('/src/repo/backstop-pages.json'));
} catch (e) {
    localConfig = {};
}

const addQueryString = scenario => {
    const url = scenario.url.includes('?') ? scenario.url : `${scenario.url}?backstop=1`;

    return {...scenario, url};
};

newConfig = {
    ...baseConfig,
    scenarios: [
        ...baseConfig.scenarios,
        ...(localConfig.scenarios || []),
    ].map(addQueryString),
    viewports: [
        ...baseConfig.viewports,
        ...(localConfig.viewports || []),
    ],
};

fs.writeFileSync('backstop.json', JSON.stringify(newConfig, null, 2));


