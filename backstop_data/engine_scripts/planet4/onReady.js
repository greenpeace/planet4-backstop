const timeSince = start => (performance ? performance.now() : process.uptime()) - start;
module.exports = async (page, scenario, vp) => {
    const start = performance ? performance.now() : process.uptime();

    console.log('-------onReady script-------');

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
    console.log('evaluated iframes ' + timeSince(start));

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
    console.log('evaluated carousels ' + timeSince(start));


    // Sroll to footer to catch lazy loading, except Search
    await page.evaluate(async () => {
        const search = document.querySelector('body.search');
        const footer = document.querySelector('footer');
        if (!search && typeof (footer) != 'undefined' && footer != null) {
            footer.scrollIntoView();
        }
    });
    console.log('evaluated scroll to footer ' + timeSince(start));

    await page.waitFor(1000);
    console.log('waited 1 second');
};
