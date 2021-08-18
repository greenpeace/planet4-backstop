module.exports = async function (page, scenario, vp) {
    const start = performance ? performance.now() : process.uptime();
    console.log('-------onBefore script-------');

    page.once('load', () => {
        const end = performance ? performance.now() : process.uptime();
        console.log('-----Page loaded!----- in ' + (start - end) + 'ms');
    });

};
