module.exports = async (page, scenario, vp) => {

    console.log('-------onReady script-------');

    // 1. Find img tags.
    // 2. Create a Promise which is resolved until all images fire load event.
    await page.evaluate(async () => {
        // Trigger all images to load
        if (typeof LazyLoad === Object) {
            w = new LazyLoad({ elements_selector: 'img', });
            w.loadAll();
        }

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

    // Disable transitions: Carousel, Footer
    await page.evaluate(async () => {

        // Carousel Header
        const carousel = document.getElementById('carousel-wrapper-header');
        if (typeof (carousel) != 'undefined' && carousel != null) {
            console.log('found carousel header block');
            carousel.removeAttribute('data-carousel-autoplay');
            // Pause carousel header button animation.
            carousel.querySelector('.action-button').style.WebkitAnimationPlayState = 'paused';
            carousel.querySelector('.action-button').style.animationPlayState = 'paused';
        }

        // Gallery Carousel
        const carousels = document.querySelectorAll('.carousel-item');
        if (typeof (carousels) != 'undefined' && carousels != null) {
            carousels.forEach((item) => {
                item.classList.add('active');
            });
        }

        // Set global dataLayer variable to blacklist tag manager modules.
        // Blacklist hotjar module.
        window.dataLayer = [{
            'gtm.blacklist': ['hjtc']
        }];

        // Disable footer transition
        const footer = document.getElementById('footer');
        if (typeof (footer) != 'undefined' && footer != null) {
            footer.style.transition = 'none';
        }
    });

    // Sroll to footer to catch lazy loading, except Search
    await page.evaluate(async () => {
        const search = document.querySelector('body.search');
        if (!search) {
            const footer = document.querySelector('footer');
            footer.scrollIntoView();
        }
    });

    await page.waitFor(500);
};
