module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    page.on('load', () => {
        console.log('-----Page loading-----');

        // Remove iframes from the page
        // to avoid happypoint issues
        page.$$eval('iframe', (frames) => {
            frames.map((frame) => {
                console.log('Removing iframe');
                frame.parentNode.removeChild(frame);
            });
        });
    });

    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
