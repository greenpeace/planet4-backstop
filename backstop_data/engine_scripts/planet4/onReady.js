module.exports = async (page, scenario, vp) => {

    console.log('-------onReady script-------');

    await page.evaluate(() => {

        // Pause boostrap carousel
        // This targets planet4 gallery block.
        if ('undefined' !== window.jQuery) {
            window.jQuery('.carousel').carousel('pause');
        }
    });
    // await page.waitFor(10000);
};
