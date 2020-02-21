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
        const imgs = Array.from(document.querySelectorAll('img'));

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

    // Try to hide iframes on Ready state.
    await page.evaluate(async () => {
        const imgs = Array.from(document.querySelectorAll('img'));

        console.log('[Ready] Search for iframes');
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach((iframe) => {
            console.log('[Ready] before: ' + iframe);
            $(iframe).attr('src', '');
            console.log('[Ready] after: ' + iframe.src);
        });
    });

    // Sroll 200px per time, to catch lazy loading
    // https://github.com/garris/BackstopJS/issues/57#issuecomment-568509475
    await page.evaluate(async () => {
        await new Promise((resolve, reject) => {
            let totalHeight = 0;
            const distance = 200;
            let timer = setInterval(() => {
                var scrollHeight = document.body.scrollHeight;
                window.scrollBy(0, distance);
                totalHeight += distance;

                if(totalHeight >= scrollHeight){
                    clearInterval(timer);
                    resolve();
                }
            }, 100);
        });
    });
    await page.waitFor(500);
};
