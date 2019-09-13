module.exports = async (page, scenario, vp) => {

    console.log('-------onReady script-------');

    await page.evaluate(() => {

        // Pause boostrap carousel
        // This targets planet4 gallery block.
        if ('undefined' !== window.jQuery) {
            window.jQuery('.carousel').carousel('pause');
        }
    });

    // 1. Find img tags.
    // 2. Create a Promise which is resolved until all images fire load event.
    await page.evaluate(async () => {
        const imgs = Array.from(document.querySelectorAll("img"));

        if (imgs.length > 0) {
            await Promise.all(imgs.map(img => {
                if (img.complete) return;
                return new Promise((resolve, reject) => {
                    img.addEventListener('load', resolve);
                    img.addEventListener('error', reject);
                });
            }));
        }
    });
};
