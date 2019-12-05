module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    // Add event handler for DOMContentLoaded event using puppeteer api.
    page.on('domcontentloaded', async () => {

        // Log DOMContentLoaded event.
        console.log('DOMContentLoaded');

        // Run snippet on DOMContentLoaded.
        // 1. Find iframes.
        // 2. Disable them by blanking src.
        page.evaluate(() => {
            console.log('search for iframes');
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach((iframe) => {
                console.log('iframe');
                $(iframe).attr('src', '');
                console.log(iframe.src);
            });
        });
    });

    // Add handler for every document that is created.
    //
    // From puppeteer documentation:
    // The function is invoked after the document was created but before any of its scripts were run.
    // This is useful to amend the JavaScript environment
    page.evaluateOnNewDocument(async (scenario) => {
        console.log('----------evaluateOnNewDocument------------');

        document.addEventListener('readystatechange', () => {
            console.log('readyState:' + document.readyState);
        });


        console.log('document location');
        console.log(document.location.href);
        if (document.location.href === scenario.url) {

            // Add event handler for DOMContentLoaded event.
            document.addEventListener('DOMContentLoaded', () => {

                // Search for carousel header block using the wrapper element id.
                const element = document.getElementById("carousel-wrapper-header");

                // If carousel header element exists in the DOM, remove data-carousel-autoplay attribute to prevent autoplay.
                if (typeof (element) != 'undefined' && element != null) {
                    console.log('found carousel header block');
                    element.removeAttribute('data-carousel-autoplay');
                    // Pause carousel header button animation.
                    element.querySelector('.action-button').style.WebkitAnimationPlayState = "paused";
                    element.querySelector('.action-button').style.animationPlayState = "paused";
                }
                console.log('DOMContentLoaded');

                // Set global dataLayer variable to blacklist tag manager modules.
                // Blacklist hotjar module.
                window.dataLayer = [{
                    'gtm.blacklist': ['hjtc']
                }];

                // Disable footer transition
                const footer = document.getElementById("footer");
                footer.style.transition = "none";
            });
        }
    }, scenario);


    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
