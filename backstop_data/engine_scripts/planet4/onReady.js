module.exports = async (page, scenario, vp) => {

    console.log('-------onReady script-------');

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

    // Hide iframes on Ready state.
    // Disable Happy Point iframe
    await page.evaluate(async () => {
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach((iframe) => {
            console.log('[Ready] before: ' + iframe);
            $(iframe).attr('src', '');
            console.log('[Ready] after: ' + iframe.src);
        });

        const happy_point = document.getElementById('happy-point');
        if (typeof (happy_point) != 'undefined' && happy_point != null) {
            happy_point.style.display = 'none';
        }
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
